//
//  RefTrackWatchApp.swift
//  RefTrack Watch App
//

import SwiftUI

@main
struct RefTrackWatchApp: App {
    @StateObject private var matchVM = WatchMatchViewModel()

    init() {
        WatchWCSession.shared.activateIfNeeded()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(matchVM)
        }
    }
}
