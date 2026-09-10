import Foundation
@testable import Freshnest

/// Shared fixtures so individual test files don't redefine the same food
/// definitions and batches (Section 86).
enum TestFixtures {
    static let appleDefinition = FoodDefinition(
        id: "apple", name: "Apple", category: .fruit, aliases: ["apples"],
        iconName: "leaf.fill", defaultUnit: .piece,
        counterShelfLifeDays: 7, fridgeShelfLifeDays: 28, freezerShelfLifeDays: 240,
        ripeningDays: 0, ethyleneProduction: .high, ethyleneSensitivity: .low,
        storageTips: ["Keep in the fridge crisper for the longest life."],
        ripenessTips: [], freezingTips: [], rescueTags: ["baking"]
    )

    static let bananaDefinition = FoodDefinition(
        id: "banana", name: "Banana", category: .fruit, aliases: ["bananas"],
        iconName: "leaf.fill", defaultUnit: .piece,
        counterShelfLifeDays: 5, fridgeShelfLifeDays: 8, freezerShelfLifeDays: 90,
        ripeningDays: 3, ethyleneProduction: .high, ethyleneSensitivity: .medium,
        storageTips: ["Store on the counter, away from other produce."],
        ripenessTips: ["Yellow with small brown spots means peak ripeness."],
        freezingTips: [], rescueTags: ["smoothie"]
    )

    static let avocadoDefinition = FoodDefinition(
        id: "avocado", name: "Avocado", category: .fruit, aliases: ["avocados"],
        iconName: "leaf.fill", defaultUnit: .piece,
        counterShelfLifeDays: 5, fridgeShelfLifeDays: 10, freezerShelfLifeDays: 150,
        ripeningDays: 4, ethyleneProduction: .high, ethyleneSensitivity: .high,
        storageTips: ["Ripens quickly near bananas and apples."],
        ripenessTips: ["Gently press near the stem — a slight give means it's ripe."],
        freezingTips: [], rescueTags: ["toast"]
    )

    static let strawberryDefinition = FoodDefinition(
        id: "strawberry", name: "Strawberry", category: .fruit, aliases: ["strawberries"],
        iconName: "leaf.fill", defaultUnit: .piece,
        counterShelfLifeDays: 1, fridgeShelfLifeDays: 5, freezerShelfLifeDays: 240,
        ripeningDays: 0, ethyleneProduction: .low, ethyleneSensitivity: .medium,
        storageTips: ["Keep unwashed in the fridge until ready to eat."],
        ripenessTips: [], freezingTips: [], rescueTags: ["smoothie"]
    )

    static let broccoliDefinition = FoodDefinition(
        id: "broccoli", name: "Broccoli", category: .vegetable, aliases: ["broccolis"],
        iconName: "leaf.fill", defaultUnit: .piece,
        counterShelfLifeDays: 2, fridgeShelfLifeDays: 10, freezerShelfLifeDays: 300,
        ripeningDays: 0, ethyleneProduction: .none, ethyleneSensitivity: .high,
        storageTips: ["Store unwashed in a perforated bag in the fridge."],
        ripenessTips: [], freezingTips: [], rescueTags: ["stirFry"]
    )

    static let allDefinitions = [
        appleDefinition, bananaDefinition, avocadoDefinition, strawberryDefinition, broccoliDefinition,
    ]

    static func freshBatch(
        foodID: String = "apple",
        purchaseDate: Date = Date(),
        storage: StorageLocation = .fridge
    ) -> FoodBatch {
        FoodBatch(
            foodDefinitionID: foodID, purchaseDate: purchaseDate, quantity: 3, unit: .piece,
            storageLocation: storage, initialRipeness: .ripe
        )
    }

    static func urgentBatch(foodID: String = "strawberry", now: Date = Date()) -> FoodBatch {
        let purchaseDate = Calendar.current.date(byAdding: .day, value: -4, to: now) ?? now
        return FoodBatch(
            foodDefinitionID: foodID, purchaseDate: purchaseDate, quantity: 2, unit: .piece,
            storageLocation: .fridge, initialRipeness: .veryRipe
        )
    }

    static func expiredLikeBatch(foodID: String = "banana", now: Date = Date()) -> FoodBatch {
        let purchaseDate = Calendar.current.date(byAdding: .day, value: -30, to: now) ?? now
        return FoodBatch(
            foodDefinitionID: foodID, purchaseDate: purchaseDate, quantity: 1, unit: .piece,
            storageLocation: .counter, initialRipeness: .veryRipe
        )
    }

    static let mockHighConfidenceScan = FoodClassificationResult(
        candidates: [FoodClassificationCandidate(foodID: "banana", confidence: 0.94)]
    )

    static let mockLowConfidenceScan = FoodClassificationResult(
        candidates: [FoodClassificationCandidate(foodID: "banana", confidence: 0.32)]
    )
}
