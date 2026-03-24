//
//  WatchHaptics.swift
//  RefTrack Watch App
//

import WatchKit

enum WatchHaptics {
    /// Konec řádné hrací doby / důležitý milník.
    static func regulationEnd() {
        WKInterfaceDevice.current().play(.notification)
    }

    /// Pauza doběhla na nulu.
    static func halftimeDone() {
        WKInterfaceDevice.current().play(.success)
    }

    /// Potvrzovací dialog / lehká odezva.
    static func confirmPrompt() {
        WKInterfaceDevice.current().play(.click)
    }
}
