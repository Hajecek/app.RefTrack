//
//  MatchLiveView.swift
//  RefTrack
//

import SwiftUI
import WatchConnectivity

struct MatchLiveView: View {
    @ObservedObject var matchSettings: MatchSettingsStore
    @ObservedObject private var phoneSession = PhoneWCSession.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Pro nový zápas: \(MatchDurationFormat.shortSummary(halfSeconds: matchSettings.halfLengthSeconds, halftimeSeconds: matchSettings.halftimeSeconds))")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .padding(.bottom, 6)

            connectionStrip

            TimelineView(.periodic(from: .now, by: 0.5)) { timeline in
                PhoneMatchMirrorView(
                    envelope: phoneSession.lastMatchEnvelope,
                    now: timeline.date
                )
            }
        }
        .padding()
        .navigationTitle("Zápas")
        .navigationBarTitleDisplayMode(.large)
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
    NavigationStack {
        MatchLiveView(matchSettings: MatchSettingsStore())
    }
}
