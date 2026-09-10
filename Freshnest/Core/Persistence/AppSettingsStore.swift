import Foundation
import Observation

enum AppColorSchemePreference: String, CaseIterable, Sendable {
    case system
    case light
    case dark

    var displayName: String {
        switch self {
        case .system: return String(localized: "System")
        case .light: return String(localized: "Light")
        case .dark: return String(localized: "Dark")
        }
    }
}

/// Thin, testable wrapper around `UserDefaults` for all user-configurable
/// app settings. Values are mirrored into `@Observable` stored properties
/// (not computed ones) so SwiftUI actually re-renders when they change.
@Observable
final class AppSettingsStore: @unchecked Sendable {
    private let defaults: UserDefaults

    private enum Keys {
        static let hasCompletedOnboarding = "settings.hasCompletedOnboarding"
        static let storeScanPhotos = "settings.storeScanPhotos"
        static let remindersEnabled = "settings.remindersEnabled"
        static let dailySummaryEnabled = "settings.dailySummaryEnabled"
        static let reminderHour = "settings.reminderHour"
        static let reminderMinute = "settings.reminderMinute"
        static let colorSchemePreference = "settings.colorSchemePreference"
    }

    var hasCompletedOnboarding: Bool {
        didSet { defaults.set(hasCompletedOnboarding, forKey: Keys.hasCompletedOnboarding) }
    }

    var storeScanPhotos: Bool {
        didSet { defaults.set(storeScanPhotos, forKey: Keys.storeScanPhotos) }
    }

    var remindersEnabled: Bool {
        didSet { defaults.set(remindersEnabled, forKey: Keys.remindersEnabled) }
    }

    var dailySummaryEnabled: Bool {
        didSet { defaults.set(dailySummaryEnabled, forKey: Keys.dailySummaryEnabled) }
    }

    var reminderHour: Int {
        didSet { defaults.set(reminderHour, forKey: Keys.reminderHour) }
    }

    var reminderMinute: Int {
        didSet { defaults.set(reminderMinute, forKey: Keys.reminderMinute) }
    }

    var colorSchemePreference: AppColorSchemePreference {
        didSet { defaults.set(colorSchemePreference.rawValue, forKey: Keys.colorSchemePreference) }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        defaults.register(defaults: [
            Keys.storeScanPhotos: true,
            Keys.remindersEnabled: false,
            Keys.dailySummaryEnabled: false,
            Keys.reminderHour: 9,
            Keys.reminderMinute: 0,
            Keys.colorSchemePreference: AppColorSchemePreference.system.rawValue,
        ])

        hasCompletedOnboarding = defaults.bool(forKey: Keys.hasCompletedOnboarding)
        storeScanPhotos = defaults.bool(forKey: Keys.storeScanPhotos)
        remindersEnabled = defaults.bool(forKey: Keys.remindersEnabled)
        dailySummaryEnabled = defaults.bool(forKey: Keys.dailySummaryEnabled)
        reminderHour = defaults.integer(forKey: Keys.reminderHour)
        reminderMinute = defaults.integer(forKey: Keys.reminderMinute)
        colorSchemePreference = AppColorSchemePreference(
            rawValue: defaults.string(forKey: Keys.colorSchemePreference) ?? ""
        ) ?? .system
    }

    var notificationSettings: NotificationSettings {
        NotificationSettings(
            remindersEnabled: remindersEnabled,
            dailySummaryEnabled: dailySummaryEnabled,
            reminderHour: reminderHour,
            reminderMinute: reminderMinute
        )
    }

    /// Resets user preferences back to defaults. Used by Settings > Delete
    /// All Data. Deliberately leaves `hasCompletedOnboarding` untouched —
    /// clearing kitchen data should not force the user back through
    /// onboarding.
    func resetAll() {
        for key in [
            Keys.storeScanPhotos, Keys.remindersEnabled,
            Keys.dailySummaryEnabled, Keys.reminderHour, Keys.reminderMinute, Keys.colorSchemePreference,
        ] {
            defaults.removeObject(forKey: key)
        }
        storeScanPhotos = true
        remindersEnabled = false
        dailySummaryEnabled = false
        reminderHour = 9
        reminderMinute = 0
        colorSchemePreference = .system
    }
}
