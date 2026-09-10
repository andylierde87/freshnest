import Foundation

struct RescueSuggestion: Identifiable, Sendable, Equatable {
    var id: String { recipe.id }
    let recipe: RescueRecipe
    let urgentFoodsRescued: Int
    let ownedIngredientCount: Int
}

protocol RescueSuggesting: Sendable {
    /// - Parameters:
    ///   - availableFoodIDs: food definition IDs currently active in the kitchen.
    ///   - urgentFoodIDs: subset of `availableFoodIDs` that should be used soon.
    ///   - recipes: the bundled offline recipe database.
    func suggestions(
        availableFoodIDs: Set<String>,
        urgentFoodIDs: Set<String>,
        recipes: [RescueRecipe]
    ) -> [RescueSuggestion]
}
