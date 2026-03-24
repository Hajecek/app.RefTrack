//
//  PhoneWCSession.swift
//  RefTrack
//

import Combine
import Foundation
import WatchConnectivity

/// Aktivuje a drží spojení s watch aplikací přes WatchConnectivity (iPhone).
@MainActor
final class PhoneWCSession: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = PhoneWCSession()

    @Published private(set) var activationState: WCSessionActivationState = .notActivated
    @Published private(set) var isReachable = false
    @Published private(set) var isPaired = false
    @Published private(set) var isWatchAppInstalled = false
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

    private func syncState(from session: WCSession) {
        activationState = session.activationState
        isReachable = session.isReachable
        isPaired = session.isPaired
        isWatchAppInstalled = session.isWatchAppInstalled
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

    nonisolated func sessionWatchStateDidChange(_ session: WCSession) {
        Task { @MainActor in
            syncState(from: session)
        }
    }

    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {}

    nonisolated func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
}
