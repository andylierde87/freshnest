import SwiftData
import XCTest
@testable import Freshnest

@MainActor
final class PersistenceTests: XCTestCase {
    private var container: ModelContainer!
    private var context: ModelContext!

    override func setUp() async throws {
        container = InMemoryContainer.make()
        context = ModelContext(container)
    }

    func testCreateAndFetchBatch() throws {
        let batch = TestFixtures.freshBatch()
        context.insert(batch)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<FoodBatch>())
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.foodDefinitionID, "apple")
    }

    func testUpdateBatchPersists() throws {
        let batch = TestFixtures.freshBatch()
        context.insert(batch)
        try context.save()

        batch.quantity = 10
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<FoodBatch>())
        XCTAssertEqual(fetched.first?.quantity, 10)
    }

    func testDeleteBatchRemovesIt() throws {
        let batch = TestFixtures.freshBatch()
        context.insert(batch)
        try context.save()

        context.delete(batch)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<FoodBatch>())
        XCTAssertTrue(fetched.isEmpty)
    }

    func testBatchEventRelationshipCascadesOnDelete() throws {
        let batch = TestFixtures.freshBatch()
        let event = FoodEvent(batchID: batch.id, type: .added)
        event.batch = batch
        context.insert(batch)
        context.insert(event)
        try context.save()

        context.delete(batch)
        try context.save()

        let events = try context.fetch(FetchDescriptor<FoodEvent>())
        XCTAssertTrue(events.isEmpty)
    }

    func testUnknownEnumRawValueFallsBackSafely() throws {
        let batch = TestFixtures.freshBatch()
        batch.storageLocationRawValue = "some_future_unknown_value"
        context.insert(batch)
        try context.save()

        XCTAssertEqual(batch.storageLocation, .counter)
    }

    func testProductionContainerIsNeverUsedByTests() {
        // Every test in this suite uses an in-memory container so the user's
        // real persistent store is never touched.
        XCTAssertTrue(container.configurations.allSatisfy(\.isStoredInMemoryOnly))
    }
}
