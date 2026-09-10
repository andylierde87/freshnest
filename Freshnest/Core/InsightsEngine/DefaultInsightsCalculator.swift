import Foundation

/// Pure aggregation over already-resolved usage/waste records. Keeping this
/// engine free of SwiftData types keeps it trivially unit-testable.
struct DefaultInsightsCalculator: InsightsCalculating {

    func calculate(_ input: InsightsInput) -> InsightsResult {
        let consumed = filtered(input.consumed, by: input.dateRange, date: \.date)
        let discarded = filtered(input.discarded, by: input.dateRange, date: \.date)

        let consumedQuantity = consumed.reduce(0) { $0 + $1.quantity }
        let discardedQuantity = discarded.reduce(0) { $0 + $1.quantity }

        let total = consumedQuantity + discardedQuantity
        let useRate = total > 0 ? consumedQuantity / total : 0

        let mostUsedFoodID = mostFrequentFoodID(consumed.map { ($0.foodDefinitionID, $0.quantity) })
        let mostWastedFoodID = mostFrequentFoodID(discarded.map { ($0.foodDefinitionID, $0.quantity) })

        var discardReasonCounts: [WasteReason: Int] = [:]
        for record in discarded {
            discardReasonCounts[record.reason, default: 0] += 1
        }

        let rescueRate: Double
        if input.rescueOutcomes.isEmpty {
            rescueRate = 0
        } else {
            let rescuedCount = input.rescueOutcomes.filter(\.wasRescued).count
            rescueRate = Double(rescuedCount) / Double(input.rescueOutcomes.count)
        }

        return InsightsResult(
            consumedQuantity: consumedQuantity,
            discardedQuantity: discardedQuantity,
            useRate: useRate,
            mostUsedFoodID: mostUsedFoodID,
            mostWastedFoodID: mostWastedFoodID,
            discardReasonCounts: discardReasonCounts,
            rescueRate: rescueRate
        )
    }

    private func filtered<T>(_ items: [T], by range: ClosedRange<Date>?, date: KeyPath<T, Date>) -> [T] {
        guard let range else { return items }
        return items.filter { range.contains($0[keyPath: date]) }
    }

    private func mostFrequentFoodID(_ pairs: [(id: String, quantity: Double)]) -> String? {
        guard !pairs.isEmpty else { return nil }
        var totals: [String: Double] = [:]
        for pair in pairs { totals[pair.id, default: 0] += pair.quantity }
        return totals.max { $0.value < $1.value }?.key
    }
}
