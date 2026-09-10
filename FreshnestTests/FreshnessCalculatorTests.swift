import XCTest
@testable import Freshnest

final class FreshnessCalculatorTests: XCTestCase {
    private let calculator = DefaultFreshnessCalculator()
    private let now = Date(timeIntervalSince1970: 1_700_000_000)

    private func input(
        food: FoodDefinition = TestFixtures.appleDefinition,
        purchaseDaysAgo: Int = 0,
        storage: StorageLocation = .fridge,
        ripeness: RipenessState = .ripe,
        manualCheck: ManualCheckInput? = nil,
        photoScan: PhotoScanInput? = nil
    ) -> FreshnessInput {
        let purchaseDate = Calendar.freshnestUTC.date(byAdding: .day, value: -purchaseDaysAgo, to: now) ?? now
        return FreshnessInput(
            foodDefinition: food,
            purchaseDate: purchaseDate,
            storageLocation: storage,
            initialRipeness: ripeness,
            latestManualCheck: manualCheck,
            latestPhotoScan: photoScan,
            currentDate: now
        )
    }

    func testFreshProduceScoresHighAndInRange() {
        let result = calculator.freshness(for: input(purchaseDaysAgo: 0))
        XCTAssertGreaterThanOrEqual(result.score, 90)
        XCTAssertLessThanOrEqual(result.score, 100)
    }

    func testAgeDecayNeverFavorsOlderBatch() {
        let newer = calculator.freshness(for: input(purchaseDaysAgo: 1))
        let older = calculator.freshness(for: input(purchaseDaysAgo: 10))
        XCTAssertLessThanOrEqual(older.score, newer.score)
    }

    func testCorrectStorageScoresAtLeastAsWellAsPoorStorage() {
        // Fridge has a longer shelf life than counter for apples, so identical
        // elapsed time should never leave fridge storage worse off.
        let fridge = calculator.freshness(for: input(purchaseDaysAgo: 5, storage: .fridge))
        let counter = calculator.freshness(for: input(purchaseDaysAgo: 5, storage: .counter))
        XCTAssertGreaterThanOrEqual(fridge.score, counter.score)
    }

    func testLowPhotoAssessmentReducesEffectiveScore() {
        let withoutScan = calculator.freshness(for: input(purchaseDaysAgo: 1))
        let withLowScan = calculator.freshness(for: input(
            purchaseDaysAgo: 1,
            photoScan: PhotoScanInput(score: 10, date: now)
        ))
        XCTAssertLessThan(withLowScan.score, withoutScan.score)
    }

    func testManualUseSoonMovesScoreDown() {
        let baseline = calculator.freshness(for: input(purchaseDaysAgo: 1))
        let withCheck = calculator.freshness(for: input(
            purchaseDaysAgo: 1,
            manualCheck: ManualCheckInput(state: .useSoon, date: now)
        ))
        XCTAssertLessThan(withCheck.score, baseline.score)
    }

    func testManualFreshMovesScoreUp() {
        let baseline = calculator.freshness(for: input(purchaseDaysAgo: 3))
        let withCheck = calculator.freshness(for: input(
            purchaseDaysAgo: 3,
            manualCheck: ManualCheckInput(state: .fresh, date: now)
        ))
        XCTAssertGreaterThan(withCheck.score, baseline.score)
    }

    func testScoreNeverExceedsValidRange() {
        let result = calculator.freshness(for: input(
            purchaseDaysAgo: 0,
            ripeness: .unripe,
            manualCheck: ManualCheckInput(state: .fresh, date: now)
        ))
        XCTAssertGreaterThanOrEqual(result.score, 0)
        XCTAssertLessThanOrEqual(result.score, 100)
    }

    func testScoreNeverGoesBelowZero() {
        let result = calculator.freshness(for: input(
            purchaseDaysAgo: 400,
            manualCheck: ManualCheckInput(state: .spoiled, date: now)
        ))
        XCTAssertGreaterThanOrEqual(result.score, 0)
    }

    func testSameInputAndClockAreDeterministic() {
        let first = calculator.freshness(for: input(purchaseDaysAgo: 4))
        let second = calculator.freshness(for: input(purchaseDaysAgo: 4))
        XCTAssertEqual(first, second)
    }
}
