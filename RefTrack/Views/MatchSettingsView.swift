//
//  MatchSettingsView.swift
//  RefTrack
//

import SwiftUI

struct MatchSettingsView: View {
    @ObservedObject var settings: MatchSettingsStore

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Text(MatchDurationFormat.describe(seconds: settings.halfLengthSeconds))
                        .font(.title2.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 4)

                    IOSDurationWheelPickers(
                        totalSeconds: $settings.halfLengthSeconds,
                        minTotal: MatchSettingsStore.halfMinSeconds,
                        maxTotal: MatchSettingsStore.halfMaxSeconds
                    )
                }
                .listRowInsets(EdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0))
            } header: {
                Text("Délka jednoho poločasu")
            } footer: {
                Text("Otáčej kolečky jako v aplikaci Časovač. Minimum \(MatchSettingsStore.halfMinSeconds) s, maximum 2 hod.")
            }

            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Text(MatchDurationFormat.describe(seconds: settings.halftimeSeconds))
                        .font(.title2.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 4)

                    IOSDurationWheelPickers(
                        totalSeconds: $settings.halftimeSeconds,
                        minTotal: 0,
                        maxTotal: MatchSettingsStore.halftimeMaxSeconds
                    )
                }
                .listRowInsets(EdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0))
            } header: {
                Text("Poločasová pauza")
            } footer: {
                Text("0 min 00 s = žádná pauza. Hodnoty se odešlou na Apple Watch při novém zápase.")
            }

            Section {
                LabeledContent("Jeden poločas", value: MatchDurationFormat.describe(seconds: settings.halfLengthSeconds))
                LabeledContent("Celkem hra (2×)", value: MatchDurationFormat.describe(seconds: settings.halfLengthSeconds * 2))
                LabeledContent("Pauza", value: MatchDurationFormat.describe(seconds: settings.halftimeSeconds))
            } header: {
                Text("Souhrn")
            }
        }
        .navigationTitle("Nastavení")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Menu {
                    Button("Standardní zápas (45 / 15)") {
                        settings.applyStandardMatch()
                    }
                    Button("Krátký test (1 min / 0)") {
                        settings.halfLengthSeconds = 60
                        settings.halftimeSeconds = 0
                    }
                    Button("Půl min / bez pauzy") {
                        settings.halfLengthSeconds = 30
                        settings.halftimeSeconds = 0
                    }
                } label: {
                    Label("Předvolby", systemImage: "clock.arrow.circlepath")
                }
            }
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
