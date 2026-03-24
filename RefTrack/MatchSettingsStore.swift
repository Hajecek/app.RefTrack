//
//  MatchSettingsStore.swift
//  RefTrack
//

import Combine
import Foundation

/// Lokální nastavení délek zápasu na iPhonu + odeslání na Apple Watch (sekundy).
@MainActor
final class MatchSettingsStore: ObservableObject {
    private enum Keys {
        static let halfSeconds = "reftrack.settings.halfSeconds"
        static let halftimeSeconds = "reftrack.settings.halftimeSeconds"
        static let halfMinutesLegacy = "reftrack.settings.halfMinutes"
        static let halftimeMinutesLegacy = "reftrack.settings.halftimeMinutes"
    }

    static let halfMinSeconds = 15
    static let halfMaxSeconds = 2 * 60 * 60
    static let halftimeMaxSeconds = 60 * 60

    @Published var halfLengthSeconds: Int {
        didSet {
            if isInternalMutation { return }
            let c = Self.clampHalf(halfLengthSeconds)
            if c != halfLengthSeconds {
                isInternalMutation = true
                halfLengthSeconds = c
                isInternalMutation = false
                return
            }
            persist()
            syncToWatch()
        }
    }

    @Published var halftimeSeconds: Int {
        didSet {
            if isInternalMutation { return }
            let c = Self.clampHalftime(halftimeSeconds)
            if c != halftimeSeconds {
                isInternalMutation = true
                halftimeSeconds = c
                isInternalMutation = false
                return
            }
            persist()
            syncToWatch()
        }
    }

    private var isInternalMutation = false

    var matchConfiguration: MatchConfiguration {
        MatchConfiguration(
            halfLengthSeconds: halfLengthSeconds,
            halftimeSeconds: halftimeSeconds
        )
    }

    private let defaults = UserDefaults.standard

    init() {
        let halfRaw: Int
        if let s = defaults.object(forKey: Keys.halfSeconds) as? Int {
            halfRaw = s
        } else if let m = defaults.object(forKey: Keys.halfMinutesLegacy) as? Int {
            halfRaw = m * 60
        } else {
            halfRaw = 45 * 60
        }

        let htRaw: Int
        if let s = defaults.object(forKey: Keys.halftimeSeconds) as? Int {
            htRaw = s
        } else if let m = defaults.object(forKey: Keys.halftimeMinutesLegacy) as? Int {
            htRaw = m * 60
        } else {
            htRaw = 15 * 60
        }

        self.halfLengthSeconds = Self.clampHalf(halfRaw)
        self.halftimeSeconds = Self.clampHalftime(htRaw)
        persist()
    }

    func applyStandardMatch() {
        halfLengthSeconds = 45 * 60
        halftimeSeconds = 15 * 60
    }

    func syncToWatch() {
        PhoneWCSession.shared.pushMatchSettings(configuration: matchConfiguration)
    }

    private func persist() {
        defaults.set(halfLengthSeconds, forKey: Keys.halfSeconds)
        defaults.set(halftimeSeconds, forKey: Keys.halftimeSeconds)
    }

    private static func clampHalf(_ s: Int) -> Int {
        min(max(s, halfMinSeconds), halfMaxSeconds)
    }

    private static func clampHalftime(_ s: Int) -> Int {
        min(max(s, 0), halftimeMaxSeconds)
    }
}
