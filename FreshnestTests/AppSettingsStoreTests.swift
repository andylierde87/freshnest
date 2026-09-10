import XCTest
@testable import Freshnest

final class AppSettingsStoreTests: XCTestCase {
    private func makeStore() -> AppSettingsStore {
        let suiteName = "test-suite-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        return AppSettingsStore(defaults: defaults)
    }

    func testStoreScanPhotosDefaultsToTrue() {
        XCTAssertTrue(makeStore().storeScanPhotos)
    }

    func testTogglingRemindersPersists() {
        let store = makeStore()
        store.remindersEnabled = true
        XCTAssertTrue(store.remindersEnabled)
    }

    func testResetAllRestoresDefaults() {
        let store = makeStore()
        store.storeScanPhotos = false
        store.remindersEnabled = true
        store.resetAll()
        XCTAssertTrue(store.storeScanPhotos)
        XCTAssertFalse(store.remindersEnabled)
    }

    func testResetAllDoesNotResetOnboardingCompletion() {
        // Deleting kitchen data should not force the user back through
        // onboarding.
        let store = makeStore()
        store.hasCompletedOnboarding = true
        store.resetAll()
        XCTAssertTrue(store.hasCompletedOnboarding)
    }
}
