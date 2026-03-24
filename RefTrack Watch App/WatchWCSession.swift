//
//  WatchWCSession.swift
//  RefTrack Watch App
//

import Combine
import Foundation
import WatchConnectivity

private enum WCKeys {
    static let matchEnvelope = "matchEnvelope"
}

/// Aktivuje spojení s companion iOS aplikací přes WatchConnectivity (Apple Watch).
@MainActor
final class WatchWCSession: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = WatchWCSession()

    @Published private(set) var activationState: WCSessionActivationState = .notActivated
    @Published private(set) var isReachable = false
    @Published private(set) var lastActivationError: String?

    override private init() {
        super.init()
    }

    func activateIfNeeded() {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        guard session.delegate == nil else { return }
        session.delegate = self
        session.activate()
    }

    /// Poslední známý stav zápasu pro iPhone (`updateApplicationContext` přepisuje celý kontext).
    func pushMatchEnvelope(_ envelope: MatchWireEnvelope) {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        guard session.activationState == .activated else { return }

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        guard let data = try? encoder.encode(envelope) else { return }

        do {
            try session.updateApplicationContext([WCKeys.matchEnvelope: data])
        } catch {
            lastActivationError = error.localizedDescription
        }
    }

    private func syncState(from session: WCSession) {
        activationState = session.activationState
        isReachable = session.isReachable
    }

    nonisolated func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        Task { @MainActor in
            self.lastActivationError = error?.localizedDescription
            syncState(from: session)
        }
    }

    nonisolated func sessionReachabilityDidChange(_ session: WCSession) {
        Task { @MainActor in
            self.isReachable = session.isReachable
        }
    }
}
