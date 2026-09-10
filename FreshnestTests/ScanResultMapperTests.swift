import XCTest
@testable import Freshnest

final class ScanResultMapperTests: XCTestCase {
    func testHighConfidenceSelectsStrongMatch() {
        let outcome = ScanResultMapper.mapClassification(TestFixtures.mockHighConfidenceScan)
        guard case .strongMatch(let foodID, let confidence) = outcome else {
            return XCTFail("Expected strong match")
        }
        XCTAssertEqual(foodID, "banana")
        XCTAssertEqual(confidence, 0.94, accuracy: 0.0001)
    }

    func testMediumConfidenceRequiresConfirmation() {
        let result = FoodClassificationResult(candidates: [FoodClassificationCandidate(foodID: "banana", confidence: 0.7)])
        let outcome = ScanResultMapper.mapClassification(result)
        guard case .suggestedMatch(let foodID, _) = outcome else {
            return XCTFail("Expected suggested match")
        }
        XCTAssertEqual(foodID, "banana")
    }

    func testLowConfidenceDoesNotAutoSelect() {
        let outcome = ScanResultMapper.mapClassification(TestFixtures.mockLowConfidenceScan)
        XCTAssertEqual(outcome, .needsManualSelection)
    }

    func testNoCandidatesFails() {
        let outcome = ScanResultMapper.mapClassification(FoodClassificationResult(candidates: []))
        XCTAssertEqual(outcome, .failed)
    }

    func testFreshnessScoreOutsideRangeIsClamped() {
        XCTAssertEqual(ScanResultMapper.mapFreshnessScore(150), 100)
        XCTAssertEqual(ScanResultMapper.mapFreshnessScore(-20), 0)
    }

    func testUnknownObservationIsPassedThroughSafely() {
        let observations = ScanResultMapper.safeObservations([.unknown])
        XCTAssertEqual(observations, [.unknown])
    }

    func testEmptyObservationsStaysEmpty() {
        XCTAssertTrue(ScanResultMapper.safeObservations([]).isEmpty)
    }
}
