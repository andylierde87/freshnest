import CoreGraphics
import Foundation
import Vision

/// Runs Apple's on-device Vision general image classifier and maps its
/// labels onto the bundled food database by name/alias matching. Fully
/// on-device — no network request is made.
struct VisionFoodClassifier: FoodClassifying {
    let definitions: [FoodDefinition]

    func classify(image: CGImage) async throws -> FoodClassificationResult {
        let observations: [VNClassificationObservation] = try await withCheckedThrowingContinuation { continuation in
            let request = VNClassifyImageRequest { request, error in
                if let error {
                    continuation.resume(throwing: FoodClassifyingError.visionRequestFailed(error))
                    return
                }
                let results = (request.results as? [VNClassificationObservation]) ?? []
                continuation.resume(returning: results)
            }
            let handler = VNImageRequestHandler(cgImage: image, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: FoodClassifyingError.visionRequestFailed(error))
            }
        }

        let candidates = mapToCandidates(observations)
        return FoodClassificationResult(candidates: candidates)
    }

    private func mapToCandidates(_ observations: [VNClassificationObservation]) -> [FoodClassificationCandidate] {
        var bestConfidenceByFoodID: [String: Double] = [:]

        for observation in observations.prefix(25) {
            let label = observation.identifier.lowercased().replacingOccurrences(of: "_", with: " ")
            guard let match = bestDefinition(matching: label) else { continue }
            let confidence = Double(observation.confidence)
            if let existing = bestConfidenceByFoodID[match.id], existing >= confidence { continue }
            bestConfidenceByFoodID[match.id] = confidence
        }

        return bestConfidenceByFoodID
            .map { FoodClassificationCandidate(foodID: $0.key, confidence: $0.value) }
            .sorted { $0.confidence > $1.confidence }
    }

    private func bestDefinition(matching label: String) -> FoodDefinition? {
        for definition in definitions {
            let names = [definition.name.lowercased()] + definition.aliases.map { $0.lowercased() }
            if names.contains(where: { label == $0 || label.contains($0) || $0.contains(label) }) {
                return definition
            }
        }
        return nil
    }
}
