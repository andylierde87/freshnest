#if DEBUG
import Foundation
import SwiftData

/// Seeds a handful of deterministic batches for UI tests (Kitchen filters,
/// Rescue suggestions, Food Details). Never compiled into a Release build.
@MainActor
enum SampleDataSeeder {
    static func seed(into context: ModelContext, now: Date) {
        let calendar = Calendar.current

        func daysAgo(_ days: Int) -> Date {
            calendar.date(byAdding: .day, value: -days, to: now) ?? now
        }

        let seeds: [(id: String, days: Int, storage: StorageLocation, ripeness: RipenessState)] = [
            ("strawberry", 4, .fridge, .veryRipe),
            ("avocado", 5, .counter, .ripe),
            ("broccoli", 1, .fridge, .notSure),
            ("apple", 1, .fridge, .ripe),
            ("banana", 0, .counter, .almostRipe),
            ("tomato", 2, .counter, .ripe),
        ]

        for seed in seeds {
            let batch = FoodBatch(
                foodDefinitionID: seed.id,
                purchaseDate: daysAgo(seed.days),
                quantity: 2,
                unit: .piece,
                storageLocation: seed.storage,
                initialRipeness: seed.ripeness
            )
            context.insert(batch)
            let event = FoodEvent(batchID: batch.id, createdAt: batch.purchaseDate, type: .added, quantity: 2)
            event.batch = batch
            context.insert(event)
        }
    }
}
#endif
