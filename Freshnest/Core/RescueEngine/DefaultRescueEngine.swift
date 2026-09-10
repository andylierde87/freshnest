import Foundation

/// Fully offline recipe matcher: a recipe is suggested only when every
/// required ingredient is currently available in the kitchen.
struct DefaultRescueEngine: RescueSuggesting {

    func suggestions(
        availableFoodIDs: Set<String>,
        urgentFoodIDs: Set<String>,
        recipes: [RescueRecipe]
    ) -> [RescueSuggestion] {
        guard !availableFoodIDs.isEmpty else { return [] }

        let candidates: [RescueSuggestion] = recipes.compactMap { recipe in
            guard !recipe.requiredFoodIDs.isEmpty else { return nil }
            let requiredSet = Set(recipe.requiredFoodIDs)
            guard requiredSet.isSubset(of: availableFoodIDs) else { return nil }

            let allIngredients = Set(recipe.requiredFoodIDs + recipe.optionalFoodIDs)
            let owned = allIngredients.intersection(availableFoodIDs)
            let urgentRescued = allIngredients.intersection(urgentFoodIDs)

            return RescueSuggestion(
                recipe: recipe,
                urgentFoodsRescued: urgentRescued.count,
                ownedIngredientCount: owned.count
            )
        }

        return candidates.sorted { lhs, rhs in
            if lhs.urgentFoodsRescued != rhs.urgentFoodsRescued {
                return lhs.urgentFoodsRescued > rhs.urgentFoodsRescued
            }
            if lhs.ownedIngredientCount != rhs.ownedIngredientCount {
                return lhs.ownedIngredientCount > rhs.ownedIngredientCount
            }
            let lhsComplexity = lhs.recipe.requiredFoodIDs.count + lhs.recipe.steps.count
            let rhsComplexity = rhs.recipe.requiredFoodIDs.count + rhs.recipe.steps.count
            if lhsComplexity != rhsComplexity {
                return lhsComplexity < rhsComplexity
            }
            return lhs.recipe.name < rhs.recipe.name
        }
    }
}
