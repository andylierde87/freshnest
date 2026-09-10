import Foundation

/// Single shared mapping from a 0...100 score to a user-facing `FreshnessState`.
/// All call sites must go through this function instead of duplicating thresholds.
enum FreshnessStateMapper {
    static func state(forScore score: Int) -> FreshnessState {
        let clamped = clamp(score)
        switch clamped {
        case 90...100: return .veryFresh
        case 75..<90: return .fresh
        case 55..<75: return .useSoon
        case 30..<55: return .eatToday
        default: return .checkCarefully
        }
    }

    static func clamp(_ score: Int) -> Int {
        min(100, max(0, score))
    }
}
