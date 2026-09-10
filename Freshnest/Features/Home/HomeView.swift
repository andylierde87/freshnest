import SwiftData
import SwiftUI

struct HomeView: View {
    @Environment(AppContainer.self) private var container
    @Environment(AppRouter.self) private var router
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.modelContext) private var modelContext

    @Query(
        filter: #Predicate<FoodBatch> { $0.statusRawValue == "active" },
        sort: \FoodBatch.purchaseDate
    )
    private var activeBatches: [FoodBatch]

    private var presenter: BatchFreshnessPresenter {
        BatchFreshnessPresenter(calculator: container.freshnessCalculator, repository: container.foodRepository)
    }

    private var sections: HomeSections {
        HomeContentBuilder.build(activeBatches: activeBatches, presenter: presenter, now: container.clock.now)
    }

    var body: some View {
        ScrollView {
            ReadableWidthContainer {
                VStack(alignment: .leading, spacing: FreshnestSpacing.xl) {
                    header

                    if activeBatches.isEmpty {
                        emptyState
                    } else {
                        let currentSections = sections
                        if !currentSections.attentionItems.isEmpty {
                            AttentionCard(
                                items: currentSections.attentionItems.map {
                                    AttentionItem(batchID: $0.batch.id, name: presenter.definition(for: $0.batch).name)
                                }
                            ) {
                                router.selectedTab = .kitchen
                            } onTapItem: { batchID in
                                router.showFoodDetails(batchID: batchID, from: .home)
                            }
                        }

                        if !currentSections.eatFirst.isEmpty {
                            SectionBlock(title: String(localized: "Eat First")) {
                                ForEach(currentSections.eatFirst) { scored in
                                    Button {
                                        router.showFoodDetails(batchID: scored.batch.id, from: .home)
                                    } label: {
                                        BatchSummaryRow(
                                            definition: presenter.definition(for: scored.batch),
                                            batch: scored.batch,
                                            result: scored.result
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }

                        if !currentSections.freshThisWeek.isEmpty {
                            SectionBlock(title: String(localized: "Fresh This Week")) {
                                ForEach(currentSections.freshThisWeek) { scored in
                                    Button {
                                        router.showFoodDetails(batchID: scored.batch.id, from: .home)
                                    } label: {
                                        BatchSummaryRow(
                                            definition: presenter.definition(for: scored.batch),
                                            batch: scored.batch,
                                            result: scored.result
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }

                    QuickActionsGrid()
                }
                .padding(.horizontal, FreshnestSpacing.screenHorizontalPadding(for: horizontalSizeClass))
                .padding(.bottom, FreshnestSpacing.xxl)
            }
        }
        .background(FreshnestColors.background)
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    router.homePath.append(.settings)
                } label: {
                    Image(systemName: "gearshape")
                }
                .accessibilityIdentifier("home.settingsButton")
                .accessibilityLabel(Text("Settings"))
            }
        }
        .onAppear {
            FreshnessScoreRefresher.refresh(activeBatches, presenter: presenter, now: container.clock.now)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(greeting)
                .font(FreshnestTypography.secondary)
                .foregroundStyle(FreshnestColors.secondaryText)
            Text("Freshnest")
                .font(FreshnestTypography.largeTitle)
                .foregroundStyle(FreshnestColors.primaryText)
        }
        .padding(.top, FreshnestSpacing.md)
        .accessibilityElement(children: .combine)
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: container.clock.now)
        switch hour {
        case 0..<12: return String(localized: "Good morning")
        case 12..<18: return String(localized: "Good afternoon")
        default: return String(localized: "Good evening")
        }
    }

    private var emptyState: some View {
        VStack(spacing: FreshnestSpacing.sm) {
            Image(systemName: "leaf")
                .font(.system(size: 40))
                .foregroundStyle(FreshnestColors.secondaryText)
            Text("Your kitchen is empty.")
                .font(FreshnestTypography.cardTitle)
                .foregroundStyle(FreshnestColors.primaryText)
            Text("Add fruits and vegetables to start tracking freshness.")
                .font(FreshnestTypography.secondary)
                .foregroundStyle(FreshnestColors.secondaryText)
                .multilineTextAlignment(.center)
            Button(String(localized: "Add Food")) {
                router.homePath.append(.addFood)
            }
            .buttonStyle(.freshnestPrimary)
            .padding(.top, FreshnestSpacing.xs)
            .accessibilityIdentifier("home.emptyState.addFoodButton")
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, FreshnestSpacing.xxl)
    }
}

private struct SectionBlock<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: FreshnestSpacing.sm) {
            Text(title)
                .font(FreshnestTypography.sectionTitle)
                .foregroundStyle(FreshnestColors.primaryText)
            VStack(spacing: FreshnestSpacing.sm) {
                content
            }
        }
    }
}

private struct AttentionItem: Identifiable {
    let batchID: UUID
    let name: String
    var id: UUID { batchID }
}

private struct AttentionCard: View {
    let items: [AttentionItem]
    let onViewItems: () -> Void
    let onTapItem: (UUID) -> Void

    var body: some View {
        FreshnestCard {
            VStack(alignment: .leading, spacing: FreshnestSpacing.sm) {
                Text("TODAY")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(FreshnestColors.warning)

                Text("\(items.count) item\(items.count == 1 ? "" : "s") need attention")
                    .font(FreshnestTypography.cardTitle)
                    .foregroundStyle(FreshnestColors.primaryText)

                ForEach(items.prefix(3)) { item in
                    Button {
                        onTapItem(item.batchID)
                    } label: {
                        Text(item.name)
                            .font(FreshnestTypography.body)
                            .foregroundStyle(FreshnestColors.primaryText)
                    }
                    .buttonStyle(.plain)
                }

                Button(String(localized: "View items"), action: onViewItems)
                    .font(FreshnestTypography.secondary.weight(.semibold))
                    .foregroundStyle(FreshnestColors.accent)
            }
        }
        .accessibilityIdentifier("home.attentionCard")
    }
}

private struct QuickActionsGrid: View {
    @Environment(AppRouter.self) private var router

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        VStack(alignment: .leading, spacing: FreshnestSpacing.sm) {
            Text("Quick Actions")
                .font(FreshnestTypography.sectionTitle)
                .foregroundStyle(FreshnestColors.primaryText)

            LazyVGrid(columns: columns, spacing: FreshnestSpacing.sm) {
                QuickActionButton(title: String(localized: "Scan Food"), symbol: "camera.viewfinder") {
                    router.selectedTab = .scan
                }
                .accessibilityIdentifier("home.scanFoodButton")

                QuickActionButton(title: String(localized: "Add Food"), symbol: "plus.circle") {
                    router.homePath.append(.addFood)
                }
                .accessibilityIdentifier("home.addFoodButton")

                QuickActionButton(title: String(localized: "Check Storage"), symbol: "refrigerator") {
                    router.homePath.append(.storageAdvisor)
                }
                .accessibilityIdentifier("home.checkStorageButton")

                QuickActionButton(title: String(localized: "Rescue Food"), symbol: "leaf") {
                    router.selectedTab = .rescue
                }
                .accessibilityIdentifier("home.rescueFoodButton")
            }
        }
    }
}

private struct QuickActionButton: View {
    let title: String
    let symbol: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: FreshnestSpacing.xs) {
                Image(systemName: symbol)
                    .font(.title2)
                Text(title)
                    .font(FreshnestTypography.secondary.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, FreshnestSpacing.md)
        }
        .buttonStyle(.freshnestSecondary)
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
    .environment(AppContainer.makePreview())
    .environment(AppRouter())
}
