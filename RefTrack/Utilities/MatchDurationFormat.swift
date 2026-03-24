//
//  MatchDurationFormat.swift
//  RefTrack
//

import Foundation

enum MatchDurationFormat {
    /// Čitelný popis pro nastavení (např. „1 min 30 s“, „45 min“).
    static func describe(seconds: Int) -> String {
        let s = max(0, seconds)
        if s < 60 {
            return "\(s) s"
        }
        let m = s / 60
        let rem = s % 60
        if rem == 0 {
            return "\(m) min"
        }
        return "\(m) min \(rem) s"
    }

    /// Krátký řetězec do záhlaví zápasu.
    static func shortSummary(halfSeconds: Int, halftimeSeconds: Int) -> String {
        "poločas \(describe(seconds: halfSeconds)) · pauza \(describe(seconds: halftimeSeconds))"
    }
}
