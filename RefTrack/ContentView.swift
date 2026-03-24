//
//  ContentView.swift
//  RefTrack
//

import SwiftUI

/// Kořen s TabBarem — ponecháno pro kompatibilitu s preview / případné odkazy v projektu.
struct ContentView: View {
    @ObservedObject var settings: MatchSettingsStore

    var body: some View {
        RootTabView(settings: settings)
    }
}

#Preview {
    ContentView(settings: MatchSettingsStore())
}
