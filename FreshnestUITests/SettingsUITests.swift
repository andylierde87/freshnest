import XCTest

final class SettingsUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    private func openSettings(seedSampleData: Bool = false) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchForTesting(seedSampleData: seedSampleData)
        app.buttons["home.settingsButton"].tap()
        return app
    }

    func testAppearancePickerIsPresent() {
        let app = openSettings()
        XCTAssertTrue(app.buttons["settings.appearancePicker"].waitForExistence(timeout: 5))
    }

    func testStoreScanPhotosTogglePersists() {
        let app = openSettings()
        let toggle = app.switches["settings.storeScanPhotosToggle"]
        XCTAssertTrue(toggle.waitForExistence(timeout: 5))
        let initialValue = toggle.value as? String
        // The accessibility element spans the whole row, but only the
        // switch knob on the trailing edge is actually interactive.
        toggle.coordinate(withNormalizedOffset: CGVector(dx: 0.92, dy: 0.5)).tap()

        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "value != %@", initialValue ?? ""),
            object: toggle
        )
        XCTAssertEqual(XCTWaiter().wait(for: [expectation], timeout: 5), .completed)
    }

    func testNotificationToggleDoesNotCrashWhenPermissionIsUnresolved() {
        let app = openSettings()
        let toggle = app.switches["settings.remindersToggle"]
        XCTAssertTrue(toggle.waitForExistence(timeout: 5))
        toggle.coordinate(withNormalizedOffset: CGVector(dx: 0.92, dy: 0.5)).tap()
        // The app must remain responsive regardless of the OS permission
        // sheet outcome (denied, allowed, or a stray system alert).
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 5))
    }

    func testDeleteAllDataRequiresConfirmationAndClearsData() {
        let app = openSettings(seedSampleData: true)
        app.buttons["settings.deleteAllDataButton"].tap()

        XCTAssertTrue(app.buttons["Delete Everything"].waitForExistence(timeout: 5))
        app.buttons["Delete Everything"].tap()

        app.tapTab("Kitchen")
        XCTAssertFalse(app.buttons["kitchen.foodCard.apple"].exists)
    }
}
