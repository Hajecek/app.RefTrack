//
//  MatchConfiguration.swift
//  RefTrack Watch App
//

import Foundation

/// Konfigurace délek (výchozí: 45 min poločas, 15 min pauza). Rozšiřitelné do nastavení.
struct MatchConfiguration: Codable, Equatable, Sendable {
    var halfLengthSeconds: Int
    var halftimeSeconds: Int

    static let `default` = MatchConfiguration(
        halfLengthSeconds: 45 * 60,
        halftimeSeconds: 15 * 60
    )
}
