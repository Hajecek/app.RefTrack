//
//  RefTrackWatchAppUITests.swift
//  RefTrack Watch AppUITests
//

import XCTest

final class RefTrackWatchAppUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testExample() throws {
        let app = XCUIApplication()
        app.launch()
    }
}
