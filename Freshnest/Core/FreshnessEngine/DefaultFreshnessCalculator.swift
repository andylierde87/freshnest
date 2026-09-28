import Foundation

/// Deterministic, unit-testable freshness scoring engine.
///
/// Conceptually: base shelf-life decay + initial ripeness modifier,
/// blended with the latest manual check and the latest photo scan.
/// The result is always clamped to 0...100.
struct DefaultFreshnessCalculator: FreshnessCalculating {

    func freshness(for input: FreshnessInput) -> FreshnessResult {
        let shelfLifeDays = max(1, input.foodDefinition.shelfLifeDays(for: input.storageLocation))
        let daysElapsed = max(0, daysBetween(input.purchaseDate, input.currentDate))

        let decayFraction = min(1, Double(daysElapsed) / Double(shelfLifeDays))
        let baseScore = 100.0 * (1 - decayFraction)

        let ripenessModifier = ripenessModifier(for: input.initialRipeness)

        var score = baseScore + Double(ripenessModifier)

        if let manualCheck = input.latestManualCheck, manualCheck.date >= input.purchaseDate {
            score += Double(manualCheck.state.scoreModifier)
        }

        if let photoScan = input.latestPhotoScan, photoScan.date >= input.purchaseDate {
            // Pull the calculated score halfway toward the observed photo score,
            // so a low visual reading meaningfully lowers the effective score.
            let clampedPhotoScore = Double(FreshnessStateMapper.clamp(photoScan.score))
            score = (score + clampedPhotoScore) / 2
        }

        let finalScore = FreshnessStateMapper.clamp(Int(score.rounded()))
        let state = FreshnessStateMapper.state(forScore: finalScore)

        let remainingFraction = Double(finalScore) / 100.0
        let remainingDays = Int((remainingFraction * Double(shelfLifeDays)).rounded())
        let estimatedFreshUntil = Calendar.current.date(
            byAdding: .day,
            value: remainingDays,
            to: input.currentDate
        )

        return FreshnessResult(score: finalScore, state: state, estimatedFreshUntil: estimatedFreshUntil)
    }

    private func ripenessModifier(for ripeness: RipenessState) -> Int {
        switch ripeness {
        case .unripe: return 5
        case .almostRipe: return 2
        case .ripe: return 0
        case .veryRipe: return -10
        case .notSure: return 0
        }
    }

    private func daysBetween(_ start: Date, _ end: Date) -> Int {
        // Uses the device's local calendar so "elapsed days" matches the
        // calendar-day boundaries (midnight) the user actually experiences,
        // rather than UTC midnight.
        Calendar.current.dateComponents([.day], from: start, to: end).day ?? 0
    }
}
