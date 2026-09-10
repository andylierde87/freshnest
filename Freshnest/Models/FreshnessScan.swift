import Foundation
import SwiftData

@Model
final class FreshnessScan {
    var id: UUID = UUID()
    var batchID: UUID?

    var createdAt: Date = Date()

    var detectedFoodID: String?
    var foodConfidence: Double?

    var freshnessScore: Int?
    var freshnessStateRawValue: String?
    var freshnessConfidence: Double?

    /// JSON-encoded `[VisibleObservation.rawValue]`.
    var detectedIssuesRawValue: String?

    var storedPhotoPath: String?

    var batch: FoodBatch?

    init(
        id: UUID = UUID(),
        batchID: UUID? = nil,
        createdAt: Date = Date(),
        detectedFoodID: String? = nil,
        foodConfidence: Double? = nil,
        freshnessScore: Int? = nil,
        freshnessState: FreshnessState? = nil,
        freshnessConfidence: Double? = nil,
        detectedIssues: [VisibleObservation] = [],
        storedPhotoPath: String? = nil
    ) {
        self.id = id
        self.batchID = batchID
        self.createdAt = createdAt
        self.detectedFoodID = detectedFoodID
        self.foodConfidence = foodConfidence
        self.freshnessScore = freshnessScore
        self.freshnessStateRawValue = freshnessState?.rawValue
        self.freshnessConfidence = freshnessConfidence
        self.detectedIssuesRawValue = try? String(
            data: JSONEncoder().encode(detectedIssues.map(\.rawValue)),
            encoding: .utf8
        )
        self.storedPhotoPath = storedPhotoPath
    }

    var freshnessState: FreshnessState? {
        freshnessStateRawValue.flatMap(FreshnessState.from(rawValue:))
    }

    var detectedIssues: [VisibleObservation] {
        guard
            let detectedIssuesRawValue,
            let data = detectedIssuesRawValue.data(using: .utf8),
            let raws = try? JSONDecoder().decode([String].self, from: data)
        else { return [] }
        return raws.compactMap(VisibleObservation.init(rawValue:))
    }
}
