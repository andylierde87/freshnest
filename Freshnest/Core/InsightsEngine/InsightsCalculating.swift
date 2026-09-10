import Foundation

struct FoodUsageRecord: Sendable, Equatable {
    let foodDefinitionID: String
    let quantity: Double
    let date: Date
}

struct WasteRecord: Sendable, Equatable {
    let foodDefinitionID: String
    let quantity: Double
    let date: Date
    let reason: WasteReason
}

/// Whether a batch that had reached an "at risk" freshness state was
/// ultimately consumed (`true`) or discarded (`false`) — used to compute rescue rate.
struct RescueOutcome: Sendable, Equatable {
    let wasRescued: Bool
}

struct InsightsInput: Sendable {
    let consumed: [FoodUsageRecord]
    let discarded: [WasteRecord]
    let rescueOutcomes: [RescueOutcome]
    let dateRange: ClosedRange<Date>?

    init(
        consumed: [FoodUsageRecord] = [],
        discarded: [WasteRecord] = [],
        rescueOutcomes: [RescueOutcome] = [],
        dateRange: ClosedRange<Date>? = nil
    ) {
        self.consumed = consumed
        self.discarded = discarded
        self.rescueOutcomes = rescueOutcomes
        self.dateRange = dateRange
    }
}

struct InsightsResult: Sendable, Equatable {
    let consumedQuantity: Double
    let discardedQuantity: Double
    let useRate: Double
    let mostUsedFoodID: String?
    let mostWastedFoodID: String?
    let discardReasonCounts: [WasteReason: Int]
    let rescueRate: Double

    static let empty = InsightsResult(
        consumedQuantity: 0,
        discardedQuantity: 0,
        useRate: 0,
        mostUsedFoodID: nil,
        mostWastedFoodID: nil,
        discardReasonCounts: [:],
        rescueRate: 0
    )
}

protocol InsightsCalculating: Sendable {
    func calculate(_ input: InsightsInput) -> InsightsResult
}
