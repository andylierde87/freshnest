import Foundation

enum FoodDatabaseError: Error {
    case resourceNotFound(String)
    case decodingFailed(Error)
}

protocol FoodDatabaseLoading: Sendable {
    func loadFoodDefinitions() throws -> [FoodDefinition]
    func loadRescueRecipes() throws -> [RescueRecipe]
}

/// Loads the bundled, offline food and recipe databases shipped inside the
/// app bundle. Never performs network requests.
struct BundledFoodDatabaseLoader: FoodDatabaseLoading {
    let bundle: Bundle

    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }

    func loadFoodDefinitions() throws -> [FoodDefinition] {
        try loadJSON(resource: "foods", as: [FoodDefinition].self)
    }

    func loadRescueRecipes() throws -> [RescueRecipe] {
        try loadJSON(resource: "recipes", as: [RescueRecipe].self)
    }

    private func loadJSON<T: Decodable>(resource: String, as type: T.Type) throws -> T {
        guard let url = bundle.url(forResource: resource, withExtension: "json") else {
            throw FoodDatabaseError.resourceNotFound(resource)
        }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw FoodDatabaseError.decodingFailed(error)
        }
    }
}
