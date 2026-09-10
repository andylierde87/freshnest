import SwiftUI

struct MainTabView: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        @Bindable var router = router
        TabView(selection: $router.selectedTab) {
            Tab(AppTab.home.title, systemImage: AppTab.home.symbolName, value: .home) {
                NavigationStack(path: $router.homePath) {
                    HomeView()
                        .navigationDestination(for: FreshnestRoute.self, destination: destination)
                }
            }

            Tab(AppTab.kitchen.title, systemImage: AppTab.kitchen.symbolName, value: .kitchen) {
                NavigationStack(path: $router.kitchenPath) {
                    KitchenView()
                        .navigationDestination(for: FreshnestRoute.self, destination: destination)
                }
            }

            Tab(AppTab.scan.title, systemImage: AppTab.scan.symbolName, value: .scan) {
                NavigationStack {
                    ScanView()
                }
            }

            Tab(AppTab.rescue.title, systemImage: AppTab.rescue.symbolName, value: .rescue) {
                NavigationStack(path: $router.rescuePath) {
                    RescueView()
                        .navigationDestination(for: FreshnestRoute.self, destination: destination)
                }
            }

            Tab(AppTab.insights.title, systemImage: AppTab.insights.symbolName, value: .insights) {
                NavigationStack(path: $router.insightsPath) {
                    InsightsView()
                        .navigationDestination(for: FreshnestRoute.self, destination: destination)
                }
            }
        }
        .tint(FreshnestColors.accent)
    }

    @ViewBuilder
    private func destination(for route: FreshnestRoute) -> some View {
        switch route {
        case .foodDetails(let batchID):
            FoodDetailsView(batchID: batchID)
        case .addFood:
            AddFoodView()
        case .shoppingList:
            ShoppingListView()
        case .foodLibrary:
            FoodLibraryView()
        case .storageAdvisor:
            StorageAdvisorView()
        case .settings:
            SettingsView()
        }
    }
}
