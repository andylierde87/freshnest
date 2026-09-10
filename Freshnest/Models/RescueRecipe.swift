import Foundation

struct RescueRecipe: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let requiredFoodIDs: [String]
    let optionalFoodIDs: [String]
    let steps: [String]
    let tags: [String]
}
