//
//  WatchHalftimeCountdownView.swift
//  RefTrack Watch App
//

import SwiftUI

struct WatchHalftimeCountdownView: View {
    @EnvironmentObject private var vm: WatchMatchViewModel

    var body: some View {
        let snap = vm.snapshot

        ZStack {
            LinearGradient(
                colors: [
                    Color.purple.opacity(0.5),
                    Color.black.opacity(0.92),
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 0) {
                Label("Pauza", systemImage: "cup.and.saucer.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 10)

                Text(MatchTimeFormat.mmss(snap.halftimeRemainingSeconds))
                    .font(.system(size: 46, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.primary)
                    .minimumScaleFactor(0.35)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("Klepnutím ukončíš pauzu")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .padding(.top, 10)

                Spacer(minLength: 0)
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
