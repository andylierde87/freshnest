import Foundation

/// Launch-argument switches used exclusively by XCUITest to make the app
/// deterministic: a clean in-memory store and mocked ML results instead of
/// the real camera/Vision pipeline.
enum LaunchEnvironment {
    static var isUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains("--uitesting")
    }

    static var skipOnboarding: Bool {
        ProcessInfo.processInfo.arguments.contains("--skip-onboarding")
    }

    static var seedSampleData: Bool {
        ProcessInfo.processInfo.arguments.contains("--seed-sample-data")
    }

    /// Wipes real `UserDefaults` at launch so a UI test never inherits state
    /// left behind by an earlier test run. Deliberately separate from
    /// `isUITesting` so a test can relaunch the app mid-test (e.g. to verify
    /// onboarding does not reappear) without losing what it just persisted.
    static var resetPersistentData: Bool {
        ProcessInfo.processInfo.arguments.contains("--reset-data")
    }

    /// UI tests can't reliably drive the system Photos picker across
    /// processes, so when a mock scan scenario is active this makes the Scan
    /// tab feed itself a placeholder image the moment it appears.
    static var autoTriggerMockScan: Bool {
        ProcessInfo.processInfo.arguments.contains("--auto-trigger-scan")
    }

    static var mockScanScenario: MockScanScenario? {
        guard
            let argument = ProcessInfo.processInfo.arguments.first(where: { $0.hasPrefix("--mock-scan=") }),
            let value = argument.split(separator: "=").last
        else { return nil }
        return MockScanScenario(rawValue: String(value))
    }
}

enum MockScanScenario: String {
    case highConfidenceBanana
    case lowConfidence
    case failure
}
