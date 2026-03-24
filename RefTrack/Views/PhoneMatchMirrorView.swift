//
//  PhoneMatchMirrorView.swift
//  RefTrack
//

import SwiftUI

struct PhoneMatchMirrorView: View {
    var envelope: MatchWireEnvelope?
    var now: Date

    var body: some View {
        Group {
            if let envelope {
                let snap = MatchMirrorDisplayFormatter.snapshot(
                    state: envelope.state,
                    at: now,
                    distanceMeters: envelope.distanceMeters,
                    energyKilocalories: envelope.energyKilocalories
                )
                mirrorContent(snap: snap, envelope: envelope)
            } else {
                ContentUnavailableView(
                    "Žádná data ze zápasu",
                    systemImage: "applewatch",
                    description: Text("Spusť zápas na Apple Watch — stav se zobrazí zde.")
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    @ViewBuilder
    private func mirrorContent(snap: MatchDisplaySnapshot, envelope: MatchWireEnvelope) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(phaseTitle(snap.phase))
                .font(.headline)

            Text(MatchMirrorTimeFormat.mmss(
                snap.phase == .halftimeBreak ? snap.halftimeRemainingSeconds : snap.mainClockSeconds
            ))
            .font(.system(size: 44, weight: .bold, design: .rounded))
            .monospacedDigit()

            if snap.isStoppageActive {
                Text("Nastavení: \(MatchMirrorTimeFormat.mmss(snap.stoppageSeconds))")
                    .font(.subheadline.weight(.semibold))
            }

            if snap.phase == .halftimeBreak {
                Text("Poločasová pauza")
                    .foregroundStyle(.secondary)
            }

            Text("Vzdálenost: \(MatchMirrorTimeFormat.formatDistanceMeters(snap.distanceMeters))")
                .font(.caption)
                .foregroundStyle(.secondary)

            if snap.phase == .finished {
                let summary = MatchSummary.from(
                    state: envelope.state,
                    distanceMeters: envelope.distanceMeters,
                    energyKilocalories: envelope.energyKilocalories
                )
                Divider().padding(.vertical, 4)
                Text("Shrnutí")
                    .font(.subheadline.bold())
                VStack(alignment: .leading, spacing: 4) {
                    summaryRow("1. poločas", MatchMirrorTimeFormat.formatDuration(summary.totalFirstHalfSeconds))
                    summaryRow("Nastavení 1", MatchMirrorTimeFormat.formatDuration(summary.firstStoppageSeconds))
                    summaryRow("Pauza", MatchMirrorTimeFormat.formatDuration(summary.halftimeSeconds))
                    summaryRow("2. poločas", MatchMirrorTimeFormat.formatDuration(summary.totalSecondHalfSeconds))
                    summaryRow("Nastavení 2", MatchMirrorTimeFormat.formatDuration(summary.secondStoppageSeconds))
                }
                .font(.caption)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func phaseTitle(_ p: MatchPhase) -> String {
        switch p {
        case .idle: return "Nečinnost"
        case .readyToStart: return "Připraveno ke startu"
        case .firstHalfRunning: return "1. poločas — hra"
        case .firstHalfStoppageTime: return "1. poločas — nastavení"
        case .halftimeBreak: return "Poločas"
        case .readyForSecondHalf: return "Před 2. poločasem"
        case .secondHalfRunning: return "2. poločas — hra"
        case .secondHalfStoppageTime: return "2. poločas — nastavení"
        case .finished: return "Zápas ukončen"
        }
    }

    private func summaryRow(_ t: String, _ v: String) -> some View {
        HStack {
            Text(t)
            Spacer()
            Text(v).fontWeight(.medium)
        }
    }
}
