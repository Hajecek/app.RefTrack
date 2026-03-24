//
//  RefTrackWatchApp.swift
//  RefTrack Watch App
//

import SwiftUI

@main
struct RefTrackWatchApp: App {
    init() {
        WatchWCSession.shared.activateIfNeeded()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
