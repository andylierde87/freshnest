import XCTest
@testable import Freshnest

final class LaunchDecisionStoreTests: XCTestCase {
    private func makeDefaults() -> UserDefaults {
        let suiteName = "launch-test-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        return defaults
    }

    func testFreshnestDecisionPersistsWebURLAndState() {
        let defaults = makeDefaults()
        let store = LaunchDecisionStore(defaults: defaults)
        let url = URL(string: "https://example.com")!

        store.save(LaunchDecision(flow: .freshnest, url: url))

        let restored = LaunchDecisionStore(defaults: defaults)
        XCTAssertEqual(restored.decision, LaunchDecision(flow: .freshnest, url: url))
    }

    func testPantryDecisionPersistsDefaultState() {
        let defaults = makeDefaults()
        let store = LaunchDecisionStore(defaults: defaults)

        store.save(LaunchDecision(flow: .pantry, url: URL(string: "https://frshnest.xyz/#privacy")))

        let restored = LaunchDecisionStore(defaults: defaults)
        XCTAssertEqual(restored.decision?.flow, .pantry)
    }
}
