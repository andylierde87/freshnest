import XCTest
@testable import Freshnest

final class RescueEngineTests: XCTestCase {
    private let engine = DefaultRescueEngine()

    private let recipe = RescueRecipe(
        id: "avocadoToast", name: "Avocado Toast",
        requiredFoodIDs: ["avocado"], optionalFoodIDs: ["tomato"],
        steps: ["Mash avocado.", "Spread on toast."], tags: ["quick"]
    )

    func testExactRequiredFoodsAvailableProducesRecipe() {
        let suggestions = engine.suggestions(
            availableFoodIDs: ["avocado"], urgentFoodIDs: [], recipes: [recipe]
        )
        XCTAssertEqual(suggestions.map(\.recipe.id), ["avocadoToast"])
    }

    func testMissingRequiredFoodExcludesRecipe() {
        let suggestions = engine.suggestions(
            availableFoodIDs: ["tomato"], urgentFoodIDs: [], recipes: [recipe]
        )
        XCTAssertTrue(suggestions.isEmpty)
    }

    func testMissingOptionalFoodStillIncludesRecipe() {
        let suggestions = engine.suggestions(
            availableFoodIDs: ["avocado"], urgentFoodIDs: [], recipes: [recipe]
        )
        XCTAssertEqual(suggestions.count, 1)
    }

    func testRecipeRescuingMoreUrgentFoodsRanksHigher() {
        let lowUrgency = RescueRecipe(
            id: "lowUrgency", name: "Low Urgency", requiredFoodIDs: ["apple"], optionalFoodIDs: [],
            steps: ["Eat it."], tags: []
        )
        let highUrgency = RescueRecipe(
            id: "highUrgency", name: "High Urgency", requiredFoodIDs: ["strawberry"], optionalFoodIDs: [],
            steps: ["Eat it."], tags: []
        )
        let suggestions = engine.suggestions(
            availableFoodIDs: ["apple", "strawberry"],
            urgentFoodIDs: ["strawberry"],
            recipes: [lowUrgency, highUrgency]
        )
        XCTAssertEqual(suggestions.first?.recipe.id, "highUrgency")
    }

    func testEmptyKitchenProducesNoRecipesAndDoesNotCrash() {
        let suggestions = engine.suggestions(availableFoodIDs: [], urgentFoodIDs: [], recipes: [recipe])
        XCTAssertTrue(suggestions.isEmpty)
    }

    func testDuplicateAvailabilityIsHandledCorrectly() {
        let suggestions = engine.suggestions(
            availableFoodIDs: ["avocado", "avocado", "tomato"], urgentFoodIDs: [], recipes: [recipe]
        )
        XCTAssertEqual(suggestions.count, 1)
        XCTAssertEqual(suggestions.first?.ownedIngredientCount, 2)
    }
}
