import Foundation

/// Static description of a food item, sourced from the bundled local database.
struct FoodDefinition: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let category: FoodCategory
    let aliases: [String]
    let iconName: String
    let defaultUnit: FoodUnit

    let counterShelfLifeDays: Int
    let fridgeShelfLifeDays: Int
    let freezerShelfLifeDays: Int
    let ripeningDays: Int

    let ethyleneProduction: EthyleneLevel
    let ethyleneSensitivity: EthyleneLevel

    let storageTips: [String]
    let ripenessTips: [String]
    let freezingTips: [String]
    let rescueTags: [String]

    func shelfLifeDays(for storage: StorageLocation) -> Int {
        switch storage {
        case .counter, .pantry: return counterShelfLifeDays
        case .fridge: return fridgeShelfLifeDays
        case .freezer: return freezerShelfLifeDays
        }
    }
}
