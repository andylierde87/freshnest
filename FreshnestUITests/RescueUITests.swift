import XCTest

final class RescueUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testUrgentProduceSurfacesACompatibleRecipe() {
        let app = XCUIApplication()
        app.launchForTesting(seedSampleData: true)
        app.tabBars.buttons["Rescue"].tap()

        // Seeded data includes an urgent avocado + tomato, which should
        // surface at least one recipe suggestion with no network dependency.
        let firstRecipe = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'rescue.recipe.'")).firstMatch
        XCTAssertTrue(firstRecipe.waitForExistence(timeout: 5))
        firstRecipe.tap()

        XCTAssertTrue(app.staticTexts["Required"].waitForExistence(timeout: 5))
    }
}
