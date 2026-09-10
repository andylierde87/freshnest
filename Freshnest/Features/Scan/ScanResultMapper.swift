import Foundation

enum ScanIdentificationOutcome: Equatable {
    case strongMatch(foodID: String, confidence: Double)
    case suggestedMatch(foodID: String, confidence: Double)
    case needsManualSelection
    case failed
}

/// Turns a raw classifier result into a UI-ready outcome, applying the
/// confidence thresholds from Section 33. Pure and unit-testable.
enum ScanResultMapper {
    static func mapClassification(_ result: FoodClassificationResult) -> ScanIdentificationOutcome {
        guard let best = result.candidates.max(by: { $0.confidence < $1.confidence }) else {
            return .failed
        }
        if best.confidence >= FoodClassificationConfidence.strong {
            return .strongMatch(foodID: best.foodID, confidence: best.confidence)
        }
        if best.confidence >= FoodClassificationConfidence.suggested {
            return .suggestedMatch(foodID: best.foodID, confidence: best.confidence)
        }
        return .needsManualSelection
    }

    /// Clamps a freshness analysis score into the valid 0...100 range and
    /// resolves any unknown observation safely instead of crashing the UI.
    static func mapFreshnessScore(_ rawScore: Int) -> Int {
        FreshnessStateMapper.clamp(rawScore)
    }

    static func safeObservations(_ observations: [VisibleObservation]) -> [VisibleObservation] {
        observations.isEmpty ? [] : observations
    }
}
