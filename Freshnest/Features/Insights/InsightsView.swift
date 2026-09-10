import SwiftData
import SwiftUI

struct InsightsView: View {
    @Environment(AppContainer.self) private var container

    @Query private var allBatches: [FoodBatch]
    @Query(filter: #Predicate<FoodEvent> { $0.typeRawValue == "eaten" })
    private var eatenEvents: [FoodEvent]
    @Query(filter: #Predicate<FoodEvent> { $0.typeRawValue == "scanned" })
    private var scannedEvents: [FoodEvent]
    @Query private var wasteEvents: [WasteEvent]

    private var batchByID: [UUID: FoodBatch] {
        Dictionary(uniqueKeysWithValues: allBatches.map { ($0.id, $0) })
    }

    private var insights: InsightsResult {
        let consumed: [FoodUsageRecord] = eatenEvents.compactMap { event in
            guard let batch = batchByID[event.batchID] else { return nil }
            return FoodUsageRecord(foodDefinitionID: batch.foodDefinitionID, quantity: event.quantity ?? 1, date: event.createdAt)
        }

        let discarded: [WasteRecord] = wasteEvents.map {
            WasteRecord(foodDefinitionID: $0.foodDefinitionID, quantity: $0.quantity, date: $0.date, reason: $0.reason)
        }

        let scannedBatchIDs = Set(scannedEvents.map(\.batchID))
        let rescueOutcomes: [RescueOutcome] = allBatches
            .filter { $0.status != .active && scannedBatchIDs.contains($0.id) }
            .map { RescueOutcome(wasRescued: $0.status == .finished) }

        return container.insightsCalculator.calculate(
            InsightsInput(consumed: consumed, discarded: discarded, rescueOutcomes: rescueOutcomes)
        )
    }

    var body: some View {
        ScrollView {
            if eatenEvents.isEmpty && wasteEvents.isEmpty {
                emptyState
            } else {
                VStack(spacing: FreshnestSpacing.sm) {
                    metricsGrid
                    discardReasonsCard
                }
                .padding(FreshnestSpacing.md)
            }
        }
        .navigationTitle("Insights")
        .background(FreshnestColors.background)
    }

    private var metricsGrid: some View {
        let result = insights
        return LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: FreshnestSpacing.sm) {
            MetricTile(title: String(localized: "Use Rate"), value: percentString(result.useRate))
            MetricTile(title: String(localized: "Rescue Rate"), value: percentString(result.rescueRate))
            MetricTile(title: String(localized: "Consumed"), value: result.consumedQuantity.formattedQuantity)
            MetricTile(title: String(localized: "Discarded"), value: result.discardedQuantity.formattedQuantity)
            MetricTile(
                title: String(localized: "Most Used"),
                value: result.mostUsedFoodID.map { container.foodRepository.definition(for: $0).name } ?? "—"
            )
            MetricTile(
                title: String(localized: "Most Wasted"),
                value: result.mostWastedFoodID.map { container.foodRepository.definition(for: $0).name } ?? "—"
            )
        }
    }

    private var discardReasonsCard: some View {
        let counts = insights.discardReasonCounts
        return Group {
            if !counts.isEmpty {
                FreshnestCard {
                    VStack(alignment: .leading, spacing: FreshnestSpacing.xs) {
                        Text("Discard Reasons")
                            .font(FreshnestTypography.cardTitle)
                        ForEach(WasteReason.allCases, id: \.self) { reason in
                            if let count = counts[reason], count > 0 {
                                HStack {
                                    Text(reason.displayName)
                                    Spacer()
                                    Text("\(count)")
                                        .foregroundStyle(FreshnestColors.secondaryText)
                                }
                                .font(FreshnestTypography.secondary)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }

    private func percentString(_ value: Double) -> String {
        "\(Int((value * 100).rounded()))%"
    }

    private var emptyState: some View {
        VStack(spacing: FreshnestSpacing.sm) {
            Spacer(minLength: 80)
            Image(systemName: "chart.bar")
                .font(.system(size: 40))
                .foregroundStyle(FreshnestColors.secondaryText)
            Text("Your insights will appear as you use Freshnest.")
                .font(FreshnestTypography.secondary)
                .foregroundStyle(FreshnestColors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, FreshnestSpacing.xl)
        }
        .frame(maxWidth: .infinity)
        .accessibilityIdentifier("insights.emptyState")
    }
}

private struct MetricTile: View {
    let title: String
    let value: String

    var body: some View {
        FreshnestCard {
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(FreshnestColors.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(FreshnestColors.secondaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    NavigationStack {
        InsightsView()
    }
    .environment(AppContainer.makePreview())
}
