import XCTest

final class KitchenUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    private func launchIntoKitchen() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchForTesting(seedSampleData: true)
        app.tapTab("Kitchen")
        return app
    }

    func testSeededCardsAppear() {
        let app = launchIntoKitchen()
        XCTAssertTrue(app.buttons["kitchen.foodCard.apple"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["kitchen.foodCard.avocado"].waitForExistence(timeout: 5))
    }

    func testFruitFilterHidesVegetables() {
        let app = launchIntoKitchen()
        app.buttons["kitchen.filter.fruits"].tap()
        XCTAssertTrue(app.buttons["kitchen.foodCard.apple"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["kitchen.foodCard.broccoli"].exists)
    }

    func testFridgeFilterHidesCounterItems() {
        let app = launchIntoKitchen()
        app.buttons["kitchen.filter.fridge"].tap()
        XCTAssertTrue(app.buttons["kitchen.foodCard.apple"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["kitchen.foodCard.avocado"].exists)
    }

    func testEatFirstFilterShowsOnlyUrgentItems() {
        let app = launchIntoKitchen()
        // The filter chip row scrolls horizontally and "Eat First" is the
        // last chip, so bring it fully on-screen before tapping it.
        app.buttons["kitchen.filter.all"].swipeLeft()
        app.buttons["kitchen.filter.eatFirst"].tap()
        XCTAssertTrue(app.buttons["kitchen.foodCard.strawberry"].waitForExistence(timeout: 5))
    }

    func testOpeningACardShowsDetails() {
        let app = launchIntoKitchen()
        let card = app.buttons["kitchen.foodCard.apple"]
        XCTAssertTrue(card.waitForExistence(timeout: 5))
        card.tap()
        XCTAssertTrue(app.otherElements["foodDetails.score"].waitForExistence(timeout: 5))
    }
}
