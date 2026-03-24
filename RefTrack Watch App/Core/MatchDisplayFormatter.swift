//
//  MatchDisplayFormatter.swift
//  RefTrack Watch App
//
//  Čistá funkce odvození UI z kotev — použitelná i na iPhonu (kopie souboru).
//

import Foundation

enum MatchDisplayFormatter {
    static func snapshot(
        state: MatchEngineState,
        at now: Date,
        distanceMeters: Double,
        energyKilocalories: Double
    ) -> MatchDisplaySnapshot {
        let cfg = state.config
        let half = cfg.halfLengthSeconds

        switch state.phase {
        case .idle, .readyToStart:
            return MatchDisplaySnapshot(
                phase: state.phase,
                mainClockSeconds: 0,
                mainClockFrozenAtRegulationEnd: false,
                stoppageSeconds: 0,
                isStoppageActive: false,
                halftimeRemainingSeconds: cfg.halftimeSeconds,
                canShowHalftimeContinueDialog: false,
                distanceMeters: distanceMeters,
                energyKilocalories: energyKilocalories
            )

        case .firstHalfRunning:
            let elapsed = secondsSince(state.firstHalfStartedAt, to: now)
            let main = min(max(elapsed, 0), half)
            return MatchDisplaySnapshot(
                phase: state.phase,
                mainClockSeconds: main,
                mainClockFrozenAtRegulationEnd: false,
                stoppageSeconds: 0,
                isStoppageActive: false,
                halftimeRemainingSeconds: cfg.halftimeSeconds,
                canShowHalftimeContinueDialog: false,
                distanceMeters: distanceMeters,
                energyKilocalories: energyKilocalories
            )

        case .firstHalfStoppageTime:
            let stopStart = state.firstStoppageStartedAt ?? now
            let st = max(0, Int(now.timeIntervalSince(stopStart).rounded(.down)))
            return MatchDisplaySnapshot(
                phase: state.phase,
                mainClockSeconds: half,
                mainClockFrozenAtRegulationEnd: true,
                stoppageSeconds: st,
                isStoppageActive: true,
                halftimeRemainingSeconds: cfg.halftimeSeconds,
                canShowHalftimeContinueDialog: false,
                distanceMeters: distanceMeters,
                energyKilocalories: energyKilocalories
            )

        case .halftimeBreak:
            let hs = state.halftimeStartedAt ?? now
            let elapsedHt = Int(now.timeIntervalSince(hs).rounded(.down))
            let remaining = max(0, cfg.halftimeSeconds - elapsedHt)
            return MatchDisplaySnapshot(
                phase: state.phase,
                mainClockSeconds: half,
                mainClockFrozenAtRegulationEnd: true,
                stoppageSeconds: 0,
                isStoppageActive: false,
                halftimeRemainingSeconds: remaining,
                canShowHalftimeContinueDialog: remaining <= 0,
                distanceMeters: distanceMeters,
                energyKilocalories: energyKilocalories
            )

        case .readyForSecondHalf:
            return MatchDisplaySnapshot(
                phase: state.phase,
                mainClockSeconds: half,
                mainClockFrozenAtRegulationEnd: true,
                stoppageSeconds: 0,
                isStoppageActive: false,
                halftimeRemainingSeconds: 0,
                canShowHalftimeContinueDialog: false,
                distanceMeters: distanceMeters,
                energyKilocalories: energyKilocalories
            )

        case .secondHalfRunning:
            let elapsed = secondsSince(state.secondHalfStartedAt, to: now)
            let main = min(max(half + elapsed, half), half * 2)
            return MatchDisplaySnapshot(
                phase: state.phase,
                mainClockSeconds: main,
                mainClockFrozenAtRegulationEnd: false,
                stoppageSeconds: 0,
                isStoppageActive: false,
                halftimeRemainingSeconds: 0,
                canShowHalftimeContinueDialog: false,
                distanceMeters: distanceMeters,
                energyKilocalories: energyKilocalories
            )

        case .secondHalfStoppageTime:
            let stopStart = state.secondStoppageStartedAt ?? now
            let st = max(0, Int(now.timeIntervalSince(stopStart).rounded(.down)))
            return MatchDisplaySnapshot(
                phase: state.phase,
                mainClockSeconds: half * 2,
                mainClockFrozenAtRegulationEnd: true,
                stoppageSeconds: st,
                isStoppageActive: true,
                halftimeRemainingSeconds: 0,
                canShowHalftimeContinueDialog: false,
                distanceMeters: distanceMeters,
                energyKilocalories: energyKilocalories
            )

        case .finished:
            return MatchDisplaySnapshot(
                phase: state.phase,
                mainClockSeconds: half * 2,
                mainClockFrozenAtRegulationEnd: true,
                stoppageSeconds: 0,
                isStoppageActive: false,
                halftimeRemainingSeconds: 0,
                canShowHalftimeContinueDialog: false,
                distanceMeters: distanceMeters,
                energyKilocalories: energyKilocalories
            )
        }
    }

    private static func secondsSince(_ start: Date?, to end: Date) -> Int {
        guard let start else { return 0 }
        return max(0, Int(end.timeIntervalSince(start).rounded(.down)))
    }
}
