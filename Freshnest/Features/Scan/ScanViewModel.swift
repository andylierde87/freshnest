import Foundation
import SwiftData
import UIKit

enum ScanPhase: Equatable {
    case idle
    case classifying
    case confirmingFood(foodID: String, confidence: Double, requiresConfirmation: Bool)
    case manualSelection
    case analyzing(foodID: String)
    case result(ScanResultData)
    case failed(message: String)
}

struct ScanResultData: Equatable {
    let foodID: String
    var score: Int
    var state: FreshnessState
    let confidence: Double
    let observations: [VisibleObservation]
}

@MainActor
@Observable
final class ScanViewModel {
    private(set) var phase: ScanPhase = .idle
    var selectedImage: UIImage?

    private let classifier: FoodClassifying
    private let analyzer: FreshnessAnalyzing
    private let repository: FoodRepository

    init(classifier: FoodClassifying, analyzer: FreshnessAnalyzing, repository: FoodRepository) {
        self.classifier = classifier
        self.analyzer = analyzer
        self.repository = repository
    }

    func reset() {
        selectedImage = nil
        phase = .idle
    }

    func imagePicked(_ image: UIImage) {
        selectedImage = image
        Task { await runClassification(image) }
    }

    func runClassification(_ image: UIImage) async {
        phase = .classifying
        guard let cgImage = ImageProcessing.cgImage(from: image) else {
            phase = .failed(message: String(localized: "We couldn't confidently analyze this photo."))
            return
        }

        do {
            let result = try await classifier.classify(image: cgImage)
            switch ScanResultMapper.mapClassification(result) {
            case .strongMatch(let foodID, let confidence):
                phase = .confirmingFood(foodID: foodID, confidence: confidence, requiresConfirmation: false)
            case .suggestedMatch(let foodID, let confidence):
                phase = .confirmingFood(foodID: foodID, confidence: confidence, requiresConfirmation: true)
            case .needsManualSelection:
                phase = .manualSelection
            case .failed:
                phase = .failed(message: String(localized: "We couldn't confidently analyze this photo."))
            }
        } catch {
            phase = .failed(message: String(localized: "Couldn't analyze this photo."))
        }
    }

    func chooseManually(foodID: String) {
        Task { await runAnalysis(foodID: foodID) }
    }

    func confirmFood(foodID: String) {
        Task { await runAnalysis(foodID: foodID) }
    }

    func runAnalysis(foodID: String) async {
        phase = .analyzing(foodID: foodID)
        guard let image = selectedImage, let cgImage = ImageProcessing.cgImage(from: image) else {
            phase = .failed(message: String(localized: "Couldn't analyze this photo."))
            return
        }
        do {
            let result = try await analyzer.analyze(image: cgImage, foodID: foodID)
            let score = ScanResultMapper.mapFreshnessScore(result.score)
            phase = .result(ScanResultData(
                foodID: foodID,
                score: score,
                state: FreshnessStateMapper.state(forScore: score),
                confidence: result.confidence,
                observations: ScanResultMapper.safeObservations(result.visibleObservations)
            ))
        } catch {
            phase = .failed(message: String(localized: "Couldn't analyze this photo."))
        }
    }

    func adjustResult(delta: Int) {
        guard case .result(var data) = phase else { return }
        let newScore = FreshnessStateMapper.clamp(data.score + delta)
        data.score = newScore
        data.state = FreshnessStateMapper.state(forScore: newScore)
        phase = .result(data)
    }

    func scanAgain() {
        reset()
    }

    /// Lets the user override the detected food, or pick manually after a
    /// low-confidence/failed identification — keeps the already-selected
    /// photo so freshness analysis can still run against it.
    func showManualSelection() {
        phase = .manualSelection
    }
}
