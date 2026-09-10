import XCTest

extension XCUIApplication {
    /// Launches with a clean, in-memory data store so UI tests never touch
    /// real user data and never depend on prior test runs.
    func launchForTesting(skipOnboarding: Bool = true, seedSampleData: Bool = false, mockScan: String? = nil) {
        launchArguments += ["--uitesting", "--reset-data"]
        if skipOnboarding { launchArguments += ["--skip-onboarding"] }
        if seedSampleData { launchArguments += ["--seed-sample-data"] }
        if let mockScan {
            launchArguments += ["--mock-scan=\(mockScan)", "--auto-trigger-scan"]
        }
        launch()
    }
}

extension XCUIElement {
    /// Polls until the element is both present and hittable (e.g. no longer
    /// obscured by a lingering keyboard), rather than just existing.
    @discardableResult
    func waitForHittable(timeout: TimeInterval) -> Bool {
        let predicate = NSPredicate(format: "exists == true AND isHittable == true")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: self)
        return XCTWaiter().wait(for: [expectation], timeout: timeout) == .completed
    }
}
