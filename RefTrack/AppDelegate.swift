//
//  AppDelegate.swift
//  RefTrack
//
//  Created by Michal Hájek on 20.03.2025.
//

import WatchConnectivity

class WatchManager: NSObject, WCSessionDelegate {
    static let shared = WatchManager()
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    func sendMessageToWatch(_ message: [String: Any]) {
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(message, replyHandler: nil, errorHandler: nil)
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("Received from Watch: \(message)")
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation failed with error: \(error.localizedDescription)")
        } else {
            print("WCSession activated with state: \(activationState.rawValue)")
        }
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        // Reaktivace session po deaktivaci
        WCSession.default.activate()
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("Session became inactive")
    }
}
