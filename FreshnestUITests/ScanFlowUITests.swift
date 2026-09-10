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
        app.tabBars.buttons["Scan"].tap()

        let confirmButton = app.buttons["scan.confirmButton"]
        XCTAssertTrue(confirmButton.waitForExistence(timeout: 10))
        confirmButton.tap()

        XCTAssertTrue(app.otherElements["scan.result.score"].waitForExistence(timeout: 10))

        app.buttons["scan.result.addToKitchen"].tap()

        app.tabBars.buttons["Kitchen"].tap()
        XCTAssertTrue(app.buttons["kitchen.foodCard.banana"].waitForExistence(timeout: 5))
    }
}
