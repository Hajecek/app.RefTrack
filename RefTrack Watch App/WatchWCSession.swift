//
//  WatchWCSession.swift
//  RefTrack Watch App
//

import Combine
import Foundation
import WatchConnectivity

private enum WCKeys {
    static let matchEnvelope = "matchEnvelope"
    static let matchSettings = "matchSettings"
    static let action = "action"
    static let resetToIdle = "resetToIdle"
}

private enum WatchSettingsPersistence {
    static let configData = "reftrack.synced.matchConfiguration.data"
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

    /// Konfigurace z iPhonu (UserDefaults), jinak výchozí 45 / 15.
    var resolvedMatchConfiguration: MatchConfiguration {
        if let d = UserDefaults.standard.data(forKey: WatchSettingsPersistence.configData),
           let c = try? JSONDecoder().decode(MatchConfiguration.self, from: d) {
            return c
        }
        return .default
    }

    private func applyIPhoneApplicationContext(_ applicationContext: [String: Any]) {
        guard let data = applicationContext[WCKeys.matchSettings] as? Data,
              let config = try? JSONDecoder().decode(MatchConfiguration.self, from: data) else { return }
        UserDefaults.standard.set(data, forKey: WatchSettingsPersistence.configData)
    }

    /// Callback z `WatchMatchViewModel` — reset zápasu z iPhonu.
    private var matchResetHandler: (() -> Void)?

    func setMatchResetHandler(_ handler: @escaping () -> Void) {
        matchResetHandler = handler
    }

    private func handlePhoneCommand(_ message: [String: Any]) {
        guard message[WCKeys.action] as? String == WCKeys.resetToIdle else { return }
        matchResetHandler?()
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
            applyIPhoneApplicationContext(session.receivedApplicationContext)
        }
    }

    nonisolated func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        Task { @MainActor in
            applyIPhoneApplicationContext(applicationContext)
        }
    }

    nonisolated func sessionReachabilityDidChange(_ session: WCSession) {
        Task { @MainActor in
            self.isReachable = session.isReachable
        }
    }

    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        Task { @MainActor in
            handlePhoneCommand(message)
            replyHandler(["ok": true])
        }
    }

    nonisolated func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any]) {
        Task { @MainActor in
            handlePhoneCommand(userInfo)
        }
    }
}
