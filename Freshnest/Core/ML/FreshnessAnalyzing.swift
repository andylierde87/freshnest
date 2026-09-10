import CoreGraphics
import Foundation

struct FreshnessAnalysisResult: Sendable, Equatable {
    let score: Int
    let state: FreshnessState
    let confidence: Double
    let visibleObservations: [VisibleObservation]
}

enum FreshnessAnalyzingError: Error {
    case imageProcessingFailed
}

protocol FreshnessAnalyzing: Sendable {
    func analyze(image: CGImage, foodID: String) async throws -> FreshnessAnalysisResult
}
