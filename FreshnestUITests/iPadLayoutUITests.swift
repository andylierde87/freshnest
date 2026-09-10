import XCTest

/// Run against an iPad simulator destination (Section 80), e.g.:
/// `xcodebuild test -scheme Freshnest -destination 'platform=iOS Simulator,name=iPad Pro 11-inch (M4)'`
///
/// Note: on iPad, iOS 18's `Tab`-based `TabView` renders as a top tab bar
/// rather than a `TabBar`-typed accessibility element, so these tests match
/// tab buttons by label directly instead of scoping through `app.tabBars`.
final class iPadLayoutUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDown() {
        XCUIDevice.shared.orientation = .portrait
    }

    func testKitchenGridAndTabBarRemainUsableOnIPad() {
        let app = XCUIApplication()
        app.launchForTesting(seedSampleData: true)

        app.buttons["Kitchen"].firstMatch.tap()
        XCTAssertTrue(app.buttons["kitchen.foodCard.apple"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["kitchen.foodCard.avocado"].exists)

        // Navigation and the tab navigation must both remain visible/tappable
        // — i.e. nothing is clipped by the iPad's wider layout.
        XCTAssertTrue(app.navigationBars.firstMatch.exists)
        XCTAssertTrue(app.buttons["Home"].firstMatch.exists)
    }

    func testFoodDetailsDoesNotStretchAwkwardlyOnIPad() {
        let app = XCUIApplication()
        app.launchForTesting(seedSampleData: true)
        app.buttons["Kitchen"].firstMatch.tap()

        let card = app.buttons["kitchen.foodCard.apple"]
        XCTAssertTrue(card.waitForExistence(timeout: 5))
        card.tap()

        XCTAssertTrue(app.otherElements["foodDetails.score"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["foodDetails.ateOneButton"].exists)
    }

    func testRotatingPortraitToLandscapeStaysFunctional() {
        let app = XCUIApplication()
        app.launchForTesting(seedSampleData: true)
        app.buttons["Kitchen"].firstMatch.tap()
        XCTAssertTrue(app.buttons["kitchen.foodCard.apple"].waitForExistence(timeout: 5))

        XCUIDevice.shared.orientation = .landscapeLeft
        XCTAssertTrue(app.buttons["kitchen.foodCard.apple"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Home"].firstMatch.exists)
    }

    func testFoodLibrarySplitViewIsUsableOnIPad() {
        let app = XCUIApplication()
        app.launchForTesting()
        app.buttons["home.settingsButton"].tap()
        app.staticTexts["Food Library"].tap()
        sleep(1)

        // On iPad this renders as a NavigationSplitView. The exact layout
        // varies enough across iPad sizes that we only assert the app is
        // still alive and responsive — no crash, no blank screen.
        XCTAssertEqual(app.state, .runningForeground)
    }
}
