import XCTest
@testable import Freshnest

final class FreshnessStateTests: XCTestCase {
    func testScore100IsVeryFresh() { XCTAssertEqual(FreshnessStateMapper.state(forScore: 100), .veryFresh) }
    func testScore90IsVeryFresh() { XCTAssertEqual(FreshnessStateMapper.state(forScore: 90), .veryFresh) }
    func testScore89IsFresh() { XCTAssertEqual(FreshnessStateMapper.state(forScore: 89), .fresh) }
    func testScore75IsFresh() { XCTAssertEqual(FreshnessStateMapper.state(forScore: 75), .fresh) }
    func testScore74IsUseSoon() { XCTAssertEqual(FreshnessStateMapper.state(forScore: 74), .useSoon) }
    func testScore55IsUseSoon() { XCTAssertEqual(FreshnessStateMapper.state(forScore: 55), .useSoon) }
    func testScore54IsEatToday() { XCTAssertEqual(FreshnessStateMapper.state(forScore: 54), .eatToday) }
    func testScore30IsEatToday() { XCTAssertEqual(FreshnessStateMapper.state(forScore: 30), .eatToday) }
    func testScore29IsCheckCarefully() { XCTAssertEqual(FreshnessStateMapper.state(forScore: 29), .checkCarefully) }
    func testScore0IsCheckCarefully() { XCTAssertEqual(FreshnessStateMapper.state(forScore: 0), .checkCarefully) }

    func testClampsBelowZero() { XCTAssertEqual(FreshnessStateMapper.clamp(-10), 0) }
    func testClampsAboveOneHundred() { XCTAssertEqual(FreshnessStateMapper.clamp(120), 100) }

    func testNegativeScoreStillMapsToCheckCarefully() {
        XCTAssertEqual(FreshnessStateMapper.state(forScore: -10), .checkCarefully)
    }

    func testOverOneHundredStillMapsToVeryFresh() {
        XCTAssertEqual(FreshnessStateMapper.state(forScore: 120), .veryFresh)
    }
}
