//
//  MatchSettingsView.swift
//  RefTrack
//

import SwiftUI

struct MatchSettingsView: View {
    @ObservedObject var settings: MatchSettingsStore

    var body: some View {
        List {
            Section {
                NavigationLink {
                    MatchDurationEditorView(
                        navigationTitle: "Délka poločasu",
                        footerText: "Nastavení platí pro nový zápas na Apple Watch. Minimum \(MatchSettingsStore.halfMinSeconds) s, maximum 2 hodiny.",
                        totalSeconds: $settings.halfLengthSeconds,
                        minTotal: MatchSettingsStore.halfMinSeconds,
                        maxTotal: MatchSettingsStore.halfMaxSeconds
                    )
                } label: {
                    LabeledContent("Délka poločasu") {
                        Text(MatchDurationFormat.describe(seconds: settings.halfLengthSeconds))
                            .foregroundStyle(.secondary)
                    }
                }

                NavigationLink {
                    MatchDurationEditorView(
                        navigationTitle: "Poločasová pauza",
                        footerText: "0 min 00 s znamená žádnou pauzu mezi poločasy.",
                        totalSeconds: $settings.halftimeSeconds,
                        minTotal: 0,
                        maxTotal: MatchSettingsStore.halftimeMaxSeconds
                    )
                } label: {
                    LabeledContent("Pauza mezi poločasy") {
                        Text(MatchDurationFormat.describe(seconds: settings.halftimeSeconds))
                            .foregroundStyle(.secondary)
                    }
                }
            } header: {
                Text("Časy zápasu")
            }

            Section {
                Button {
                    settings.applyStandardMatch()
                } label: {
                    Label("Standardní zápas · 45 + 15 min", systemImage: "sportscourt.fill")
                }

                Button {
                    settings.halfLengthSeconds = 60
                    settings.halftimeSeconds = 0
                } label: {
                    Label("Krátký test · 1 min / bez pauzy", systemImage: "flame.fill")
                }

                Button {
                    settings.halfLengthSeconds = 30
                    settings.halftimeSeconds = 0
                } label: {
                    Label("Velmi krátký · 30 s / bez pauzy", systemImage: "hare.fill")
                }
            } header: {
                Text("Předvolby")
            }

            Section {
                LabeledContent("Jeden poločas", value: MatchDurationFormat.describe(seconds: settings.halfLengthSeconds))
                LabeledContent("Celková hra", value: MatchDurationFormat.describe(seconds: settings.halfLengthSeconds * 2))
                LabeledContent("Pauza", value: MatchDurationFormat.describe(seconds: settings.halftimeSeconds))
            } header: {
                Text("Souhrn")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Nastavení")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    settings.syncToWatch()
                } label: {
                    Label("Odeslat na Watch", systemImage: "applewatch.and.arrow.forward")
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        MatchSettingsView(settings: MatchSettingsStore())
    }
}
