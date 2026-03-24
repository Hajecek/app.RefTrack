//
//  WatchPlayingPhaseView.swift
//  RefTrack Watch App
//

import SwiftUI

struct WatchPlayingPhaseView: View {
    var accent: Color
    var phaseTitle: String
    /// SF Symbol pro horní řádek (např. „1“ / „2“).
    var phaseSymbol: String

    @EnvironmentObject private var vm: WatchMatchViewModel

    var body: some View {
        let snap = vm.snapshot

        ZStack {
            LinearGradient(
                colors: [
                    accent.opacity(0.55),
                    Color.black.opacity(0.92),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 6) {
                    Image(systemName: phaseSymbol)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(phaseTitle)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 10)

                Text(MatchTimeFormat.mmss(snap.mainClockSeconds))
                    .font(.system(size: 46, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.primary)
                    .minimumScaleFactor(0.35)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if snap.isStoppageActive {
                    VStack(alignment: .leading, spacing: 4) {
                        Label("Nastavení", systemImage: "timer")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.secondary)
                        Text(MatchTimeFormat.mmss(snap.stoppageSeconds))
                            .font(.title2.bold().monospacedDigit())
                            .foregroundStyle(.primary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .padding(.top, 12)
                }

                Spacer(minLength: 8)

                HStack(spacing: 6) {
                    Image(systemName: "figure.run")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.tertiary)
                    Text(MatchTimeFormat.formatDistanceMeters(snap.distanceMeters))
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 16)
        }
        .contentShape(Rectangle())
        .ignoresSafeArea()
        .onTapGesture {
            vm.handlePlayfieldTap()
        }
    }
}
