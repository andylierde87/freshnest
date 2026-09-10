import Foundation
import SwiftData

enum FoodBatchMutationError: Error, Equatable {
    case invalidQuantity
}

/// Centralizes every state transition a `FoodBatch` can go through so the
/// rules (quantity floors, resulting status, emitted events) live in one
/// tested place instead of being duplicated across views.
struct FoodBatchMutationService {
    let modelContext: ModelContext
    let clock: ClockProviding

    init(modelContext: ModelContext, clock: ClockProviding = SystemClock()) {
        self.modelContext = modelContext
        self.clock = clock
    }

    @discardableResult
    func ateOne(_ batch: FoodBatch) throws -> FoodBatch {
        try ate(batch, quantity: 1)
    }

    @discardableResult
    func ate(_ batch: FoodBatch, quantity: Double) throws -> FoodBatch {
        guard quantity > 0, quantity <= batch.quantity else { throw FoodBatchMutationError.invalidQuantity }

        batch.quantity -= quantity
        batch.updatedAt = clock.now
        if batch.quantity <= 0 {
            batch.quantity = 0
            batch.status = .finished
        }

        let event = FoodEvent(batchID: batch.id, createdAt: clock.now, type: .eaten, quantity: quantity)
        event.batch = batch
        modelContext.insert(event)
        return batch
    }

    @discardableResult
    func discard(_ batch: FoodBatch, quantity: Double, reason: WasteReason) throws -> FoodBatch {
        guard quantity > 0, quantity <= batch.quantity else { throw FoodBatchMutationError.invalidQuantity }

        batch.quantity -= quantity
        batch.updatedAt = clock.now
        if batch.quantity <= 0 {
            batch.quantity = 0
            batch.status = .discarded
        }

        let event = FoodEvent(
            batchID: batch.id,
            createdAt: clock.now,
            type: .discarded,
            quantity: quantity,
            metadata: reason.rawValue
        )
        event.batch = batch
        modelContext.insert(event)

        let waste = WasteEvent(
            foodDefinitionID: batch.foodDefinitionID,
            batchID: batch.id,
            quantity: quantity,
            unit: batch.unit,
            date: clock.now,
            reason: reason
        )
        modelContext.insert(waste)

        return batch
    }

    @discardableResult
    func discardAll(_ batch: FoodBatch, reason: WasteReason) throws -> FoodBatch {
        try discard(batch, quantity: batch.quantity, reason: reason)
    }

    func move(_ batch: FoodBatch, to location: StorageLocation) {
        guard batch.storageLocation != location else { return }
        batch.storageLocation = location
        batch.updatedAt = clock.now

        let event = FoodEvent(
            batchID: batch.id,
            createdAt: clock.now,
            type: .moved,
            metadata: location.rawValue
        )
        event.batch = batch
        modelContext.insert(event)
    }

    func recordManualCheck(_ batch: FoodBatch, state: ManualFreshnessCheckState) {
        batch.updatedAt = clock.now
        let event = FoodEvent(
            batchID: batch.id,
            createdAt: clock.now,
            type: .ripenessChanged,
            metadata: state.rawValue
        )
        event.batch = batch
        modelContext.insert(event)
    }

    func updateQuantity(_ batch: FoodBatch, to newQuantity: Double) throws {
        guard newQuantity >= 0 else { throw FoodBatchMutationError.invalidQuantity }
        batch.quantity = newQuantity
        batch.updatedAt = clock.now
        if newQuantity <= 0 {
            batch.status = .finished
        }
        let event = FoodEvent(batchID: batch.id, createdAt: clock.now, type: .quantityChanged, quantity: newQuantity)
        event.batch = batch
        modelContext.insert(event)
    }
}
