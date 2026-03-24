//
//  WatchMatchViewModel.swift
//  RefTrack Watch App
//
//  MVVM: spojuje stavový automat, workout, haptiku a synchronizaci s iPhonem.
//

import Combine
import Foundation
import SwiftUI

@MainActor
final class WatchMatchViewModel: ObservableObject {
    let engine = MatchTimerEngine()
    let workout = WatchWorkoutManager()

    @Published private(set) var snapshot: MatchDisplaySnapshot

    @Published var showEndFirstHalfConfirm = false
    @Published var showHalftimeContinueConfirm = false
    @Published var showEndMatchConfirm = false

    private var cancellables = [AnyCancellable]()
    private var lastPhase: MatchPhase
    private var didFireHalftimeZeroHaptic = false

    init() {
        let initialSnap = MatchDisplayFormatter.snapshot(
            state: engine.state,
            at: Date(),
            distanceMeters: 0,
            energyKilocalories: 0
        )
        self.snapshot = initialSnap
        self.lastPhase = engine.state.phase

        workout.requestHealthKitAuthorization()

        engine.objectWillChange
            .merge(with: workout.objectWillChange)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.recompute()
            }
            .store(in: &cancellables)

        recompute()
    }

    // MARK: - Akce obrazovek

    func beginNewMatchFlow() {
        engine.beginNewMatchFlow()
        recompute()
    }

    func startMatchFromReadyScreen() {
        let start = Date()
        workout.startSoccerWorkout(at: start)
        engine.startFirstHalf(now: start)
        recompute()
    }

    func startSecondHalfFromIntro() {
        engine.startSecondHalf()
        recompute()
    }

    func resetAfterFinished() {
        workout.resetPublishedMetrics()
        engine.resetToIdle()
        lastPhase = .idle
        didFireHalftimeZeroHaptic = false
        recompute()
    }

    func refreshFromForeground() {
        engine.refreshNow()
        recompute()
    }

    func handlePlayfieldTap() {
        switch snapshot.phase {
        case .firstHalfRunning, .firstHalfStoppageTime:
            WatchHaptics.confirmPrompt()
            showEndFirstHalfConfirm = true
        case .halftimeBreak:
            WatchHaptics.confirmPrompt()
            showHalftimeContinueConfirm = true
        case .secondHalfRunning, .secondHalfStoppageTime:
            WatchHaptics.confirmPrompt()
            showEndMatchConfirm = true
        default:
            break
        }
    }

    func confirmEndFirstHalf() {
        showEndFirstHalfConfirm = false
        engine.confirmEndFirstHalf()
        recompute()
    }

    func confirmHalftimeContinue() {
        showHalftimeContinueConfirm = false
        engine.confirmContinueToSecondHalf()
        recompute()
    }

    func confirmEndMatch() {
        showEndMatchConfirm = false
        let end = Date()
        engine.confirmEndMatch(now: end)
        workout.endWorkout(at: end) { _ in
            Task { @MainActor in
                self.recompute()
            }
        }
        recompute()
    }

    var summary: MatchSummary {
        engine.matchSummary(
            distanceMeters: workout.distanceMeters,
            energyKilocalories: workout.energyKilocalories
        )
    }

    // MARK: - Interní

    private func recompute() {
        let snap = MatchDisplayFormatter.snapshot(
            state: engine.state,
            at: engine.displayNow,
            distanceMeters: workout.distanceMeters,
            energyKilocalories: workout.energyKilocalories
        )
        snapshot = snap
        applyHapticsIfNeeded(snap)
        pushToPhone()
    }

    private func applyHapticsIfNeeded(_ snap: MatchDisplaySnapshot) {
        if snap.phase != lastPhase {
            if snap.phase == .firstHalfStoppageTime || snap.phase == .secondHalfStoppageTime {
                WatchHaptics.regulationEnd()
            }
            lastPhase = snap.phase
        }

        if snap.phase == .halftimeBreak, snap.halftimeRemainingSeconds == 0, !didFireHalftimeZeroHaptic {
            didFireHalftimeZeroHaptic = true
            WatchHaptics.halftimeDone()
        }
        if snap.phase != .halftimeBreak {
            didFireHalftimeZeroHaptic = false
        }
    }

    private func pushToPhone() {
        let envelope = MatchWireEnvelope(
            state: engine.state,
            distanceMeters: workout.distanceMeters,
            energyKilocalories: workout.energyKilocalories,
            sentAt: Date()
        )
        WatchWCSession.shared.pushMatchEnvelope(envelope)
    }
}
