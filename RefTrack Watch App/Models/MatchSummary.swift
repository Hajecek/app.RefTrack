//
//  MatchSummary.swift
//  RefTrack Watch App
//

import Foundation

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
        let t1Start = state.firstHalfStartedAt
        let t1End = state.firstStoppageEndedAt
        let totalFirst = interval(t1Start, t1End)

        let s1a = state.firstStoppageStartedAt
        let s1b = state.firstStoppageEndedAt
        let firstStop = interval(s1a, s1b)

        let hta = state.halftimeStartedAt
        let htb = state.halftimeEndedAt
        let ht = interval(hta, htb)

        let t2a = state.secondHalfStartedAt
        let t2b = state.secondStoppageEndedAt
        let totalSecond = interval(t2a, t2b)

        let s2a = state.secondStoppageStartedAt
        let s2b = state.secondStoppageEndedAt
        let secondStop = interval(s2a, s2b)

        let actStart = state.firstHalfStartedAt
        let actEnd = state.finishedAt ?? state.secondStoppageEndedAt
        let totalAct = interval(actStart, actEnd)

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
