import XCTest
@testable import Freshnest

final class InsightsCalculatorTests: XCTestCase {
    private let calculator = DefaultInsightsCalculator()
    private let now = Date(timeIntervalSince1970: 1_700_000_000)

    func testUseRateIsEightyPercentForEightConsumedTwoDiscarded() {
        let consumed = (0..<8).map { _ in FoodUsageRecord(foodDefinitionID: "apple", quantity: 1, date: now) }
        let discarded = (0..<2).map { _ in WasteRecord(foodDefinitionID: "apple", quantity: 1, date: now, reason: .spoiled) }
        let result = calculator.calculate(InsightsInput(consumed: consumed, discarded: discarded))
        XCTAssertEqual(result.useRate, 0.8, accuracy: 0.0001)
    }

    func testZeroConsumedAndZeroDiscardedDoesNotDivideByZero() {
        let result = calculator.calculate(InsightsInput())
        XCTAssertEqual(result.useRate, 0)
        XCTAssertEqual(result.consumedQuantity, 0)
        XCTAssertEqual(result.discardedQuantity, 0)
    }

    func testMostUsedFoodIsHighestQuantityConsumed() {
        let consumed = [
            FoodUsageRecord(foodDefinitionID: "apple", quantity: 2, date: now),
            FoodUsageRecord(foodDefinitionID: "banana", quantity: 5, date: now),
        ]
        let result = calculator.calculate(InsightsInput(consumed: consumed))
        XCTAssertEqual(result.mostUsedFoodID, "banana")
    }

    func testMostWastedFoodIsHighestQuantityDiscarded() {
        let discarded = [
            WasteRecord(foodDefinitionID: "apple", quantity: 1, date: now, reason: .spoiled),
            WasteRecord(foodDefinitionID: "broccoli", quantity: 4, date: now, reason: .forgotten),
        ]
        let result = calculator.calculate(InsightsInput(discarded: discarded))
        XCTAssertEqual(result.mostWastedFoodID, "broccoli")
    }

    func testDiscardReasonsAreAggregatedByCount() {
        let discarded = [
            WasteRecord(foodDefinitionID: "apple", quantity: 1, date: now, reason: .spoiled),
            WasteRecord(foodDefinitionID: "banana", quantity: 1, date: now, reason: .spoiled),
            WasteRecord(foodDefinitionID: "broccoli", quantity: 1, date: now, reason: .forgotten),
        ]
        let result = calculator.calculate(InsightsInput(discarded: discarded))
        XCTAssertEqual(result.discardReasonCounts[.spoiled], 2)
        XCTAssertEqual(result.discardReasonCounts[.forgotten], 1)
    }

    func testDateRangeFiltersOutRecordsOutsideTheRange() {
        let inRange = Date(timeIntervalSince1970: 1_700_100_000)
        let outOfRange = Date(timeIntervalSince1970: 1_600_000_000)
        let consumed = [
            FoodUsageRecord(foodDefinitionID: "apple", quantity: 3, date: inRange),
            FoodUsageRecord(foodDefinitionID: "apple", quantity: 10, date: outOfRange),
        ]
        let range = now...Date(timeIntervalSince1970: 1_700_200_000)
        let result = calculator.calculate(InsightsInput(consumed: consumed, dateRange: range))
        XCTAssertEqual(result.consumedQuantity, 3)
    }

    func testRescueRateComputesFromOutcomes() {
        let outcomes = [
            RescueOutcome(wasRescued: true),
            RescueOutcome(wasRescued: true),
            RescueOutcome(wasRescued: false),
            RescueOutcome(wasRescued: false),
        ]
        let result = calculator.calculate(InsightsInput(rescueOutcomes: outcomes))
        XCTAssertEqual(result.rescueRate, 0.5, accuracy: 0.0001)
    }

    func testEmptyRescueOutcomesYieldZeroRescueRate() {
        let result = calculator.calculate(InsightsInput())
        XCTAssertEqual(result.rescueRate, 0)
    }
}
