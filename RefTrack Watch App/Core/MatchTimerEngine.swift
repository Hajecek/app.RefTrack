//
//  MatchTimerEngine.swift
//  RefTrack Watch App
//
//  Časování výhradně z rozdílů Date — odolné vůči pozastavení aplikace.
//

import Combine
import Foundation

@MainActor
final class MatchTimerEngine: ObservableObject {
    @Published private(set) var state: MatchEngineState
    @Published private(set) var displayNow: Date

    private var tick: AnyCancellable?

    init(initial: MatchEngineState = .initial) {
        self.state = initial
        self.displayNow = Date()
        startTicking()
    }

    private func startTicking() {
        tick = Timer.publish(every: 0.5, tolerance: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.refreshNow()
            }
    }

    /// Po návratu na popředí — okamžitě přepočte čas bez čekání na další tik.
    func refreshNow() {
        let now = Date()
        displayNow = now
        applyAutomaticTransitions(now: now)
    }

    // MARK: - Veřejné akce

    /// `matchConfiguration` z iPhonu / výchozí z hodinek — platí pro nadcházející zápas.
    func beginNewMatchFlow(matchConfiguration: MatchConfiguration) {
        guard state.phase == .idle || state.phase == .finished else { return }
        state = .initial
        state.config = matchConfiguration
        state.phase = .readyToStart
    }

    func startFirstHalf(now: Date = Date()) {
        guard state.phase == .readyToStart else { return }
        state.firstHalfStartedAt = now
        state.phase = .firstHalfRunning
    }

    /// Uživatel potvrdil konec 1. poločasu — během hry i během nastavení.
    func confirmEndFirstHalf(now: Date = Date()) {
        switch state.phase {
        case .firstHalfRunning:
            state.firstHalfRegulationEndedAt = now
            state.firstStoppageStartedAt = now
            state.firstStoppageEndedAt = now
            state.halftimeStartedAt = now
            state.phase = .halftimeBreak
        case .firstHalfStoppageTime:
            state.firstStoppageEndedAt = now
            state.halftimeStartedAt = now
            state.phase = .halftimeBreak
        default:
            break
        }
    }

    /// Po doběhnutí pauzy a dialogu.
    func confirmContinueToSecondHalf(now: Date = Date()) {
        guard state.phase == .halftimeBreak else { return }
        state.halftimeEndedAt = now
        state.phase = .readyForSecondHalf
    }

    func startSecondHalf(now: Date = Date()) {
        guard state.phase == .readyForSecondHalf else { return }
        state.secondHalfStartedAt = now
        state.phase = .secondHalfRunning
    }

    /// Uživatel ukončil zápas — ve 2. poločasu i v nastavení.
    func confirmEndMatch(now: Date = Date()) {
        switch state.phase {
        case .secondHalfRunning:
            state.secondHalfRegulationEndedAt = now
            state.secondStoppageStartedAt = now
            state.secondStoppageEndedAt = now
            state.finishedAt = now
            state.phase = .finished
        case .secondHalfStoppageTime:
            state.secondStoppageEndedAt = now
            state.finishedAt = now
            state.phase = .finished
        default:
            break
        }
    }

    func resetToIdle() {
        state = .initial
    }

    // MARK: - Automatické přechody

    private func applyAutomaticTransitions(now: Date) {
        let cfg = state.config

        switch state.phase {
        case .firstHalfRunning:
            guard let start = state.firstHalfStartedAt else { return }
            let regulationEnd = start.addingTimeInterval(TimeInterval(cfg.halfLengthSeconds))
            if now >= regulationEnd {
                state.firstHalfRegulationEndedAt = regulationEnd
                state.firstStoppageStartedAt = regulationEnd
                state.phase = .firstHalfStoppageTime
            }

        case .secondHalfRunning:
            guard let start = state.secondHalfStartedAt else { return }
            let regulationEnd = start.addingTimeInterval(TimeInterval(cfg.halfLengthSeconds))
            if now >= regulationEnd {
                state.secondHalfRegulationEndedAt = regulationEnd
                state.secondStoppageStartedAt = regulationEnd
                state.phase = .secondHalfStoppageTime
            }

        default:
            break
        }
    }

    // MARK: - Snapshot pro UI / iPhone

    func displaySnapshot(
        at now: Date,
        distanceMeters: Double,
        energyKilocalories: Double
    ) -> MatchDisplaySnapshot {
        MatchDisplayFormatter.snapshot(
            state: state,
            at: now,
            distanceMeters: distanceMeters,
            energyKilocalories: energyKilocalories
        )
    }

    func matchSummary(distanceMeters: Double, energyKilocalories: Double) -> MatchSummary {
        MatchSummary.from(state: state, distanceMeters: distanceMeters, energyKilocalories: energyKilocalories)
    }
}
