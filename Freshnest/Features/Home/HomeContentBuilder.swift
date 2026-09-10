import Foundation

struct ScoredBatch: Identifiable {
    var id: UUID { batch.id }
    let batch: FoodBatch
    let result: FreshnessResult
}

struct HomeSections {
    let attentionItems: [ScoredBatch]
    let eatFirst: [ScoredBatch]
    let freshThisWeek: [ScoredBatch]
}

/// Pure section-building logic for the Home screen, kept out of the view so
/// the ranking rules are unit-testable in isolation from SwiftUI.
@MainActor
enum HomeContentBuilder {
    static func build(activeBatches: [FoodBatch], presenter: BatchFreshnessPresenter, now: Date) -> HomeSections {
        let scored = activeBatches
            .map { ScoredBatch(batch: $0, result: presenter.result(for: $0, now: now)) }
            .sorted(by: isMoreUrgent)

        let attention = scored.filter { $0.result.state == .checkCarefully || $0.result.state == .eatToday }
        let eatFirst = Array(scored.prefix(5))
        let freshThisWeek = scored.filter { $0.result.state == .fresh || $0.result.state == .veryFresh }

        return HomeSections(attentionItems: attention, eatFirst: eatFirst, freshThisWeek: Array(freshThisWeek.prefix(8)))
    }

    static func isMoreUrgent(_ lhs: ScoredBatch, _ rhs: ScoredBatch) -> Bool {
        let lhsRank = urgencyRank(lhs.result.state)
        let rhsRank = urgencyRank(rhs.result.state)
        if lhsRank != rhsRank { return lhsRank < rhsRank }
        if lhs.result.score != rhs.result.score { return lhs.result.score < rhs.result.score }

        switch (lhs.result.estimatedFreshUntil, rhs.result.estimatedFreshUntil) {
        case let (l?, r?) where l != r:
            return l < r
        case (nil, .some):
            return false
        case (.some, nil):
            return true
        default:
            break
        }
        return lhs.batch.purchaseDate < rhs.batch.purchaseDate
    }

    private static func urgencyRank(_ state: FreshnessState) -> Int {
        switch state {
        case .checkCarefully: return 0
        case .eatToday: return 1
        case .useSoon: return 2
        case .fresh: return 3
        case .veryFresh: return 4
        }
    }
}
