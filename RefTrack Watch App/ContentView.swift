//
//  ContentView.swift
//  RefTrack Watch App
//

import SwiftUI
import WatchConnectivity

struct ContentView: View {
    @ObservedObject private var watchSession = WatchWCSession.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("RefTrack")
                .font(.headline)
            Text("Stav: \(activationLabel(watchSession.activationState))")
            Text("iPhone v dosahu: \(watchSession.isReachable ? "ano" : "ne")")
                .font(.caption2)
                .foregroundStyle(.secondary)
            if let err = watchSession.lastActivationError {
                Text(err)
                    .font(.caption2)
                    .foregroundStyle(.red)
            }
        }
        .padding()
    }

    private func activationLabel(_ state: WCSessionActivationState) -> String {
        switch state {
        case .notActivated: return "neaktivní"
        case .inactive: return "neaktivní"
        case .activated: return "aktivní"
        @unknown default: return "neznámý"
        }
    }
}

#Preview {
    ContentView()
}
