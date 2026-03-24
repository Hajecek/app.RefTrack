//
//  RefTrackApp.swift
//  RefTrack
//

import SwiftUI

@main
struct RefTrackApp: App {
    @StateObject private var matchSettings = MatchSettingsStore()

    init() {
        PhoneWCSession.shared.activateIfNeeded()
    }

    var body: some Scene {
        WindowGroup {
            RootTabView(settings: matchSettings)
                .onReceive(NotificationCenter.default.publisher(for: .phoneWCSessionDidActivate)) { _ in
                    matchSettings.syncToWatch()
                }
        }
    }
}
