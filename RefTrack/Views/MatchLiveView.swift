//
//  MatchLiveView.swift
//  RefTrack
//

import SwiftUI

struct MatchLiveView: View {
    @ObservedObject private var phone = PhoneWCSession.shared

    @State private var showResetConfirm = false
    @State private var isResetting = false
    @State private var toastMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                TimelineView(.periodic(from: .now, by: 0.5)) { timeline in
                    clockContent(now: timeline.date)
                }
            }
            .navigationTitle("RefTrack")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Label(
                            phone.isReachable ? "Hodinky v dosahu" : "Hodinky mimo dosah",
                            systemImage: phone.isReachable ? "applewatch.radiowaves.left.and.right" : "applewatch.slash"
                        )
                        Label(
                            phone.isPaired ? "Spárováno" : "Nespárováno",
                            systemImage: phone.isPaired ? "checkmark.circle" : "xmark.circle"
                        )
                        if let err = phone.lastActivationError {
                            Text(err)
                        }
                    } label: {
                        Image(systemName: "info.circle")
                    }
                    .accessibilityLabel("Stav spojení")
                }
            }
            .confirmationDialog(
                "Vrátit časomíru do výchozího stavu?",
                isPresented: $showResetConfirm,
                titleVisibility: .visible
            ) {
                Button("Resetovat", role: .destructive) {
                    runReset()
                }
                Button("Zrušit", role: .cancel) {}
            } message: {
                Text("Na Apple Watch se ukončí případný zápas a aplikace se vrátí na začátek.")
            }
            .overlay(alignment: .top) {
                if let toastMessage {
                    Text(toastMessage)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(.black.opacity(0.78), in: Capsule())
                        .padding(.top, 8)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.32, dampingFraction: 0.84), value: toastMessage)
        }
    }

    @ViewBuilder
    private func clockContent(now: Date) -> some View {
        let model = Self.displayModel(envelope: phone.lastMatchEnvelope, now: now)

        VStack(spacing: 0) {
            Spacer(minLength: 24)

            Text(model.phaseLine)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            Text(model.mainClock)
                .font(.system(size: 80, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.primary)
                .minimumScaleFactor(0.25)
                .lineLimit(1)
                .padding(.top, 12)
                .padding(.horizontal, 12)

            if let second = model.secondaryLine {
                Text(second)
                    .font(.title3.weight(.semibold))
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)
            }

            if let third = model.tertiaryLine {
                Text(third)
                    .font(.footnote)
                    .foregroundStyle(.tertiary)
                    .padding(.top, 6)
            }

            Spacer(minLength: 24)

            Button {
                showResetConfirm = true
            } label: {
                Label("Reset časomíry", systemImage: "arrow.counterclockwise.circle.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(.systemGray4))
            .foregroundStyle(.primary)
            .disabled(isResetting)
            .padding(.horizontal, 24)
            .padding(.bottom, 28)
        }
    }

    private func runReset() {
        isResetting = true
        phone.sendResetMatchToWatch { result in
            isResetting = false
            switch result {
            case .success(let hint):
                if let hint {
                    showToast(hint)
                }
            case .failure(let error):
                showToast(error.localizedDescription)
            }
        }
    }

    private func showToast(_ text: String) {
        toastMessage = text
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            toastMessage = nil
        }
    }

    private struct DisplayModel {
        let phaseLine: String
        let mainClock: String
        let secondaryLine: String?
        let tertiaryLine: String?
    }

    private static func displayModel(envelope: MatchWireEnvelope?, now: Date) -> DisplayModel {
        guard let envelope else {
            return DisplayModel(
                phaseLine: "Čeká na Apple Watch",
                mainClock: "00:00",
                secondaryLine: nil,
                tertiaryLine: "Spusť zápas na hodinkách"
            )
        }

        let snap = MatchMirrorDisplayFormatter.snapshot(
            state: envelope.state,
            at: now,
            distanceMeters: envelope.distanceMeters,
            energyKilocalories: envelope.energyKilocalories
        )

        let main = MatchMirrorTimeFormat.mmss(
            snap.phase == .halftimeBreak ? snap.halftimeRemainingSeconds : snap.mainClockSeconds
        )

        var second: String?
        if snap.isStoppageActive {
            second = "Nastavení \(MatchMirrorTimeFormat.mmss(snap.stoppageSeconds))"
        } else if snap.phase == .halftimeBreak {
            second = "Poločasová pauza"
        }

        var third: String? = MatchMirrorTimeFormat.formatDistanceMeters(snap.distanceMeters)
        if snap.phase == .idle, snap.distanceMeters < 1 {
            third = nil
        }
        if snap.phase == .finished {
            third = "Zápas ukončen · \(MatchMirrorTimeFormat.formatDistanceMeters(snap.distanceMeters))"
        }

        return DisplayModel(
            phaseLine: phaseTitle(snap.phase),
            mainClock: main,
            secondaryLine: second,
            tertiaryLine: third
        )
    }

    private static func phaseTitle(_ p: MatchPhase) -> String {
        switch p {
        case .idle: return "Nečinnost"
        case .readyToStart: return "Připraveno ke startu"
        case .firstHalfRunning: return "1. poločas"
        case .firstHalfStoppageTime: return "1. poločas · nastavení"
        case .halftimeBreak: return "Pauza"
        case .readyForSecondHalf: return "Před 2. poločasem"
        case .secondHalfRunning: return "2. poločas"
        case .secondHalfStoppageTime: return "2. poločas · nastavení"
        case .finished: return "Konec zápasu"
        }
    }
}

#Preview {
    MatchLiveView()
}
