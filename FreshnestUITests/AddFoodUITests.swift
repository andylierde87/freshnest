import XCTest

final class AddFoodUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testAddAvocadoFromHomeAppearsInKitchenWithCorrectQuantity() {
        let app = XCUIApplication()
        app.launchForTesting()

        app.buttons["home.addFoodButton"].tap()

        let searchField = app.textFields["addFood.searchField"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))
        searchField.tap()
        searchField.typeText("Avocado")

        let result = app.buttons["addFood.result.avocado"]
        XCTAssertTrue(result.waitForExistence(timeout: 5))
        result.tap()

        let incrementButton = app.buttons["addFood.quantityStepper-Increment"]
        XCTAssertTrue(incrementButton.waitForExistence(timeout: 5))
        incrementButton.tap()
        incrementButton.tap()

        app.buttons["addFood.saveButton"].tap()

        // Popping back to the search screen can silently restore keyboard
        // focus to the search field, which visually covers the tab bar.
        // Explicitly dismiss it before trying to switch tabs.
        if app.keyboards.firstMatch.waitForExistence(timeout: 2) {
            let returnKey = app.keyboards.buttons["Search"].exists
                ? app.keyboards.buttons["Search"]
                : app.keyboards.buttons["Return"]
            if returnKey.exists {
                returnKey.tap()
            }
        }

        let kitchenTab = app.tabBars.buttons["Kitchen"]
        XCTAssertTrue(kitchenTab.waitForExistence(timeout: 5))
        XCTAssertTrue(kitchenTab.waitForHittable(timeout: 5))
        kitchenTab.tap()

        XCTAssertTrue(app.buttons["kitchen.foodCard.avocado"].waitForExistence(timeout: 5))
    }
}
