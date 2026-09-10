import SwiftData
import SwiftUI

struct KitchenView: View {
    @Environment(AppContainer.self) private var container
    @Environment(AppRouter.self) private var router
    @Environment(\.modelContext) private var modelContext
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @Query(
        filter: #Predicate<FoodBatch> { $0.statusRawValue == "active" }
    )
    private var activeBatches: [FoodBatch]

    @State private var filter: KitchenFilter = .all
    @State private var sort: KitchenSort = .freshness
    @State private var pendingDiscard: FoodBatch?

    private var presenter: BatchFreshnessPresenter {
        BatchFreshnessPresenter(calculator: container.freshnessCalculator, repository: container.foodRepository)
    }

    private var items: [ScoredBatch] {
        KitchenContentBuilder.build(
            activeBatches: activeBatches,
            filter: filter,
            sort: sort,
            presenter: presenter,
            now: container.clock.now
        )
    }

    private var columns: [GridItem] {
        horizontalSizeClass == .regular
            ? [GridItem(.adaptive(minimum: 320), spacing: FreshnestSpacing.sm)]
            : [GridItem(.flexible())]
    }

    var body: some View {
        VStack(spacing: 0) {
            filterBar

            if activeBatches.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: FreshnestSpacing.sm) {
                        ForEach(items) { scored in
                            Button {
                                router.showFoodDetails(batchID: scored.batch.id, from: .kitchen)
                            } label: {
                                BatchSummaryRow(
                                    definition: presenter.definition(for: scored.batch),
                                    batch: scored.batch,
                                    result: scored.result
                                )
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                batchActions(for: scored.batch)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    pendingDiscard = scored.batch
                                } label: {
                                    Label("Discard", systemImage: "trash")
                                }

                                Button {
                                    _ = try? FoodBatchMutationService(modelContext: modelContext, clock: container.clock)
                                        .ateOne(scored.batch)
                                } label: {
                                    Label("Ate", systemImage: "checkmark")
                                }
                                .tint(FreshnestColors.success)
                            }
                        }
                    }
                    .padding(FreshnestSpacing.md)
                }
            }
        }
        .navigationTitle("Kitchen")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Picker(String(localized: "Sort"), selection: $sort) {
                        ForEach(KitchenSort.allCases) { option in
                            Text(option.title).tag(option)
                        }
                    }
                } label: {
                    Label("Sort", systemImage: "arrow.up.arrow.down")
                }
                .accessibilityIdentifier("kitchen.sortMenu")
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    router.kitchenPath.append(.addFood)
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityIdentifier("kitchen.addFoodButton")
            }
        }
        .background(FreshnestColors.background)
        .confirmationDialog(
            "Why are you discarding this?",
            isPresented: Binding(get: { pendingDiscard != nil }, set: { if !$0 { pendingDiscard = nil } }),
            titleVisibility: .visible
        ) {
            ForEach(WasteReason.allCases, id: \.self) { reason in
                Button(reason.displayName) {
                    if let batch = pendingDiscard {
                        _ = try? FoodBatchMutationService(modelContext: modelContext, clock: container.clock)
                            .discardAll(batch, reason: reason)
                    }
                    pendingDiscard = nil
                }
            }
        }
    }

    @ViewBuilder
    private func batchActions(for batch: FoodBatch) -> some View {
        Button {
            router.showFoodDetails(batchID: batch.id, from: .kitchen)
        } label: {
            Label("Edit", systemImage: "pencil")
        }
        Button {
            _ = try? FoodBatchMutationService(modelContext: modelContext, clock: container.clock).ateOne(batch)
        } label: {
            Label("Ate", systemImage: "checkmark")
        }
        Button(role: .destructive) {
            pendingDiscard = batch
        } label: {
            Label("Discard", systemImage: "trash")
        }
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: FreshnestSpacing.xs) {
                ForEach(KitchenFilter.allCases) { option in
                    FilterChip(title: option.title, isSelected: filter == option) {
                        filter = option
                    }
                    .accessibilityIdentifier("kitchen.filter.\(option.rawValue)")
                }
            }
            .padding(.horizontal, FreshnestSpacing.md)
            .padding(.vertical, FreshnestSpacing.xs)
        }
    }

    private var emptyState: some View {
        VStack(spacing: FreshnestSpacing.sm) {
            Spacer()
            Image(systemName: "refrigerator")
                .font(.system(size: 40))
                .foregroundStyle(FreshnestColors.secondaryText)
            Text("Your kitchen is empty.")
                .font(FreshnestTypography.cardTitle)
            Text("Add fruits and vegetables to start tracking freshness.")
                .font(FreshnestTypography.secondary)
                .foregroundStyle(FreshnestColors.secondaryText)
                .multilineTextAlignment(.center)
            Button(String(localized: "Add Food")) {
                router.kitchenPath.append(.addFood)
            }
            .buttonStyle(.freshnestPrimary)
            .padding(.horizontal, FreshnestSpacing.xxl)
            .padding(.top, FreshnestSpacing.xs)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}

#Preview {
    NavigationStack {
        KitchenView()
    }
    .environment(AppContainer.makePreview())
    .environment(AppRouter())
}
