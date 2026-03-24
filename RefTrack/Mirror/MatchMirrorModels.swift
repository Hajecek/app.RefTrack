//
//  MatchMirrorModels.swift
//  RefTrack
//
//  Shodná Codable schémata jako na hodinkách — pro dekódování stavu z WatchConnectivity.
//

import Foundation

enum MatchPhase: String, Codable, CaseIterable, Sendable {
    case idle
    case readyToStart
    case firstHalfRunning
    case firstHalfStoppageTime
    case halftimeBreak
    case readyForSecondHalf
    case secondHalfRunning
    case secondHalfStoppageTime
    case finished
}

struct MatchConfiguration: Codable, Equatable, Sendable {
    var halfLengthSeconds: Int
    var halftimeSeconds: Int
}

struct MatchEngineState: Codable, Equatable, Sendable {
    var phase: MatchPhase
    var config: MatchConfiguration

    var firstHalfStartedAt: Date?
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
}

struct MatchDisplaySnapshot: Equatable, Sendable {
    var phase: MatchPhase
    var mainClockSeconds: Int
    var mainClockFrozenAtRegulationEnd: Bool
    var stoppageSeconds: Int
    var isStoppageActive: Bool
    var halftimeRemainingSeconds: Int
    var canShowHalftimeContinueDialog: Bool
    var distanceMeters: Double
    var energyKilocalories: Double
}

struct MatchWireEnvelope: Codable, Equatable, Sendable {
    var state: MatchEngineState
    var distanceMeters: Double
    var energyKilocalories: Double
    var sentAt: Date
}

struct MatchSummary: Equatable, Sendable {
    var totalFirstHalfSeconds: TimeInterval
    var firstStoppageSeconds: TimeInterval
    var halftimeSeconds: TimeInterval
    var totalSecondHalfSeconds: TimeInterval
    var secondStoppageSeconds: TimeInterval
    var totalActivitySeconds: TimeInterval
    var distanceMeters: Double
    var energyKilocalories: Double

    static func from(
        state: MatchEngineState,
        distanceMeters: Double,
        energyKilocalories: Double
    ) -> MatchSummary {
        let totalFirst = interval(state.firstHalfStartedAt, state.firstStoppageEndedAt)
        let firstStop = interval(state.firstStoppageStartedAt, state.firstStoppageEndedAt)
        let ht = interval(state.halftimeStartedAt, state.halftimeEndedAt)
        let totalSecond = interval(state.secondHalfStartedAt, state.secondStoppageEndedAt)
        let secondStop = interval(state.secondStoppageStartedAt, state.secondStoppageEndedAt)
        let totalAct = interval(state.firstHalfStartedAt, state.finishedAt ?? state.secondStoppageEndedAt)

        return MatchSummary(
            totalFirstHalfSeconds: totalFirst,
            firstStoppageSeconds: firstStop,
            halftimeSeconds: ht,
            totalSecondHalfSeconds: totalSecond,
            secondStoppageSeconds: secondStop,
            totalActivitySeconds: totalAct,
            distanceMeters: distanceMeters,
            energyKilocalories: energyKilocalories
        )
    }

    private static func interval(_ a: Date?, _ b: Date?) -> TimeInterval {
        guard let a, let b else { return 0 }
        return max(0, b.timeIntervalSince(a))
    }
}
