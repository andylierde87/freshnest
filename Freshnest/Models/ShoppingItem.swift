import Foundation
import SwiftData

@Model
final class ShoppingItem {
    var id: UUID = UUID()
    var foodDefinitionID: String = ""
    var quantity: Double = 1
    var unitRawValue: String = FoodUnit.piece.rawValue
    var isPurchased: Bool = false
    var createdAt: Date = Date()

    init(
        id: UUID = UUID(),
        foodDefinitionID: String,
        quantity: Double,
        unit: FoodUnit,
        isPurchased: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.foodDefinitionID = foodDefinitionID
        self.quantity = quantity
        self.unitRawValue = unit.rawValue
        self.isPurchased = isPurchased
        self.createdAt = createdAt
    }

    var unit: FoodUnit {
        get { .from(rawValue: unitRawValue) }
        set { unitRawValue = newValue.rawValue }
    }
}
