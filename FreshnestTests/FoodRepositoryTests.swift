import XCTest
@testable import Freshnest

@MainActor
final class FoodRepositoryTests: XCTestCase {
    func testUnknownFoodIDNeverCrashesAndReturnsSafeFallback() {
        let repository = FoodRepository()
        let definition = repository.definition(for: "definitely-not-a-real-food-id")
        XCTAssertEqual(definition.id, "definitely-not-a-real-food-id")
        XCTAssertEqual(definition.category, .otherProduce)
    }

    func testKnownFoodIsReturnedWhenPresent() {
        let repository = FoodRepository()
        XCTAssertNotNil(repository.definitionIfKnown(for: "apple"))
    }

    func testLoadFailureFallsBackToEmptyDatabaseInsteadtOfCrashing() {
        struct FailingLoader: FoodDatabaseLoading {
            func loadFoodDefinitions() throws -> [FoodDefinition] { throw FoodDatabaseError.resourceNotFound("foods") }
            func loadRescueRecipes() throws -> [RescueRecipe] { throw FoodDatabaseError.resourceNotFound("recipes") }
        }
        let repository = FoodRepository(loader: FailingLoader())
        XCTAssertTrue(repository.definitions.isEmpty)
        XCTAssertNotNil(repository.loadError)
        // Even with an empty database, lookups stay safe.
        XCTAssertEqual(repository.definition(for: "apple").id, "apple")
    }
}
