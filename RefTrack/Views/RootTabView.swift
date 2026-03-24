//
//  RootTabView.swift
//  RefTrack
//

import SwiftUI

struct RootTabView: View {
    @ObservedObject var settings: MatchSettingsStore

    var body: some View {
        TabView {
            NavigationStack {
                MatchLiveView()
            }
            .tabItem {
                Label("Čas", systemImage: "timer")
            }

            NavigationStack {
                MatchSettingsView(settings: settings)
            }
            .tabItem {
                Label("Nastavení", systemImage: "gearshape.fill")
            }
        }
        .tint(.green)
    }
}

#Preview {
    RootTabView(settings: MatchSettingsStore())
}
