import XCTest
@testable import Freshnest

final class FoodSearchTests: XCTestCase {
    private let definitions = TestFixtures.allDefinitions

    func testLowercaseQueryFindsApple() {
        let results = FoodSearchEngine.search("apple", in: definitions)
        XCTAssertEqual(results.first?.id, "apple")
    }

    func testUppercaseQueryFindsApple() {
        let results = FoodSearchEngine.search("APPLE", in: definitions)
        XCTAssertEqual(results.first?.id, "apple")
    }

    func testWhitespaceIsTrimmed() {
        let results = FoodSearchEngine.search(" apple ", in: definitions)
        XCTAssertEqual(results.first?.id, "apple")
    }

    func testAliasMatchesTomatoStylePlural() {
        let results = FoodSearchEngine.search("avocados", in: definitions)
        XCTAssertEqual(results.first?.id, "avocado")
    }

    func testPartialQueryRanksAvocadoHighly() {
        let results = FoodSearchEngine.search("avo", in: definitions)
        XCTAssertEqual(results.first?.id, "avocado")
    }

    func testUnknownQueryReturnsEmptyResult() {
        let results = FoodSearchEngine.search("xyznotafood", in: definitions)
        XCTAssertTrue(results.isEmpty)
    }

    func testExactMatchRanksAboveAliasAndPartialMatch() {
        let custom = [
            FoodDefinition(
                id: "berry-alias-food", name: "Berry Alias Food", category: .fruit,
                aliases: ["ber"], iconName: "leaf.fill", defaultUnit: .piece,
                counterShelfLifeDays: 1, fridgeShelfLifeDays: 1, freezerShelfLifeDays: 1, ripeningDays: 0,
                ethyleneProduction: .none, ethyleneSensitivity: .none,
                storageTips: [], ripenessTips: [], freezingTips: [], rescueTags: []
            ),
            FoodDefinition(
                id: "ber", name: "Ber", category: .fruit,
                aliases: [], iconName: "leaf.fill", defaultUnit: .piece,
                counterShelfLifeDays: 1, fridgeShelfLifeDays: 1, freezerShelfLifeDays: 1, ripeningDays: 0,
                ethyleneProduction: .none, ethyleneSensitivity: .none,
                storageTips: [], ripenessTips: [], freezingTips: [], rescueTags: []
            ),
        ]
        let results = FoodSearchEngine.search("ber", in: custom)
        XCTAssertEqual(results.first?.id, "ber")
    }
}
