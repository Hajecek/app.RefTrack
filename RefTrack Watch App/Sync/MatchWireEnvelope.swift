//
//  MatchWireEnvelope.swift
//  RefTrack Watch App
//
//  Kompletní stav pro WatchConnectivity — iPhone musí mít shodné typy (kopie v targetu RefTrack).
//

import Foundation

struct MatchWireEnvelope: Codable, Equatable, Sendable {
    var state: MatchEngineState
    var distanceMeters: Double
    var energyKilocalories: Double
    var sentAt: Date
}
