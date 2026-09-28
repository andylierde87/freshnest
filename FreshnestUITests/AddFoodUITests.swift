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
        XCTAssertTrue(searchField.waitForExistence(timeout: 15))
        searchField.tap()
        searchField.typeText("Avocado")

        let result = app.buttons["addFood.result.avocado"]
        XCTAssertTrue(result.waitForExistence(timeout: 15))
        result.tap()

        let incrementButton = app.buttons["addFood.quantityStepper-Increment"]
        XCTAssertTrue(incrementButton.waitForExistence(timeout: 15))
        incrementButton.tap()
        incrementButton.tap()

        app.buttons["addFood.saveButton"].tap()

        // Popping back to the search screen can silently restore keyboard
        // focus to the search field, which visually covers the tab bar.
        // Explicitly dismiss it before trying to switch tabs. Sending the
        // return keystroke directly (rather than tapping a keyboard button by
        // label) avoids depending on the keyboard's locale and sidesteps a
        // flaky AX scroll-to-visible failure when tapping onscreen keyboard
        // keys on some simulators.
        if app.keyboards.firstMatch.waitForExistence(timeout: 2) {
            app.typeText("\n")
        }

        let kitchenTab = app.tab("Kitchen")
        XCTAssertTrue(kitchenTab.waitForExistence(timeout: 15))
        app.tapTab("Kitchen")

        XCTAssertTrue(app.buttons["kitchen.foodCard.avocado"].waitForExistence(timeout: 15))
    }
}
