//
//  WatchFinishedSummaryView.swift
//  RefTrack Watch App
//

import SwiftUI

struct WatchFinishedSummaryView: View {
    @EnvironmentObject private var vm: WatchMatchViewModel

    var body: some View {
        let s = vm.summary
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text("KONEC")
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity, alignment: .center)

                Group {
                    row("1. poločas celkem", MatchTimeFormat.formatDuration(s.totalFirstHalfSeconds))
                    row("Nastavení 1", MatchTimeFormat.formatDuration(s.firstStoppageSeconds))
                    row("Pauza", MatchTimeFormat.formatDuration(s.halftimeSeconds))
                    row("2. poločas celkem", MatchTimeFormat.formatDuration(s.totalSecondHalfSeconds))
                    row("Nastavení 2", MatchTimeFormat.formatDuration(s.secondStoppageSeconds))
                    row("Aktivita celkem", MatchTimeFormat.formatDuration(s.totalActivitySeconds))
                    row("Vzdálenost", MatchTimeFormat.formatDistanceMeters(s.distanceMeters))
                    if s.energyKilocalories > 0.5 {
                        row("Energie", String(format: "%.0f kcal", s.energyKilocalories))
                    }
                }
                .font(.caption2)

                Button {
                    vm.resetAfterFinished()
                } label: {
                    Text("Nový zápas")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .padding(.top, 6)
            }
            .padding(10)
        }
    }

    private func row(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer(minLength: 4)
            Text(value)
                .fontWeight(.semibold)
                .multilineTextAlignment(.trailing)
        }
    }
}
