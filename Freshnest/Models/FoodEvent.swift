import Foundation
import SwiftData

@Model
final class FoodEvent {
    var id: UUID = UUID()
    var batchID: UUID = UUID()
    var createdAt: Date = Date()
    var typeRawValue: String = FoodEventType.added.rawValue
    var quantity: Double?
    var metadata: String?

    var batch: FoodBatch?

    init(
        id: UUID = UUID(),
        batchID: UUID,
        createdAt: Date = Date(),
        type: FoodEventType,
        quantity: Double? = nil,
        metadata: String? = nil
    ) {
        self.id = id
        self.batchID = batchID
        self.createdAt = createdAt
        self.typeRawValue = type.rawValue
        self.quantity = quantity
        self.metadata = metadata
    }

    var type: FoodEventType {
        FoodEventType(rawValue: typeRawValue) ?? .added
    }
}
