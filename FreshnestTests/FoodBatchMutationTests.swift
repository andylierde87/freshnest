import SwiftData
import XCTest
@testable import Freshnest

@MainActor
final class FoodBatchMutationTests: XCTestCase {
    private var container: ModelContainer!
    private var context: ModelContext!
    private var service: FoodBatchMutationService!

    override func setUp() async throws {
        container = InMemoryContainer.make()
        context = ModelContext(container)
        service = FoodBatchMutationService(modelContext: context, clock: FixedClock(fixedDate: Date()))
    }

    private func makeBatch(quantity: Double = 3) -> FoodBatch {
        let batch = TestFixtures.freshBatch()
        batch.quantity = quantity
        context.insert(batch)
        return batch
    }

    func testAteOneDecrementsQuantity() throws {
        let batch = makeBatch(quantity: 3)
        try service.ateOne(batch)
        XCTAssertEqual(batch.quantity, 2)
        XCTAssertTrue(batch.isActive)
    }

    func testAteOneCreatesEvent() throws {
        let batch = makeBatch(quantity: 3)
        try service.ateOne(batch)
        XCTAssertEqual(batch.events.filter { $0.type == .eaten }.count, 1)
    }

    func testAteLastOneFinishesBatch() throws {
        let batch = makeBatch(quantity: 1)
        try service.ateOne(batch)
        XCTAssertEqual(batch.quantity, 0)
        XCTAssertEqual(batch.status, .finished)
    }

    func testAteOneOnFractionalRemainderFinishesBatchInsteadOfThrowing() throws {
        let batch = makeBatch(quantity: 0.5)
        try service.ateOne(batch)
        XCTAssertEqual(batch.quantity, 0)
        XCTAssertEqual(batch.status, .finished)
    }

    func testDiscardPartialDecreasesQuantityAndCreatesWasteEvent() throws {
        let batch = makeBatch(quantity: 4)
        try service.discard(batch, quantity: 1, reason: .spoiled)
        XCTAssertEqual(batch.quantity, 3)
        XCTAssertTrue(batch.isActive)
    }

    func testDiscardEntireBatchMarksDiscarded() throws {
        let batch = makeBatch(quantity: 2)
        try service.discard(batch, quantity: 2, reason: .forgotten)
        XCTAssertEqual(batch.quantity, 0)
        XCTAssertEqual(batch.status, .discarded)
    }

    func testMoveStorageChangesLocationAndCreatesEvent() {
        let batch = makeBatch()
        XCTAssertEqual(batch.storageLocation, .fridge)
        service.move(batch, to: .freezer)
        XCTAssertEqual(batch.storageLocation, .freezer)
        XCTAssertEqual(batch.events.filter { $0.type == .moved }.count, 1)
    }

    func testNegativeQuantityIsPrevented() {
        let batch = makeBatch(quantity: 3)
        XCTAssertThrowsError(try service.discard(batch, quantity: -1, reason: .other)) { error in
            XCTAssertEqual(error as? FoodBatchMutationError, .invalidQuantity)
        }
        XCTAssertEqual(batch.quantity, 3)
    }

    func testCannotEatMoreThanAvailable() {
        let batch = makeBatch(quantity: 2)
        XCTAssertThrowsError(try service.ate(batch, quantity: 5)) { error in
            XCTAssertEqual(error as? FoodBatchMutationError, .invalidQuantity)
        }
        XCTAssertEqual(batch.quantity, 2)
    }
}
