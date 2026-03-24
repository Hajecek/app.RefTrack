//
//  RefTrackApp.swift
//  RefTrack
//

import SwiftUI

@main
struct RefTrackApp: App {
    init() {
        PhoneWCSession.shared.activateIfNeeded()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
