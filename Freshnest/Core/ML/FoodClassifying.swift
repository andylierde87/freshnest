import CoreGraphics
import Foundation

struct FoodClassificationCandidate: Sendable, Equatable {
    let foodID: String
    let confidence: Double
}

struct FoodClassificationResult: Sendable, Equatable {
    let candidates: [FoodClassificationCandidate]
}

enum FoodClassificationConfidence {
    /// >= this: strong, safe to auto-select.
    static let strong = 0.80
    /// >= this: show as a suggestion that still needs confirmation.
    static let suggested = 0.60
}

protocol FoodClassifying: Sendable {
    func classify(image: CGImage) async throws -> FoodClassificationResult
}

enum FoodClassifyingError: Error {
    case visionRequestFailed(Error)
}
