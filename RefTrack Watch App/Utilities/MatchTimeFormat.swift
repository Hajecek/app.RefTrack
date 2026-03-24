//
//  MatchTimeFormat.swift
//  RefTrack Watch App
//

import Foundation

enum MatchTimeFormat {
    static func mmss(_ totalSeconds: Int) -> String {
        let s = max(0, totalSeconds)
        let m = s / 60
        let sec = s % 60
        return String(format: "%02d:%02d", m, sec)
    }

    static func formatDistanceMeters(_ m: Double) -> String {
        if m >= 1000 {
            return String(format: "%.2f km", m / 1000)
        }
        return String(format: "%.0f m", m)
    }

    static func formatDuration(_ interval: TimeInterval) -> String {
        let sec = Int(interval.rounded())
        return mmss(sec)
    }
}
