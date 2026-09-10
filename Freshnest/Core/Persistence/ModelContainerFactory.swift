import Foundation
import SwiftData

enum FreshnestSchema {
    static let models: [any PersistentModel.Type] = [
        FoodBatch.self,
        FreshnessScan.self,
        FoodEvent.self,
        WasteEvent.self,
        ShoppingItem.self,
    ]
}

enum ModelContainerFactory {
    /// Builds the app's SwiftData container. Falls back to a fresh in-memory
    /// store rather than crashing if the persistent store is unreadable.
    static func makeContainer(inMemory: Bool = false) -> ModelContainer {
        let schema = Schema(FreshnestSchema.models)
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)

        if let container = try? ModelContainer(for: schema, configurations: [configuration]) {
            return container
        }

        let fallbackConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        guard let fallback = try? ModelContainer(for: schema, configurations: [fallbackConfiguration]) else {
            fatalError("PantryPulse could not create a SwiftData container, even in-memory.")
        }
        return fallback
    }
}
