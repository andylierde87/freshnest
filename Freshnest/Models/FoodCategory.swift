import Foundation

enum FoodCategory: String, Codable, CaseIterable, Sendable {
    case fruit
    case vegetable
    case herb
    case otherProduce

    var displayName: String {
        switch self {
        case .fruit: return String(localized: "Fruit")
        case .vegetable: return String(localized: "Vegetable")
        case .herb: return String(localized: "Herb")
        case .otherProduce: return String(localized: "Other Produce")
        }
    }
}

enum StorageLocation: String, Codable, CaseIterable, Sendable {
    case counter
    case fridge
    case freezer
    case pantry

    var displayName: String {
        switch self {
        case .counter: return String(localized: "Counter")
        case .fridge: return String(localized: "Fridge")
        case .freezer: return String(localized: "Freezer")
        case .pantry: return String(localized: "Pantry")
        }
    }

    var symbolName: String {
        switch self {
        case .counter: return "sun.max"
        case .fridge: return "refrigerator"
        case .freezer: return "snowflake"
        case .pantry: return "cabinet"
        }
    }

    /// Fails safely to `.counter` for unknown/legacy raw values.
    static func from(rawValue: String) -> StorageLocation {
        StorageLocation(rawValue: rawValue) ?? .counter
    }
}

enum RipenessState: String, Codable, CaseIterable, Sendable {
    case unripe
    case almostRipe
    case ripe
    case veryRipe
    case notSure

    var displayName: String {
        switch self {
        case .unripe: return String(localized: "Unripe")
        case .almostRipe: return String(localized: "Almost Ripe")
        case .ripe: return String(localized: "Ripe")
        case .veryRipe: return String(localized: "Very Ripe")
        case .notSure: return String(localized: "Not Sure")
        }
    }

    static func from(rawValue: String) -> RipenessState {
        RipenessState(rawValue: rawValue) ?? .notSure
    }
}

enum FreshnessState: String, Codable, CaseIterable, Sendable {
    case veryFresh
    case fresh
    case useSoon
    case eatToday
    case checkCarefully

    var displayName: String {
        switch self {
        case .veryFresh: return String(localized: "Very Fresh")
        case .fresh: return String(localized: "Fresh")
        case .useSoon: return String(localized: "Use Soon")
        case .eatToday: return String(localized: "Eat Today")
        case .checkCarefully: return String(localized: "Check Carefully")
        }
    }

    static func from(rawValue: String) -> FreshnessState? {
        FreshnessState(rawValue: rawValue)
    }
}

enum FoodEventType: String, Codable, CaseIterable, Sendable {
    case added
    case eaten
    case discarded
    case moved
    case scanned
    case ripenessChanged
    case quantityChanged
}

enum WasteReason: String, Codable, CaseIterable, Sendable {
    case spoiled
    case forgotten
    case boughtTooMuch
    case didNotLike
    case damaged
    case other

    var displayName: String {
        switch self {
        case .spoiled: return String(localized: "Spoiled")
        case .forgotten: return String(localized: "Forgot about it")
        case .boughtTooMuch: return String(localized: "Bought too much")
        case .didNotLike: return String(localized: "Didn't like it")
        case .damaged: return String(localized: "Damaged")
        case .other: return String(localized: "Other")
        }
    }
}

enum EthyleneLevel: String, Codable, CaseIterable, Sendable {
    case none
    case low
    case medium
    case high
}

enum FoodUnit: String, Codable, CaseIterable, Sendable {
    case piece
    case gram
    case kilogram
    case bunch
    case bag

    var displayName: String {
        switch self {
        case .piece: return String(localized: "pc")
        case .gram: return String(localized: "g")
        case .kilogram: return String(localized: "kg")
        case .bunch: return String(localized: "bunch")
        case .bag: return String(localized: "bag")
        }
    }

    static func from(rawValue: String) -> FoodUnit {
        FoodUnit(rawValue: rawValue) ?? .piece
    }
}

enum VisibleObservation: String, Codable, CaseIterable, Sendable {
    case greenArea
    case yellowing
    case brownSpots
    case darkSpots
    case wrinkling
    case surfaceDamage
    case discoloration
    case moldLikePattern
    case unknown

    var displayName: String {
        switch self {
        case .greenArea: return String(localized: "Green area")
        case .yellowing: return String(localized: "Yellowing")
        case .brownSpots: return String(localized: "Small brown spots")
        case .darkSpots: return String(localized: "Dark spots")
        case .wrinkling: return String(localized: "Wrinkling")
        case .surfaceDamage: return String(localized: "Surface damage")
        case .discoloration: return String(localized: "Discoloration")
        case .moldLikePattern: return String(localized: "Possible mold-like area")
        case .unknown: return String(localized: "Unrecognized visual pattern")
        }
    }
}
