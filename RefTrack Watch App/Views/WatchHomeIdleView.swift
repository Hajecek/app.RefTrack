//
//  WatchHomeIdleView.swift
//  RefTrack Watch App
//

import SwiftUI

struct WatchHomeIdleView: View {
    @EnvironmentObject private var vm: WatchMatchViewModel

    var body: some View {
        ZStack {
            // Barevné a "čistší" pozadí pro stav kdy není aktivní zápas.
            LinearGradient(
                colors: [
                    Color.green.opacity(0.22),
                    Color.mint.opacity(0.18),
                    Color.blue.opacity(0.16),
                    Color.black.opacity(0.92)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 14) {
                VStack(spacing: 6) {
                    Image(systemName: "sportscourt.fill")
                        .font(.title)
                        .foregroundStyle(.tint)
                        .symbolRenderingMode(.hierarchical)

                    Text("RefTrack")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 10)

                VStack(spacing: 10) {
                    Text("Začněte nový zápas.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    Button {
                        vm.beginNewMatchFlow()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                            Text("Nový zápas")
                                .font(.title3.bold())
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color.green.opacity(0.95),
                                    Color.mint.opacity(0.95)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .shadow(color: Color.green.opacity(0.35), radius: 10, x: 0, y: 4)
                    }
                    .buttonStyle(.plain)
                }
                .padding(12)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .padding(10)
        }
    }
}
