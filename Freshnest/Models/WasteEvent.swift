import Foundation
import SwiftData

@Model
final class WasteEvent {
    var id: UUID = UUID()
    var foodDefinitionID: String = ""
    var batchID: UUID?
    var quantity: Double = 0
    var unitRawValue: String = FoodUnit.piece.rawValue
    var date: Date = Date()
    var reasonRawValue: String = WasteReason.other.rawValue

    init(
        id: UUID = UUID(),
        foodDefinitionID: String,
        batchID: UUID? = nil,
        quantity: Double,
        unit: FoodUnit,
        date: Date = Date(),
        reason: WasteReason
    ) {
        self.id = id
        self.foodDefinitionID = foodDefinitionID
        self.batchID = batchID
        self.quantity = quantity
        self.unitRawValue = unit.rawValue
        self.date = date
        self.reasonRawValue = reason.rawValue
    }

    var unit: FoodUnit {
        get { .from(rawValue: unitRawValue) }
        set { unitRawValue = newValue.rawValue }
    }

    var reason: WasteReason {
        get { WasteReason(rawValue: reasonRawValue) ?? .other }
        set { reasonRawValue = newValue.rawValue }
    }
}
