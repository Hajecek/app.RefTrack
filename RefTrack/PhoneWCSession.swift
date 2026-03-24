//
//  PhoneWCSession.swift
//  RefTrack
//

import Combine
import Foundation
import WatchConnectivity

private enum WCKeys {
    static let matchEnvelope = "matchEnvelope"
}

/// Aktivuje a drží spojení s watch aplikací přes WatchConnectivity (iPhone).
@MainActor
final class PhoneWCSession: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = PhoneWCSession()

    @Published private(set) var activationState: WCSessionActivationState = .notActivated
    @Published private(set) var isReachable = false
    @Published private(set) var isPaired = false
    @Published private(set) var isWatchAppInstalled = false
    @Published private(set) var lastActivationError: String?
    @Published private(set) var lastMatchEnvelope: MatchWireEnvelope?

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

    private func syncState(from session: WCSession) {
        activationState = session.activationState
        isReachable = session.isReachable
        isPaired = session.isPaired
        isWatchAppInstalled = session.isWatchAppInstalled
    }

    private func applyMatchContext(_ applicationContext: [String: Any]) {
        guard let data = applicationContext[WCKeys.matchEnvelope] as? Data else { return }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let env = try? decoder.decode(MatchWireEnvelope.self, from: data) {
            lastMatchEnvelope = env
        }
    }

    nonisolated func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        Task { @MainActor in
            self.lastActivationError = error?.localizedDescription
            syncState(from: session)
            applyMatchContext(session.receivedApplicationContext)
        }
    }

    nonisolated func sessionReachabilityDidChange(_ session: WCSession) {
        Task { @MainActor in
            self.isReachable = session.isReachable
        }
    }

    nonisolated func sessionWatchStateDidChange(_ session: WCSession) {
        Task { @MainActor in
            syncState(from: session)
        }
    }

    nonisolated func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        Task { @MainActor in
            applyMatchContext(applicationContext)
        }
    }

    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {}

    nonisolated func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
}
