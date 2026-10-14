import XCTest

final class ScanFlowUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    /// Never drives the real camera/ML in automated UI tests — the app is
    /// launched with mocked scan dependencies and a self-fed placeholder
    /// photo instead (Section 74), since XCUITest cannot reliably drive the
    /// system Photos picker across processes.
    func testHighConfidenceScanFlowAddsBananaToKitchen() {
        let app = XCUIApplication()
        app.launchForTesting(mockScan: "highConfidenceBanana")
        app.tapTab("Scan")

        let confirmButton = app.buttons["scan.confirmButton"]
        XCTAssertTrue(confirmButton.waitForExistence(timeout: 10))
        confirmButton.tap()

        XCTAssertTrue(app.otherElements["scan.result.score"].waitForExistence(timeout: 10))

        app.buttons["scan.result.addToKitchen"].tap()

        app.tapTab("Kitchen")
        XCTAssertTrue(app.buttons["kitchen.foodCard.banana"].waitForExistence(timeout: 15))
    }

    func testScanFeedbackControlsFitWithAccessibilityText() {
        let app = XCUIApplication()
        app.launchArguments += [
            "--uitesting", "--reset-data", "--skip-onboarding",
            "--mock-scan=highConfidenceBanana", "--auto-trigger-scan",
            "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityExtraExtraExtraLarge",
        ]
        app.launch()
        app.tapTab("Scan")

        XCTAssertTrue(app.buttons["scan.confirmButton"].waitForExistence(timeout: 10))
        app.buttons["scan.confirmButton"].tap()

        XCTAssertTrue(app.buttons["scan.result.looksFresher"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["scan.result.looksCorrect"].exists)
        XCTAssertTrue(app.buttons["scan.result.looksWorse"].exists)
    }
}
