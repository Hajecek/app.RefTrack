//
//  MatchDisplaySnapshot.swift
//  RefTrack Watch App
//

import Foundation

/// Odvozené hodnoty pro UI (počítá se z `MatchEngineState` + aktuálního času).
struct MatchDisplaySnapshot: Equatable, Sendable {
    var phase: MatchPhase

    /// Hlavní čas jako sekundy od začátku „zápasového“ času v dané fázi (0–45*60 v 1P, 45*60–90*60 ve 2P).
    var mainClockSeconds: Int
    var mainClockFrozenAtRegulationEnd: Bool

    var stoppageSeconds: Int
    var isStoppageActive: Bool

    var halftimeRemainingSeconds: Int
    var canShowHalftimeContinueDialog: Bool

    var distanceMeters: Double
    var energyKilocalories: Double
}
