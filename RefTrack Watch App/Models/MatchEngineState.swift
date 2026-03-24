//
//  MatchEngineState.swift
//  RefTrack Watch App
//

import Foundation

/// Kotvy v čase (wall clock) pro přesný výpočet po návratu z pozadí.
struct MatchEngineState: Codable, Equatable, Sendable {
    var phase: MatchPhase
    var config: MatchConfiguration

    var firstHalfStartedAt: Date?
    /// Teoretický okamžik ukončení řádné hrací doby 1. poločasu (start + 45 min).
    var firstHalfRegulationEndedAt: Date?
    var firstStoppageStartedAt: Date?
    var firstStoppageEndedAt: Date?

    var halftimeStartedAt: Date?
    var halftimeEndedAt: Date?

    var secondHalfStartedAt: Date?
    var secondHalfRegulationEndedAt: Date?
    var secondStoppageStartedAt: Date?
    var secondStoppageEndedAt: Date?

    var finishedAt: Date?

    static let initial = MatchEngineState(
        phase: .idle,
        config: .default,
        firstHalfStartedAt: nil,
        firstHalfRegulationEndedAt: nil,
        firstStoppageStartedAt: nil,
        firstStoppageEndedAt: nil,
        halftimeStartedAt: nil,
        halftimeEndedAt: nil,
        secondHalfStartedAt: nil,
        secondHalfRegulationEndedAt: nil,
        secondStoppageStartedAt: nil,
        secondStoppageEndedAt: nil,
        finishedAt: nil
    )
}
