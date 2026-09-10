#if DEBUG
import CoreGraphics
import Foundation
import UIKit

extension UIImage {
    /// A tiny in-memory placeholder image so UI tests can drive the Scan
    /// flow without needing a real photo library asset.
    static func solidColorPlaceholder(size: CGSize = CGSize(width: 64, height: 64)) -> UIImage? {
        UIGraphicsImageRenderer(size: size).image { context in
            UIColor.systemYellow.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
}

/// Deterministic stand-ins for the real Vision-backed services, used only
/// by SwiftUI previews, unit tests, and UI-test launch-argument injection.
/// Never compiled into a Release build.
struct FakeFoodClassifier: FoodClassifying {
    let result: FoodClassificationResult

    static func highConfidence(foodID: String, confidence: Double = 0.94) -> FakeFoodClassifier {
        FakeFoodClassifier(result: FoodClassificationResult(
            candidates: [FoodClassificationCandidate(foodID: foodID, confidence: confidence)]
        ))
    }

    static func lowConfidence(foodID: String, confidence: Double = 0.32) -> FakeFoodClassifier {
        FakeFoodClassifier(result: FoodClassificationResult(
            candidates: [FoodClassificationCandidate(foodID: foodID, confidence: confidence)]
        ))
    }

    static let empty = FakeFoodClassifier(result: FoodClassificationResult(candidates: []))

    func classify(image: CGImage) async throws -> FoodClassificationResult {
        result
    }
}

struct FakeFreshnessAnalyzer: FreshnessAnalyzing {
    let result: FreshnessAnalysisResult
    var shouldThrow = false

    static func result(score: Int, observations: [VisibleObservation] = []) -> FakeFreshnessAnalyzer {
        FakeFreshnessAnalyzer(result: FreshnessAnalysisResult(
            score: score,
            state: FreshnessStateMapper.state(forScore: score),
            confidence: 0.9,
            visibleObservations: observations
        ))
    }

    static let failing = FakeFreshnessAnalyzer(
        result: FreshnessAnalysisResult(score: 0, state: .checkCarefully, confidence: 0, visibleObservations: []),
        shouldThrow: true
    )

    func analyze(image: CGImage, foodID: String) async throws -> FreshnessAnalysisResult {
        if shouldThrow { throw FreshnessAnalyzingError.imageProcessingFailed }
        return result
    }
}
#endif
