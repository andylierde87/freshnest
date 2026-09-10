import XCTest

final class OnboardingUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testFreshInstallShowsOnboardingThenHomeThenNotAgain() {
        let app = XCUIApplication()
        app.launchArguments += ["--uitesting", "--reset-data"]
        app.launch()

        XCTAssertTrue(app.staticTexts["onboarding.page.0"].waitForExistence(timeout: 5))

        let continueButton = app.buttons["onboarding.continueButton"]
        for _ in 0..<3 {
            XCTAssertTrue(continueButton.waitForExistence(timeout: 5))
            continueButton.tap()
        }
        XCTAssertTrue(continueButton.waitForExistence(timeout: 5))
        continueButton.tap()

        XCTAssertTrue(app.buttons["home.settingsButton"].waitForExistence(timeout: 5))

        app.terminate()
        // Reassign (not append) so the earlier "--reset-data" argument is
        // dropped — this relaunch must NOT wipe what onboarding just saved.
        app.launchArguments = ["--uitesting"]
        app.launch()

        XCTAssertTrue(app.buttons["home.settingsButton"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["onboarding.page.0"].exists)
    }
}
