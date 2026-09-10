import Foundation
import SwiftData

/// Single composition root. Every screen reads its dependencies from here
/// (via the SwiftUI environment) instead of reaching for singletons, so
/// tests and previews can swap in fakes.
@MainActor
@Observable
final class AppContainer {
    let modelContainer: ModelContainer
    let foodRepository: FoodRepository
    let settingsStore: AppSettingsStore
    let notificationCoordinator: NotificationCoordinator
    let scanPhotoStore: ScanPhotoStoring

    let clock: ClockProviding
    let freshnessCalculator: FreshnessCalculating
    let storageAdvisor: StorageAdvising
    let rescueEngine: RescueSuggesting
    let insightsCalculator: InsightsCalculating

    let foodClassifier: FoodClassifying
    let freshnessAnalyzer: FreshnessAnalyzing

    init(
        modelContainer: ModelContainer,
        foodRepository: FoodRepository,
        settingsStore: AppSettingsStore = AppSettingsStore(),
        notificationCoordinator: NotificationCoordinator? = nil,
        scanPhotoStore: ScanPhotoStoring = FileSystemScanPhotoStore(),
        clock: ClockProviding = SystemClock(),
        freshnessCalculator: FreshnessCalculating = DefaultFreshnessCalculator(),
        storageAdvisor: StorageAdvising = DefaultStorageAdvisor(),
        rescueEngine: RescueSuggesting = DefaultRescueEngine(),
        insightsCalculator: InsightsCalculating = DefaultInsightsCalculator(),
        foodClassifier: FoodClassifying? = nil,
        freshnessAnalyzer: FreshnessAnalyzing? = nil
    ) {
        self.modelContainer = modelContainer
        self.foodRepository = foodRepository
        self.settingsStore = settingsStore
        self.notificationCoordinator = notificationCoordinator ?? NotificationCoordinator()
        self.scanPhotoStore = scanPhotoStore
        self.clock = clock
        self.freshnessCalculator = freshnessCalculator
        self.storageAdvisor = storageAdvisor
        self.rescueEngine = rescueEngine
        self.insightsCalculator = insightsCalculator
        self.foodClassifier = foodClassifier ?? VisionFoodClassifier(definitions: foodRepository.definitions)
        self.freshnessAnalyzer = freshnessAnalyzer ?? HeuristicFreshnessAnalyzer()
    }

    @MainActor
    static func makeDefault() -> AppContainer {
        let modelContainer = ModelContainerFactory.makeContainer()
        let repository = FoodRepository()
        return AppContainer(modelContainer: modelContainer, foodRepository: repository)
    }

    @MainActor
    static func makePreview() -> AppContainer {
        let modelContainer = ModelContainerFactory.makeContainer(inMemory: true)
        let repository = FoodRepository()
        return AppContainer(
            modelContainer: modelContainer,
            foodRepository: repository,
            settingsStore: AppSettingsStore(defaults: UserDefaults(suiteName: "preview") ?? .standard)
        )
    }
}
