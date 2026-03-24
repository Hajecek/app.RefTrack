//
//  WatchMatchRootView.swift
//  RefTrack Watch App
//

import SwiftUI

struct WatchMatchRootView: View {
    @EnvironmentObject private var vm: WatchMatchViewModel

    var body: some View {
        Group {
            switch vm.snapshot.phase {
            case .idle:
                WatchHomeIdleView()
            case .readyToStart:
                WatchBigStartView()
            case .firstHalfRunning, .firstHalfStoppageTime:
                WatchPlayingPhaseView(
                    accent: .blue,
                    phaseTitle: "1. poločas",
                    phaseSymbol: "1.circle.fill"
                )
            case .halftimeBreak:
                WatchHalftimeCountdownView()
            case .readyForSecondHalf:
                WatchSecondHalfGateView()
            case .secondHalfRunning, .secondHalfStoppageTime:
                WatchPlayingPhaseView(
                    accent: .green,
                    phaseTitle: "2. poločas",
                    phaseSymbol: "2.circle.fill"
                )
            case .finished:
                WatchFinishedSummaryView()
            }
        }
        .confirmationDialog(
            "Ukončit 1. poločas?",
            isPresented: $vm.showEndFirstHalfConfirm,
            titleVisibility: .visible
        ) {
            Button("Ano") { vm.confirmEndFirstHalf() }
            Button("Ne", role: .cancel) {}
        } message: {
            Text("Začne poločasová pauza.")
        }
        .confirmationDialog(
            "Ukončit pauzu?",
            isPresented: $vm.showHalftimeContinueConfirm,
            titleVisibility: .visible
        ) {
            Button("Ano, pokračovat") { vm.confirmHalftimeContinue() }
            Button("Ne", role: .cancel) {}
        } message: {
            Text("Přejdeš na obrazovku před 2. poločasem.")
        }
        .confirmationDialog(
            "Ukončit zápas?",
            isPresented: $vm.showEndMatchConfirm,
            titleVisibility: .visible
        ) {
            Button("Ano") { vm.confirmEndMatch() }
            Button("Ne", role: .cancel) {}
        } message: {
            Text("Uloží se aktivita a zobrazí shrnutí.")
        }
    }
}
