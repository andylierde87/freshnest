import Foundation

/// User-reported condition from a manual freshness check (Section 39).
enum ManualFreshnessCheckState: String, Codable, CaseIterable, Sendable {
    case fresh
    case good
    case useSoon
    case overripe
    case spoiled

    var displayName: String {
        switch self {
        case .fresh: return String(localized: "Fresh")
        case .good: return String(localized: "Good")
        case .useSoon: return String(localized: "Use Soon")
        case .overripe: return String(localized: "Overripe")
        case .spoiled: return String(localized: "Spoiled")
        }
    }

    /// Additive score modifier applied by the freshness calculation engine.
    var scoreModifier: Int {
        switch self {
        case .fresh: return 5
        case .good: return 0
        case .useSoon: return -10
        case .overripe: return -25
        case .spoiled: return -60
        }
    }
}
