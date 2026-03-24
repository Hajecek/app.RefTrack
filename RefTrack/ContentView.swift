//
//  ContentView.swift
//  RefTrack
//

import SwiftUI
import WatchConnectivity

struct ContentView: View {
    @ObservedObject private var phoneSession = PhoneWCSession.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("RefTrack")
                .font(.title2)
            Group {
                Text("Stav: \(activationLabel(phoneSession.activationState))")
                Text("Spárované hodinky: \(phoneSession.isPaired ? "ano" : "ne")")
                Text("Watch app nainstalovaná: \(phoneSession.isWatchAppInstalled ? "ano" : "ne")")
                Text("Dosah (obě app spuštěné): \(phoneSession.isReachable ? "ano" : "ne")")
                if let err = phoneSession.lastActivationError {
                    Text("Chyba: \(err)")
                        .foregroundStyle(.red)
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding()
    }

    private func activationLabel(_ state: WCSessionActivationState) -> String {
        switch state {
        case .notActivated: return "neaktivní"
        case .inactive: return "neaktivní (přechod)"
        case .activated: return "aktivní"
        @unknown default: return "neznámý"
        }
    }
}

#Preview {
    ContentView()
}
