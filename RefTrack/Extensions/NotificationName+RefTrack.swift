//
//  NotificationName+RefTrack.swift
//  RefTrack
//

import Foundation

extension Notification.Name {
    /// WatchConnectivity na iPhonu dokončilo aktivaci — znovu odešli nastavení na hodinky.
    static let phoneWCSessionDidActivate = Notification.Name("reftrack.phoneWC.activated")
}
