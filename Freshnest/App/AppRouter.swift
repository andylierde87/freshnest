import Foundation

enum AppTab: String, CaseIterable, Identifiable {
    case home
    case kitchen
    case scan
    case rescue
    case insights

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home: return String(localized: "Home")
        case .kitchen: return String(localized: "Kitchen")
        case .scan: return String(localized: "Scan")
        case .rescue: return String(localized: "Rescue")
        case .insights: return String(localized: "Insights")
        }
    }

    var symbolName: String {
        switch self {
        case .home: return "house"
        case .kitchen: return "refrigerator"
        case .scan: return "camera.viewfinder"
        case .rescue: return "leaf"
        case .insights: return "chart.bar"
        }
    }
}

enum FreshnestRoute: Hashable {
    case foodDetails(batchID: UUID)
    case addFood
    case shoppingList
    case foodLibrary
    case storageAdvisor
    case settings
}

@MainActor
@Observable
final class AppRouter {
    var selectedTab: AppTab = .home

    var homePath: [FreshnestRoute] = []
    var kitchenPath: [FreshnestRoute] = []
    var scanPath: [FreshnestRoute] = []
    var rescuePath: [FreshnestRoute] = []
    var insightsPath: [FreshnestRoute] = []

    func showFoodDetails(batchID: UUID, from tab: AppTab? = nil) {
        let targetTab = tab ?? selectedTab
        selectedTab = targetTab
        switch targetTab {
        case .home: homePath.append(.foodDetails(batchID: batchID))
        case .kitchen: kitchenPath.append(.foodDetails(batchID: batchID))
        case .scan: scanPath.append(.foodDetails(batchID: batchID))
        case .rescue: rescuePath.append(.foodDetails(batchID: batchID))
        case .insights: insightsPath.append(.foodDetails(batchID: batchID))
        }
    }
}
