import SwiftUI

struct ScanResultView: View {
    let data: ScanResultData
    let activeBatchesForFood: [FoodBatch]
    let isSaving: Bool
    let onLooksCorrect: () -> Void
    let onLooksFresher: () -> Void
    let onLooksWorse: () -> Void
    let onAddToKitchen: () -> Void
    let onUpdateExisting: (FoodBatch) -> Void
    let onScanAgain: () -> Void

    @Environment(AppContainer.self) private var container
    @State private var showExistingPicker = false

    private var definition: FoodDefinition {
        container.foodRepository.definition(for: data.foodID)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: FreshnestSpacing.lg) {
                Text(definition.name)
                    .font(FreshnestTypography.largeTitle)

                FreshnessRingView(score: data.score, state: data.state)
                    .accessibilityIdentifier("scan.result.score")

                observationsSection

                Text("Visual estimate only. PantryPulse cannot confirm food safety. Check smell, texture, and the inside of the food before eating.")
                    .font(.caption)
                    .foregroundStyle(FreshnestColors.tertiaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, FreshnestSpacing.lg)

                HStack(spacing: FreshnestSpacing.xs) {
                    Button("Looks Fresher", action: onLooksFresher)
                        .buttonStyle(.freshnestSecondary)
                    Button("Looks Correct", action: onLooksCorrect)
                        .buttonStyle(.freshnestSecondary)
                    Button("Looks Worse", action: onLooksWorse)
                        .buttonStyle(.freshnestSecondary)
                }
                .font(.footnote)
                .padding(.horizontal, FreshnestSpacing.md)

                VStack(spacing: FreshnestSpacing.xs) {
                    Button("Add to Kitchen", action: onAddToKitchen)
                        .buttonStyle(.freshnestPrimary)
                        .accessibilityIdentifier("scan.result.addToKitchen")
                        .disabled(isSaving)

                    if !activeBatchesForFood.isEmpty {
                        Button("Update Existing Item") { showExistingPicker = true }
                            .buttonStyle(.freshnestSecondary)
                            .disabled(isSaving)
                    }

                    Button("Scan Again", action: onScanAgain)
                        .buttonStyle(.freshnestSecondary)
                        .accessibilityIdentifier("scan.result.scanAgain")
                        .disabled(isSaving)
                }
                .padding(.horizontal, FreshnestSpacing.md)
            }
            .padding(.vertical, FreshnestSpacing.lg)
        }
        .confirmationDialog("Update which item?", isPresented: $showExistingPicker, titleVisibility: .visible) {
            ForEach(activeBatchesForFood) { batch in
                Button("\(batch.quantity.formattedQuantity) \(batch.unit.displayName) — \(batch.storageLocation.displayName)") {
                    onUpdateExisting(batch)
                }
            }
        }
    }

    private var observationsSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Visible observations")
                .font(FreshnestTypography.cardTitle)
            if data.observations.isEmpty {
                Label("No obvious visible spoilage detected", systemImage: "checkmark.circle")
                    .foregroundStyle(FreshnestColors.success)
            } else {
                ForEach(data.observations, id: \.self) { observation in
                    Label(observation.displayName, systemImage: "circle.fill")
                        .imageScale(.small)
                }
            }
        }
        .font(FreshnestTypography.secondary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, FreshnestSpacing.lg)
    }
}
