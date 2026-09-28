import Foundation
import OSLog
import SwiftData

private let logger = Logger(subsystem: "com.pantrypulse.ios", category: "Persistence")

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

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            // Falling back to an in-memory store silently loses every batch,
            // event, and scan the user had — this is only reachable if the
            // on-disk store can't be opened/migrated, but it must stay
            // diagnosable rather than fail completely silently.
            logger.fault("Persistent ModelContainer failed to load, falling back to in-memory store: \(error, privacy: .public)")
        }

        let fallbackConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        guard let fallback = try? ModelContainer(for: schema, configurations: [fallbackConfiguration]) else {
            fatalError("PantryPulse could not create a SwiftData container, even in-memory.")
        }
        return fallback
    }
}
