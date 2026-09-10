import XCTest

final class ShoppingListUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testAddPurchaseAndMoveToKitchen() {
        let app = XCUIApplication()
        app.launchForTesting()
        app.tapTab("Home")
        app.buttons["home.settingsButton"].tap()
        app.staticTexts["Shopping List"].tap()

        app.buttons["shoppingList.addButton"].tap()

        let searchField = app.textFields["shoppingItem.searchField"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 15))
        searchField.tap()
        searchField.typeText("Banana")

        app.buttons["shoppingItem.result.banana"].tap()

        let incrementButton = app.buttons["shoppingItem.quantityStepper-Increment"]
        if incrementButton.waitForExistence(timeout: 3) {
            for _ in 0..<4 { incrementButton.tap() }
        }
        app.buttons["shoppingItem.addButton"].tap()

        let toggle = app.buttons["shoppingList.toggle.banana"]
        XCTAssertTrue(toggle.waitForExistence(timeout: 15))
        toggle.tap()

        XCTAssertTrue(app.buttons["Add to Kitchen"].waitForExistence(timeout: 15))
        app.buttons["Add to Kitchen"].tap()

        app.tapTab("Kitchen")
        XCTAssertTrue(app.buttons["kitchen.foodCard.banana"].waitForExistence(timeout: 15))
    }
}
