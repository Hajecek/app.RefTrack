//
//  MatchLiveActivityController.swift
//  RefTrack
//

import ActivityKit
import Combine
import Foundation

/// Live Activity — aktualizace jen při změně stavu z hodinek. Čas na zamykáčce tiká v extension přes `TimelineView`.
@MainActor
final class MatchLiveActivityController {
    static let shared = MatchLiveActivityController()

    private var activity: Activity<RefTrackMatchAttributes>?
    private var cancellables = Set<AnyCancellable>()
    private var observationStarted = false

    private init() {}

    func startObserving(phone: PhoneWCSession) {
        guard !observationStarted else { return }
        observationStarted = true
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        phone.$lastMatchEnvelope
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.sync(phone: phone)
            }
            .store(in: &cancellables)

        sync(phone: phone)
    }

    func sync(phone: PhoneWCSession) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            Task { await endActivity() }
            return
        }

        guard let envelope = phone.lastMatchEnvelope else {
            Task { await endActivity() }
            return
        }

        let phase = envelope.state.phase
        if phase == .idle || phase == .finished {
            Task { await endActivity() }
            return
        }

        let state = Self.makeContentState(envelope: envelope)

        Task {
            if let existing = activity {
                await existing.update(
                    ActivityContent(state: state, staleDate: nil)
                )
            } else {
                do {
                    activity = try Activity.request(
                        attributes: RefTrackMatchAttributes(),
                        content: ActivityContent(state: state, staleDate: nil),
                        pushType: nil
                    )
                } catch {}
            }
        }
    }

    private func endActivity() async {
        guard let activity else { return }
        let final = activity.content.state
        await activity.end(ActivityContent(state: final, staleDate: nil), dismissalPolicy: .immediate)
        self.activity = nil
    }

    private static func makeContentState(envelope: MatchWireEnvelope) -> RefTrackMatchAttributes.ContentState {
        let headline = phaseHeadline(envelope.state.phase)
        return RefTrackMatchAttributes.ContentState(
            headline: headline,
            engineState: envelope.state,
            distanceMeters: envelope.distanceMeters,
            energyKilocalories: envelope.energyKilocalories
        )
    }

    private static func phaseHeadline(_ p: MatchPhase) -> String {
        switch p {
        case .idle: return "RefTrack"
        case .readyToStart: return "Připraveno ke startu"
        case .firstHalfRunning: return "1. poločas"
        case .firstHalfStoppageTime: return "1. poločas · nastavení"
        case .halftimeBreak: return "Poločasová pauza"
        case .readyForSecondHalf: return "Před 2. poločasem"
        case .secondHalfRunning: return "2. poločas"
        case .secondHalfStoppageTime: return "2. poločas · nastavení"
        case .finished: return "Konec"
        }
    }
}
