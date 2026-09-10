import Foundation

/// Resolves a `FoodBatch` plus its event/scan history into the freshness
/// engine's input, keeping that mapping out of SwiftUI views.
@MainActor
struct BatchFreshnessPresenter {
    let calculator: FreshnessCalculating
    let repository: FoodRepository

    func definition(for batch: FoodBatch) -> FoodDefinition {
        repository.definition(for: batch.foodDefinitionID)
    }

    func result(for batch: FoodBatch, now: Date) -> FreshnessResult {
        let input = FreshnessInput(
            foodDefinition: definition(for: batch),
            purchaseDate: batch.purchaseDate,
            storageLocation: batch.storageLocation,
            initialRipeness: batch.initialRipeness,
            latestManualCheck: latestManualCheck(from: batch.events),
            latestPhotoScan: latestPhotoScan(from: batch.scans),
            currentDate: now
        )
        return calculator.freshness(for: input)
    }

    private func latestManualCheck(from events: [FoodEvent]) -> ManualCheckInput? {
        events
            .filter { $0.type == .ripenessChanged }
            .max { $0.createdAt < $1.createdAt }
            .flatMap { event -> ManualCheckInput? in
                guard let raw = event.metadata, let state = ManualFreshnessCheckState(rawValue: raw) else { return nil }
                return ManualCheckInput(state: state, date: event.createdAt)
            }
    }

    private func latestPhotoScan(from scans: [FreshnessScan]) -> PhotoScanInput? {
        scans
            .filter { $0.freshnessScore != nil }
            .max { $0.createdAt < $1.createdAt }
            .flatMap { scan -> PhotoScanInput? in
                guard let score = scan.freshnessScore else { return nil }
                return PhotoScanInput(score: score, date: scan.createdAt)
            }
    }
}

/// Periodically syncs the persisted `currentFreshnessScore`/`estimatedFreshUntil`
/// fields so other parts of the app (widgets, notifications) can read a
/// reasonably fresh value without recomputing.
@MainActor
enum FreshnessScoreRefresher {
    static func refresh(_ batches: [FoodBatch], presenter: BatchFreshnessPresenter, now: Date) {
        for batch in batches where batch.isActive {
            let result = presenter.result(for: batch, now: now)
            if batch.currentFreshnessScore != result.score {
                batch.currentFreshnessScore = result.score
            }
            if batch.estimatedFreshUntil != result.estimatedFreshUntil {
                batch.estimatedFreshUntil = result.estimatedFreshUntil
            }
        }
    }
}
