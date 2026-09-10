import Foundation
import SwiftData

enum FoodBatchStatus: String, Codable, Sendable {
    case active
    case finished
    case discarded

    static func from(rawValue: String) -> FoodBatchStatus {
        FoodBatchStatus(rawValue: rawValue) ?? .active
    }
}

@Model
final class FoodBatch {
    var id: UUID = UUID()
    var foodDefinitionID: String = ""

    var purchaseDate: Date = Date()
    var quantity: Double = 1
    var unitRawValue: String = FoodUnit.piece.rawValue

    var storageLocationRawValue: String = StorageLocation.counter.rawValue
    var initialRipenessRawValue: String = RipenessState.notSure.rawValue

    var currentFreshnessScore: Int = 100
    var estimatedFreshUntil: Date?

    var statusRawValue: String = FoodBatchStatus.active.rawValue

    var notes: String?

    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    @Relationship(deleteRule: .cascade, inverse: \FoodEvent.batch)
    var events: [FoodEvent] = []

    @Relationship(deleteRule: .cascade, inverse: \FreshnessScan.batch)
    var scans: [FreshnessScan] = []

    init(
        id: UUID = UUID(),
        foodDefinitionID: String,
        purchaseDate: Date,
        quantity: Double,
        unit: FoodUnit,
        storageLocation: StorageLocation,
        initialRipeness: RipenessState,
        currentFreshnessScore: Int = 100,
        estimatedFreshUntil: Date? = nil,
        status: FoodBatchStatus = .active,
        notes: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.foodDefinitionID = foodDefinitionID
        self.purchaseDate = purchaseDate
        self.quantity = quantity
        self.unitRawValue = unit.rawValue
        self.storageLocationRawValue = storageLocation.rawValue
        self.initialRipenessRawValue = initialRipeness.rawValue
        self.currentFreshnessScore = currentFreshnessScore
        self.estimatedFreshUntil = estimatedFreshUntil
        self.statusRawValue = status.rawValue
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var unit: FoodUnit {
        get { .from(rawValue: unitRawValue) }
        set { unitRawValue = newValue.rawValue }
    }

    var storageLocation: StorageLocation {
        get { .from(rawValue: storageLocationRawValue) }
        set { storageLocationRawValue = newValue.rawValue }
    }

    var initialRipeness: RipenessState {
        get { .from(rawValue: initialRipenessRawValue) }
        set { initialRipenessRawValue = newValue.rawValue }
    }

    var status: FoodBatchStatus {
        get { .from(rawValue: statusRawValue) }
        set { statusRawValue = newValue.rawValue }
    }

    var isActive: Bool { status == .active }
}
