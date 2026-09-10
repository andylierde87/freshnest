import XCTest
@testable import Freshnest

final class StorageAdvisorTests: XCTestCase {
    private let advisor = DefaultStorageAdvisor()

    func testHighProducerWithHighSensitiveGeneratesWarning() {
        // Banana (high producer) + Avocado (high sensitivity) is the classic
        // incompatible pair called out in Section 40's example.
        let result = advisor.advise(for: [TestFixtures.bananaDefinition, TestFixtures.avocadoDefinition])
        XCTAssertFalse(result.warnings.isEmpty)
        XCTAssertEqual(result.compatibility, .fair)
    }

    func testCompatiblePairProducesNoFalseWarning() {
        // Two low-ethylene items (neither a meaningful producer nor sensitive)
        // should never trigger a compatibility warning.
        let lowA = FoodDefinition(
            id: "lowA", name: "Low A", category: .vegetable, aliases: [], iconName: "leaf.fill",
            defaultUnit: .piece, counterShelfLifeDays: 5, fridgeShelfLifeDays: 20, freezerShelfLifeDays: 100,
            ripeningDays: 0, ethyleneProduction: .none, ethyleneSensitivity: .low,
            storageTips: [], ripenessTips: [], freezingTips: [], rescueTags: []
        )
        let lowB = FoodDefinition(
            id: "lowB", name: "Low B", category: .vegetable, aliases: [], iconName: "leaf.fill",
            defaultUnit: .piece, counterShelfLifeDays: 5, fridgeShelfLifeDays: 20, freezerShelfLifeDays: 100,
            ripeningDays: 0, ethyleneProduction: .none, ethyleneSensitivity: .low,
            storageTips: [], ripenessTips: [], freezingTips: [], rescueTags: []
        )
        let result = advisor.advise(for: [lowA, lowB])
        XCTAssertTrue(result.warnings.isEmpty)
        XCTAssertEqual(result.compatibility, .good)
    }

    func testEmptySelectionReturnsValidEmptyResult() {
        let result = advisor.advise(for: [])
        XCTAssertTrue(result.warnings.isEmpty)
        XCTAssertTrue(result.recommendations.isEmpty)
        XCTAssertEqual(result.compatibility, .good)
    }

    func testSingleFoodGetsRecommendationAndNoWarning() {
        let result = advisor.advise(for: [TestFixtures.appleDefinition])
        XCTAssertEqual(result.recommendations.count, 1)
        XCTAssertTrue(result.warnings.isEmpty)
    }

    func testDuplicateFoodIDsAreHandledWithoutDuplicateWarnings() {
        let result = advisor.advise(for: [
            TestFixtures.bananaDefinition, TestFixtures.bananaDefinition, TestFixtures.avocadoDefinition,
        ])
        XCTAssertEqual(result.recommendations.count, 2)
        XCTAssertEqual(result.warnings.count, 1)
    }
}
