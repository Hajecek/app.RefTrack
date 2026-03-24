//
//  RefTrackMatchAttributes.swift
//  RefTrackLiveActivity
//
//  Musí být shodné s kopií v hlavní aplikaci RefTrack.
//

import ActivityKit
import Foundation

struct RefTrackMatchAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable, Sendable {
        public var headline: String
        public var primaryTime: String
        public var secondaryLine: String?
        public var halftimeCountdownStart: Date?
        public var halftimeCountdownEnd: Date?

        public init(
            headline: String,
            primaryTime: String,
            secondaryLine: String?,
            halftimeCountdownStart: Date?,
            halftimeCountdownEnd: Date?
        ) {
            self.headline = headline
            self.primaryTime = primaryTime
            self.secondaryLine = secondaryLine
            self.halftimeCountdownStart = halftimeCountdownStart
            self.halftimeCountdownEnd = halftimeCountdownEnd
        }
    }
}
