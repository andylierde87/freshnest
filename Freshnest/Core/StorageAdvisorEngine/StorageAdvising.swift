import Foundation

enum StorageCompatibility: String, Sendable {
    case good
    case fair
    case poor

    var displayName: String {
        switch self {
        case .good: return String(localized: "Good")
        case .fair: return String(localized: "Fair")
        case .poor: return String(localized: "Poor")
        }
    }
}

struct StorageWarning: Identifiable, Sendable, Equatable {
    let id: String
    let involvedFoodIDs: [String]
    let message: String
}

struct StorageRecommendation: Identifiable, Sendable, Equatable {
    var id: String { foodID }
    let foodID: String
    let recommendedStorage: StorageLocation
    let tips: [String]
}

struct StorageAdvisorResult: Sendable, Equatable {
    let compatibility: StorageCompatibility
    let warnings: [StorageWarning]
    let recommendations: [StorageRecommendation]
}

protocol StorageAdvising: Sendable {
    func advise(for foods: [FoodDefinition]) -> StorageAdvisorResult
}
