//
//  MatchLiveActivityController.swift
//  RefTrack
//

import ActivityKit
import Combine
import Foundation

/// Live Activity na Lock Screen / Dynamic Island — synchronizace se stavem z hodinek + sekundový tik pro plynulý text.
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
                self?.sync(phone: phone, now: Date())
            }
            .store(in: &cancellables)

        Timer.publish(every: 1, tolerance: 0.2, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.sync(phone: phone, now: Date())
            }
            .store(in: &cancellables)

        sync(phone: phone, now: Date())
    }

    func sync(phone: PhoneWCSession, now: Date) {
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

        let state = Self.makeContentState(envelope: envelope, now: now)

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

    private static func makeContentState(envelope: MatchWireEnvelope, now: Date) -> RefTrackMatchAttributes.ContentState {
        let snap = MatchMirrorDisplayFormatter.snapshot(
            state: envelope.state,
            at: now,
            distanceMeters: envelope.distanceMeters,
            energyKilocalories: envelope.energyKilocalories
        )

        let headline = phaseHeadline(snap.phase)
        let primary = MatchMirrorTimeFormat.mmss(
            snap.phase == .halftimeBreak ? snap.halftimeRemainingSeconds : snap.mainClockSeconds
        )

        var secondary: String?
        if snap.isStoppageActive {
            secondary = "Nastavení \(MatchMirrorTimeFormat.mmss(snap.stoppageSeconds))"
        } else if snap.distanceMeters >= 1 {
            secondary = MatchMirrorTimeFormat.formatDistanceMeters(snap.distanceMeters)
        }

        var htStart: Date?
        var htEnd: Date?
        if snap.phase == .halftimeBreak, let hs = envelope.state.halftimeStartedAt {
            htStart = hs
            htEnd = hs.addingTimeInterval(TimeInterval(envelope.state.config.halftimeSeconds))
        }

        return RefTrackMatchAttributes.ContentState(
            headline: headline,
            primaryTime: primary,
            secondaryLine: secondary,
            halftimeCountdownStart: htStart,
            halftimeCountdownEnd: htEnd
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
