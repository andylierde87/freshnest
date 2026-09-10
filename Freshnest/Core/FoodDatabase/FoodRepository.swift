import Foundation
import Observation

/// Loads and indexes the bundled food database once, exposing safe lookups.
/// A missing bundled record never crashes the app — callers get a safe
/// placeholder definition instead.
@Observable
@MainActor
final class FoodRepository {
    private(set) var definitions: [FoodDefinition] = []
    private(set) var recipes: [RescueRecipe] = []
    private(set) var loadError: Error?

    private var definitionsByID: [String: FoodDefinition] = [:]

    init(loader: FoodDatabaseLoading = BundledFoodDatabaseLoader()) {
        do {
            definitions = try loader.loadFoodDefinitions()
            definitionsByID = Dictionary(uniqueKeysWithValues: definitions.map { ($0.id, $0) })
        } catch {
            loadError = error
            definitions = []
            definitionsByID = [:]
        }

        do {
            recipes = try loader.loadRescueRecipes()
        } catch {
            recipes = []
        }
    }

    func definition(for id: String) -> FoodDefinition {
        definitionsByID[id] ?? FoodRepository.unknownDefinition(id: id)
    }

    func definitionIfKnown(for id: String) -> FoodDefinition? {
        definitionsByID[id]
    }

    func definitions(in category: FoodCategory) -> [FoodDefinition] {
        definitions.filter { $0.category == category }
    }

    /// Safe fallback used whenever a batch/scan references a food ID that is
    /// no longer present in the database (Section 51: never crash).
    static func unknownDefinition(id: String) -> FoodDefinition {
        FoodDefinition(
            id: id,
            name: String(localized: "Unknown Item"),
            category: .otherProduce,
            aliases: [],
            iconName: "questionmark.circle",
            defaultUnit: .piece,
            counterShelfLifeDays: 7,
            fridgeShelfLifeDays: 14,
            freezerShelfLifeDays: 180,
            ripeningDays: 0,
            ethyleneProduction: .none,
            ethyleneSensitivity: .none,
            storageTips: [],
            ripenessTips: [],
            freezingTips: [],
            rescueTags: []
        )
    }
}
