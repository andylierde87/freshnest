import XCTest

final class ScanLowConfidenceUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLowConfidenceShowsManualSelectionInsteadOfAutoSelecting() {
        let app = XCUIApplication()
        app.launchForTesting(mockScan: "lowConfidence")
        app.tapTab("Scan")

        let message = app.staticTexts["scan.lowConfidenceMessage"]
        XCTAssertTrue(message.waitForExistence(timeout: 10))

        XCTAssertFalse(app.buttons["scan.confirmButton"].exists)

        let manualResult = app.buttons["scan.manualResult.banana"]
        XCTAssertTrue(manualResult.waitForExistence(timeout: 5))
        manualResult.tap()

        XCTAssertTrue(app.otherElements["scan.result.score"].waitForExistence(timeout: 10))
    }
}

final class ScanFailureUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testFailedScanShowsRetryAndManualOptions() {
        let app = XCUIApplication()
        app.launchForTesting(mockScan: "failure")
        app.tapTab("Scan")

        XCTAssertTrue(app.staticTexts["scan.failureMessage"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["scan.failure.retryButton"].exists)
        XCTAssertTrue(app.buttons["scan.failure.selectManuallyButton"].exists)

        app.buttons["scan.failure.selectManuallyButton"].tap()
        XCTAssertTrue(app.staticTexts["scan.lowConfidenceMessage"].waitForExistence(timeout: 5))
    }
}
