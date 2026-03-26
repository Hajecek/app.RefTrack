//
//  WatchPlayingPhaseView.swift
//  RefTrack Watch App
//

import SwiftUI

struct WatchPlayingPhaseView: View {
    var accent: Color
    var phaseTitle: String
    var phaseSymbol: String

    @EnvironmentObject private var vm: WatchMatchViewModel

    var body: some View {
        let snap = vm.snapshot
        let inStoppage = snap.isStoppageActive

        ZStack {
            LinearGradient(
                colors: inStoppage
                    ? [Color.orange.opacity(0.45), Color.black.opacity(0.94)]
                    : [accent.opacity(0.5), Color.black.opacity(0.94)],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(spacing: 0) {
                Spacer(minLength: 6)

                HStack(spacing: 5) {
                    Image(systemName: phaseSymbol)
                        .font(.caption2.weight(.semibold))
                    Text(phaseTitle)
                        .font(.caption.weight(.semibold))
                }
                .foregroundStyle(.white.opacity(0.72))

                if inStoppage {
                    VStack(spacing: 8) {
                        Text(MatchTimeFormat.mmss(snap.stoppageSeconds))
                            .font(.system(size: 56, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(.white)
                            .minimumScaleFactor(0.3)
                            .lineLimit(1)
                            .transition(.asymmetric(
                                insertion: .move(edge: .top).combined(with: .opacity),
                                removal: .move(edge: .bottom).combined(with: .opacity)
                            ))

                        stoppageAccessory(mainClockSeconds: snap.mainClockSeconds)
                    }
                    .padding(.top, 10)
                } else {
                    Text(MatchTimeFormat.mmss(snap.mainClockSeconds))
                        .font(.system(size: 52, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(.white)
                        .minimumScaleFactor(0.3)
                        .lineLimit(1)
                        .padding(.top, 10)
                        .transition(.asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .move(edge: .top).combined(with: .opacity)
                        ))
                }

                Spacer(minLength: 6)

                HStack(spacing: 5) {
                    Image(systemName: "figure.run")
                        .font(.caption2)
                    Text(MatchTimeFormat.formatDistanceMeters(snap.distanceMeters))
                        .font(.caption2)
                }
                .foregroundStyle(.white.opacity(0.55))
                .padding(.bottom, 4)
            }
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 10)
        }
        .contentShape(Rectangle())
        .ignoresSafeArea()
        .onTapGesture {
            vm.handlePlayfieldTap()
        }
        .animation(.easeInOut(duration: 0.28), value: inStoppage)
    }

    /// Během nastavení ukáže pod hlavním časem zastavený zápasový čas.
    private func stoppageAccessory(mainClockSeconds: Int) -> some View {
        VStack(spacing: 2) {
            Text("Zastaveno")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.white.opacity(0.62))
            Text(MatchTimeFormat.mmss(mainClockSeconds))
                .font(.title3.weight(.semibold))
                .monospacedDigit()
                .foregroundStyle(.white.opacity(0.9))
        }
    }
}
