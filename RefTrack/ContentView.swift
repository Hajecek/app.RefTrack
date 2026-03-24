//
//  ContentView.swift
//  RefTrack
//

import SwiftUI
import WatchConnectivity

struct ContentView: View {
    @ObservedObject private var phoneSession = PhoneWCSession.shared

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                connectionStrip

                TimelineView(.periodic(from: .now, by: 0.5)) { timeline in
                    PhoneMatchMirrorView(
                        envelope: phoneSession.lastMatchEnvelope,
                        now: timeline.date
                    )
                }
            }
            .padding()
            .navigationTitle("RefTrack")
        }
    }

    private var connectionStrip: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Spojení: \(activationLabel(phoneSession.activationState))")
            Text("Hodinky: \(phoneSession.isPaired ? "spárováno" : "ne") · App: \(phoneSession.isWatchAppInstalled ? "ano" : "ne")")
            if let err = phoneSession.lastActivationError {
                Text(err).font(.caption2).foregroundStyle(.red)
            }
        }
        .font(.caption2)
        .foregroundStyle(.secondary)
        .padding(.bottom, 8)
    }

    private func activationLabel(_ state: WCSessionActivationState) -> String {
        switch state {
        case .notActivated: return "neaktivní"
        case .inactive: return "přechod"
        case .activated: return "aktivní"
        @unknown default: return "neznámý"
        }
    }
}

#Preview {
    ContentView()
}
