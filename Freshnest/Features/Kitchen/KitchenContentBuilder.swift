import Foundation

enum KitchenFilter: String, CaseIterable, Identifiable {
    case all
    case fruits
    case vegetables
    case fridge
    case counter
    case freezer
    case eatFirst

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: return String(localized: "All")
        case .fruits: return String(localized: "Fruits")
        case .vegetables: return String(localized: "Vegetables")
        case .fridge: return String(localized: "Fridge")
        case .counter: return String(localized: "Counter")
        case .freezer: return String(localized: "Freezer")
        case .eatFirst: return String(localized: "Eat First")
        }
    }
}

enum KitchenSort: String, CaseIterable, Identifiable {
    case freshness
    case recentlyAdded
    case purchaseDate
    case name

    var id: String { rawValue }

    var title: String {
        switch self {
        case .freshness: return String(localized: "Freshness")
        case .recentlyAdded: return String(localized: "Recently Added")
        case .purchaseDate: return String(localized: "Purchase Date")
        case .name: return String(localized: "Name")
        }
    }
}

@MainActor
enum KitchenContentBuilder {
    static func build(
        activeBatches: [FoodBatch],
        filter: KitchenFilter,
        sort: KitchenSort,
        presenter: BatchFreshnessPresenter,
        now: Date
    ) -> [ScoredBatch] {
        let scored = activeBatches.map { ScoredBatch(batch: $0, result: presenter.result(for: $0, now: now)) }

        let filtered = scored.filter { scored in
            let definition = presenter.definition(for: scored.batch)
            switch filter {
            case .all: return true
            case .fruits: return definition.category == .fruit
            case .vegetables: return definition.category == .vegetable
            case .fridge: return scored.batch.storageLocation == .fridge
            case .counter: return scored.batch.storageLocation == .counter
            case .freezer: return scored.batch.storageLocation == .freezer
            case .eatFirst: return scored.result.state == .eatToday || scored.result.state == .checkCarefully || scored.result.state == .useSoon
            }
        }

        return filtered.sorted { lhs, rhs in
            switch sort {
            case .freshness:
                return lhs.result.score < rhs.result.score
            case .recentlyAdded:
                return lhs.batch.createdAt > rhs.batch.createdAt
            case .purchaseDate:
                return lhs.batch.purchaseDate > rhs.batch.purchaseDate
            case .name:
                return presenter.definition(for: lhs.batch).name < presenter.definition(for: rhs.batch).name
            }
        }
    }
}
