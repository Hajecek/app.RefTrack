//
//  ContentView.swift
//  RefTrack Watch App
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var matchVM: WatchMatchViewModel
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        WatchMatchRootView()
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    matchVM.refreshFromForeground()
                }
            }
    }
}

#Preview {
    ContentView()
        .environmentObject(WatchMatchViewModel())
}
