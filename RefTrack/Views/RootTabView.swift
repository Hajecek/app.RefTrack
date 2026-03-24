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
                MatchLiveView(matchSettings: settings)
            }
            .tabItem {
                Label("Zápas", systemImage: "sportscourt.fill")
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
