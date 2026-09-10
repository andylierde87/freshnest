import SwiftData
import SwiftUI

@main
struct FreshnestApp: App {
    @State private var container: AppContainer
    @State private var router = AppRouter()

    init() {
        _container = State(initialValue: FreshnestApp.buildContainer())
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(container)
                .environment(router)
                .modelContainer(container.modelContainer)
                .preferredColorScheme(container.settingsStore.colorSchemePreference.colorScheme)
        }
    }

    @MainActor
    private static func buildContainer() -> AppContainer {
        let inMemory = LaunchEnvironment.isUITesting
        if LaunchEnvironment.resetPersistentData, let bundleID = Bundle.main.bundleIdentifier {
            // Guarantees a UI test starts from a truly clean slate, regardless
            // of what earlier runs left in the simulator.
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }

        let modelContainer = ModelContainerFactory.makeContainer(inMemory: inMemory)
        let repository = FoodRepository()
        let settingsStore = AppSettingsStore()

        // Only forces onboarding to be skipped when explicitly requested —
        // never forces it back to incomplete, so a UI test can relaunch the
        // app and still see onboarding-completed state it just persisted.
        if LaunchEnvironment.skipOnboarding {
            settingsStore.hasCompletedOnboarding = true
        }

        var foodClassifier: FoodClassifying?
        var freshnessAnalyzer: FreshnessAnalyzing?

        #if DEBUG
        if let scenario = LaunchEnvironment.mockScanScenario {
            switch scenario {
            case .highConfidenceBanana:
                foodClassifier = FakeFoodClassifier.highConfidence(foodID: "banana", confidence: 0.94)
                freshnessAnalyzer = FakeFreshnessAnalyzer.result(score: 78, observations: [.yellowing, .brownSpots])
            case .lowConfidence:
                foodClassifier = FakeFoodClassifier.lowConfidence(foodID: "banana", confidence: 0.32)
                freshnessAnalyzer = FakeFreshnessAnalyzer.result(score: 60)
            case .failure:
                foodClassifier = FakeFoodClassifier.empty
                freshnessAnalyzer = FakeFreshnessAnalyzer.failing
            }
        }
        #endif

        return AppContainer(
            modelContainer: modelContainer,
            foodRepository: repository,
            settingsStore: settingsStore,
            foodClassifier: foodClassifier,
            freshnessAnalyzer: freshnessAnalyzer
        )
    }
}

private extension AppColorSchemePreference {
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}
