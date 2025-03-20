//
//  ExtensionDelegate.swift
//  RefTrack
//
//  Created by Michal Hájek on 20.03.2025.
//

import WatchConnectivity

class WatchConnector: NSObject, WCSessionDelegate {
    static let shared = WatchConnector()

    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    func sendMessageToiPhone(_ message: [String: Any]) {
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(message, replyHandler: nil, errorHandler: nil)
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("Received from iPhone: \(message)")
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // Zpracování dokončení aktivace
    }
}
