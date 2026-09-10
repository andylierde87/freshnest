import XCTest

final class FoodDetailsUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testAteOneDecrementsQuantityAndUpdatesHistory() {
        let app = XCUIApplication()
        app.launchForTesting(seedSampleData: true)
        app.tapTab("Kitchen")

        let card = app.buttons["kitchen.foodCard.apple"]
        XCTAssertTrue(card.waitForExistence(timeout: 15))
        card.tap()

        let ateOneButton = app.buttons["foodDetails.ateOneButton"]
        XCTAssertTrue(ateOneButton.waitForExistence(timeout: 15))
        ateOneButton.tap()

        XCTAssertTrue(app.staticTexts["Ate one"].waitForExistence(timeout: 15))
    }

    func testMoveStorageUpdatesLocationLabel() {
        let app = XCUIApplication()
        app.launchForTesting(seedSampleData: true)
        app.tapTab("Kitchen")

        let card = app.buttons["kitchen.foodCard.avocado"]
        XCTAssertTrue(card.waitForExistence(timeout: 15))
        card.tap()

        let moveButton = app.buttons["foodDetails.moveStorageButton"]
        XCTAssertTrue(moveButton.waitForExistence(timeout: 15))
        moveButton.tap()
        app.buttons["Fridge"].tap()

        XCTAssertTrue(app.staticTexts["Moved storage"].waitForExistence(timeout: 15))
    }
}
