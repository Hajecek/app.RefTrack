//
//  WatchWorkoutManager.swift
//  RefTrack Watch App
//
//  HKWorkoutSession + HKLiveWorkoutBuilder pro přesné měření na hodinkách a zápis do Zdraví.
//

import Combine
import Foundation
import HealthKit

@MainActor
final class WatchWorkoutManager: NSObject, ObservableObject {
    @Published private(set) var distanceMeters: Double = 0
    @Published private(set) var energyKilocalories: Double = 0
    @Published private(set) var workoutState: HKWorkoutSessionState = .notStarted
    @Published private(set) var authorizationDenied: Bool = false
    @Published private(set) var lastErrorDescription: String?

    private let healthStore = HKHealthStore()
    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?

    private static let distanceQuantityType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
    private static let energyQuantityType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!

    private var typesToShare: Set<HKSampleType> {
        [
            HKObjectType.workoutType(),
        ]
    }

    private var typesToRead: Set<HKObjectType> {
        [
            HKObjectType.workoutType(),
            Self.distanceQuantityType,
            Self.energyQuantityType,
            HKObjectType.activitySummaryType(),
        ]
    }

    func requestHealthKitAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            lastErrorDescription = "HealthKit na tomto zařízení není k dispozici."
            return
        }

        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { [weak self] success, error in
            Task { @MainActor in
                if let error {
                    self?.lastErrorDescription = error.localizedDescription
                }
                if !success {
                    self?.authorizationDenied = true
                }
            }
        }
    }

    func startSoccerWorkout(at startDate: Date = Date()) {
        guard HKHealthStore.isHealthDataAvailable() else { return }

        distanceMeters = 0
        energyKilocalories = 0
        lastErrorDescription = nil

        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .soccer
        configuration.locationType = .outdoor

        do {
            let newSession = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            let newBuilder = newSession.associatedWorkoutBuilder()
            newBuilder.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)

            session = newSession
            builder = newBuilder

            newSession.delegate = self
            newBuilder.delegate = self

            workoutState = newSession.state
            newSession.startActivity(with: startDate)
            newBuilder.beginCollection(withStart: startDate) { [weak self] success, error in
                Task { @MainActor in
                    if !success {
                        self?.lastErrorDescription = error?.localizedDescription ?? "beginCollection selhalo."
                    }
                }
            }
        } catch {
            lastErrorDescription = error.localizedDescription
        }
    }

    func endWorkout(at endDate: Date = Date(), completion: @escaping (Bool) -> Void) {
        guard let session, let builder else {
            completion(true)
            return
        }

        session.end()
        // HealthKit: `finishWorkout` zavolej až po dokončení `endCollection`.
        // Jinak se může stát, že některé metriky (např. vzdálenost) se uloží odděleně a v aplikaci Fitness pak
        // vidíš trvání a vzdálenost jako dvě různé „věci“.
        builder.endCollection(withEnd: endDate) { [weak self] success, error in
            builder.finishWorkout { [weak self] _, finishError in
                Task { @MainActor in
                    if !success {
                        self?.lastErrorDescription = error?.localizedDescription
                    }
                    if let finishError {
                        self?.lastErrorDescription = finishError.localizedDescription
                    }

                    self?.session = nil
                    self?.builder = nil
                    self?.workoutState = .ended
                    completion(success && finishError == nil)
                }
            }
        }
    }

    func resetPublishedMetrics() {
        distanceMeters = 0
        energyKilocalories = 0
    }
}

// MARK: - HKWorkoutSessionDelegate

extension WatchWorkoutManager: HKWorkoutSessionDelegate {
    nonisolated func workoutSession(
        _ workoutSession: HKWorkoutSession,
        didChangeTo toState: HKWorkoutSessionState,
        from fromState: HKWorkoutSessionState,
        date: Date
    ) {
        Task { @MainActor in
            self.workoutState = toState
        }
    }

    nonisolated func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        Task { @MainActor in
            self.lastErrorDescription = error.localizedDescription
        }
    }
}

// MARK: - HKLiveWorkoutBuilderDelegate

extension WatchWorkoutManager: HKLiveWorkoutBuilderDelegate {
    nonisolated func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else { continue }
            guard let statistics = workoutBuilder.statistics(for: quantityType) else { continue }

            Task { @MainActor in
                if quantityType == Self.distanceQuantityType, let q = statistics.sumQuantity() {
                    self.distanceMeters = q.doubleValue(for: .meter())
                } else if quantityType == Self.energyQuantityType, let q = statistics.sumQuantity() {
                    self.energyKilocalories = q.doubleValue(for: .kilocalorie())
                }
            }
        }
    }

    nonisolated func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {}
}
