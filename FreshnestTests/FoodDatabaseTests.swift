import XCTest
@testable import Freshnest

final class FoodDatabaseTests: XCTestCase {
    private func loadDefinitions() throws -> [FoodDefinition] {
        try BundledFoodDatabaseLoader(bundle: .main).loadFoodDefinitions()
    }

    private func loadRecipes() throws -> [RescueRecipe] {
        try BundledFoodDatabaseLoader(bundle: .main).loadRescueRecipes()
    }

    func testAtLeastFiftyProduceDefinitionsExist() throws {
        let definitions = try loadDefinitions()
        XCTAssertGreaterThanOrEqual(definitions.count, 50)
    }

    func testAllIDsAreUnique() throws {
        let definitions = try loadDefinitions()
        let ids = definitions.map(\.id)
        XCTAssertEqual(ids.count, Set(ids).count)
    }

    func testAllNamesAreNonEmpty() throws {
        let definitions = try loadDefinitions()
        XCTAssertTrue(definitions.allSatisfy { !$0.name.isEmpty })
    }

    func testShelfLifeValuesAreNonNegative() throws {
        let definitions = try loadDefinitions()
        for definition in definitions {
            XCTAssertGreaterThanOrEqual(definition.counterShelfLifeDays, 0)
            XCTAssertGreaterThanOrEqual(definition.fridgeShelfLifeDays, 0)
            XCTAssertGreaterThanOrEqual(definition.freezerShelfLifeDays, 0)
            XCTAssertGreaterThanOrEqual(definition.ripeningDays, 0)
        }
    }

    func testAliasesContainNoEmptyStrings() throws {
        let definitions = try loadDefinitions()
        for definition in definitions {
            XCTAssertFalse(definition.aliases.contains(""))
        }
    }

    func testNoDuplicateAliasesWithinTheSameFood() throws {
        let definitions = try loadDefinitions()
        for definition in definitions {
            XCTAssertEqual(definition.aliases.count, Set(definition.aliases).count, "Duplicate alias in \(definition.id)")
        }
    }

    func testRecipeReferencesPointToValidFoods() throws {
        let definitions = try loadDefinitions()
        let validIDs = Set(definitions.map(\.id))
        let recipes = try loadRecipes()
        for recipe in recipes {
            for foodID in recipe.requiredFoodIDs + recipe.optionalFoodIDs {
                XCTAssertTrue(validIDs.contains(foodID), "\(recipe.id) references unknown food \(foodID)")
            }
        }
    }

    func testCategoryRawValuesAreValid() throws {
        // Decoding already fails if a raw value is invalid, but this
        // documents the expectation explicitly for CI failure clarity.
        XCTAssertNoThrow(try loadDefinitions())
    }
}
