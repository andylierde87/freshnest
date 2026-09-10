import SwiftData
import SwiftUI

struct FoodDetailsView: View {
    let batchID: UUID

    @Environment(AppContainer.self) private var container
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @Query private var batches: [FoodBatch]
    @State private var showManualCheck = false
    @State private var showDiscardReasons = false
    @State private var showDeleteConfirmation = false

    init(batchID: UUID) {
        self.batchID = batchID
        let id = batchID
        _batches = Query(filter: #Predicate<FoodBatch> { $0.id == id })
    }

    private var batch: FoodBatch? { batches.first }

    private var presenter: BatchFreshnessPresenter {
        BatchFreshnessPresenter(calculator: container.freshnessCalculator, repository: container.foodRepository)
    }

    var body: some View {
        Group {
            if let batch {
                content(for: batch)
            } else {
                ContentUnavailableView("Item not found", systemImage: "questionmark.circle")
            }
        }
        .background(FreshnestColors.background)
    }

    @ViewBuilder
    private func content(for batch: FoodBatch) -> some View {
        let definition = presenter.definition(for: batch)
        let result = presenter.result(for: batch, now: container.clock.now)

        ScrollView {
            ReadableWidthContainer {
                if horizontalSizeClass == .regular {
                    HStack(alignment: .top, spacing: FreshnestSpacing.lg) {
                        VStack(spacing: FreshnestSpacing.md) {
                            overviewSection(definition: definition, batch: batch, result: result)
                            actionsSection(batch: batch)
                        }
                        .frame(maxWidth: .infinity)

                        VStack(spacing: FreshnestSpacing.md) {
                            storageSection(definition: definition, batch: batch)
                            compatibilitySection(definition: definition)
                            timelineSection(batch: batch)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(FreshnestSpacing.lg)
                } else {
                    VStack(spacing: FreshnestSpacing.md) {
                        overviewSection(definition: definition, batch: batch, result: result)
                        actionsSection(batch: batch)
                        storageSection(definition: definition, batch: batch)
                        compatibilitySection(definition: definition)
                        timelineSection(batch: batch)
                    }
                    .padding(FreshnestSpacing.md)
                }
            }
        }
        .navigationTitle(definition.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    NavigationLink("Edit") { FoodBatchFormView(mode: .edit(batch)) }
                    Button("Delete", role: .destructive) { showDeleteConfirmation = true }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .confirmationDialog(
            "Delete this item?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                modelContext.delete(batch)
                dismiss()
            }
        }
        .confirmationDialog(
            "How does it look?",
            isPresented: $showManualCheck,
            titleVisibility: .visible
        ) {
            ForEach(ManualFreshnessCheckState.allCases, id: \.self) { state in
                Button(state.displayName) {
                    FoodBatchMutationService(modelContext: modelContext, clock: container.clock)
                        .recordManualCheck(batch, state: state)
                }
            }
        }
        .confirmationDialog(
            "Why are you discarding this?",
            isPresented: $showDiscardReasons,
            titleVisibility: .visible
        ) {
            ForEach(WasteReason.allCases, id: \.self) { reason in
                Button(reason.displayName) {
                    _ = try? FoodBatchMutationService(modelContext: modelContext, clock: container.clock)
                        .discardAll(batch, reason: reason)
                    dismiss()
                }
            }
        }
    }

    private func overviewSection(definition: FoodDefinition, batch: FoodBatch, result: FreshnessResult) -> some View {
        FreshnestCard {
            VStack(spacing: FreshnestSpacing.md) {
                FreshnessRingView(score: result.score, state: result.state)
                    .accessibilityIdentifier("foodDetails.score")

                if let until = result.estimatedFreshUntil {
                    Text("Best used by \(until.formatted(date: .abbreviated, time: .omitted))")
                        .font(FreshnestTypography.secondary)
                        .foregroundStyle(FreshnestColors.secondaryText)
                }

                HStack {
                    Label("\(batch.quantity.formattedQuantity) \(batch.unit.displayName)", systemImage: "number")
                    Spacer()
                    Label(batch.storageLocation.displayName, systemImage: batch.storageLocation.symbolName)
                }
                .font(FreshnestTypography.secondary)
                .foregroundStyle(FreshnestColors.secondaryText)

                Text("Visual estimate only. PantryPulse cannot confirm food safety. Check smell, texture, and the inside of the food before eating.")
                    .font(.caption)
                    .foregroundStyle(FreshnestColors.tertiaryText)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private func actionsSection(batch: FoodBatch) -> some View {
        VStack(spacing: FreshnestSpacing.xs) {
            Button("Check Freshness") { showManualCheck = true }
                .buttonStyle(.freshnestPrimary)
                .accessibilityIdentifier("foodDetails.scanButton")

            HStack(spacing: FreshnestSpacing.xs) {
                Button("Ate One") {
                    _ = try? FoodBatchMutationService(modelContext: modelContext, clock: container.clock).ateOne(batch)
                }
                .buttonStyle(.freshnestSecondary)
                .accessibilityIdentifier("foodDetails.ateOneButton")

                Button("Discard") { showDiscardReasons = true }
                    .buttonStyle(.freshnestSecondary)
                    .accessibilityIdentifier("foodDetails.discardButton")
            }

            Menu {
                ForEach(StorageLocation.allCases, id: \.self) { location in
                    Button(location.displayName) {
                        FoodBatchMutationService(modelContext: modelContext, clock: container.clock)
                            .move(batch, to: location)
                    }
                }
            } label: {
                Text("Move Storage")
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .buttonStyle(.freshnestSecondary)
            .accessibilityIdentifier("foodDetails.moveStorageButton")
        }
    }

    private func storageSection(definition: FoodDefinition, batch: FoodBatch) -> some View {
        FreshnestCard {
            VStack(alignment: .leading, spacing: FreshnestSpacing.xs) {
                Text("Storage Tips")
                    .font(FreshnestTypography.cardTitle)
                ForEach(definition.storageTips, id: \.self) { tip in
                    Label(tip, systemImage: "lightbulb")
                        .font(FreshnestTypography.secondary)
                        .foregroundStyle(FreshnestColors.secondaryText)
                }
                if definition.storageTips.isEmpty {
                    Text("No specific storage tips available.")
                        .font(FreshnestTypography.secondary)
                        .foregroundStyle(FreshnestColors.tertiaryText)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func compatibilitySection(definition: FoodDefinition) -> some View {
        FreshnestCard {
            VStack(alignment: .leading, spacing: FreshnestSpacing.xs) {
                Text("Compatibility")
                    .font(FreshnestTypography.cardTitle)
                Label(
                    "Ethylene production: \(definition.ethyleneProduction.rawValue.capitalized)",
                    systemImage: "wind"
                )
                Label(
                    "Sensitivity: \(definition.ethyleneSensitivity.rawValue.capitalized)",
                    systemImage: "exclamationmark.triangle"
                )
            }
            .font(FreshnestTypography.secondary)
            .foregroundStyle(FreshnestColors.secondaryText)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func timelineSection(batch: FoodBatch) -> some View {
        FreshnestCard {
            VStack(alignment: .leading, spacing: FreshnestSpacing.xs) {
                Text("History")
                    .font(FreshnestTypography.cardTitle)

                let events = batch.events.sorted { $0.createdAt > $1.createdAt }
                if events.isEmpty {
                    Text("No activity yet.")
                        .font(FreshnestTypography.secondary)
                        .foregroundStyle(FreshnestColors.tertiaryText)
                } else {
                    ForEach(events.prefix(10)) { event in
                        HStack {
                            Text(eventTitle(event))
                            Spacer()
                            Text(event.createdAt.formatted(date: .abbreviated, time: .omitted))
                                .foregroundStyle(FreshnestColors.tertiaryText)
                        }
                        .font(FreshnestTypography.secondary)
                    }
                }

                if !batch.scans.isEmpty {
                    Divider().padding(.vertical, 4)
                    Text("Scan History")
                        .font(FreshnestTypography.cardTitle)
                    ForEach(batch.scans.sorted { $0.createdAt > $1.createdAt }) { scan in
                        HStack {
                            Text(scan.createdAt.formatted(date: .abbreviated, time: .omitted))
                            Spacer()
                            if let score = scan.freshnessScore {
                                Text("\(score)%")
                                    .foregroundStyle(FreshnestColors.accent)
                            }
                        }
                        .font(FreshnestTypography.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func eventTitle(_ event: FoodEvent) -> String {
        switch event.type {
        case .added: return String(localized: "Added")
        case .eaten: return String(localized: "Ate one")
        case .discarded: return String(localized: "Discarded")
        case .moved: return String(localized: "Moved storage")
        case .scanned: return String(localized: "Scanned")
        case .ripenessChanged: return String(localized: "Freshness checked")
        case .quantityChanged: return String(localized: "Quantity updated")
        }
    }
}
