//
//  MatchLiveActivityAttributes.swift
//  RefTrack
//
//  Kopie musí odpovídat RefTrackLiveActivity/RefTrackMatchAttributes.swift
//

import ActivityKit
import Foundation

struct RefTrackMatchAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable, Sendable {
        public var headline: String
        public var engineState: MatchEngineState
        public var distanceMeters: Double
        public var energyKilocalories: Double

        public init(
            headline: String,
            engineState: MatchEngineState,
            distanceMeters: Double,
            energyKilocalories: Double
        ) {
            self.headline = headline
            self.engineState = engineState
            self.distanceMeters = distanceMeters
            self.energyKilocalories = energyKilocalories
        }
    }
}
