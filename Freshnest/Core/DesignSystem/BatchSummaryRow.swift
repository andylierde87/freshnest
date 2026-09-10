import SwiftUI

/// The shared "food card" used by Home, Kitchen, and Rescue — produce name,
/// quantity, storage location, purchase date, and freshness state/score.
struct BatchSummaryRow: View {
    let definition: FoodDefinition
    let batch: FoodBatch
    let result: FreshnessResult

    var body: some View {
        FreshnestCard {
            HStack(spacing: FreshnestSpacing.md) {
                Image(systemName: definition.iconName)
                    .font(.title2)
                    .foregroundStyle(FreshnestColors.accent)
                    .frame(width: 36, height: 36)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 4) {
                    Text(definition.name)
                        .font(FreshnestTypography.cardTitle)
                        .foregroundStyle(FreshnestColors.primaryText)

                    HStack(spacing: FreshnestSpacing.xs) {
                        Label(quantityText, systemImage: "number")
                            .labelStyle(.titleOnly)
                        Label(batch.storageLocation.displayName, systemImage: batch.storageLocation.symbolName)
                    }
                    .font(FreshnestTypography.metadata)
                    .foregroundStyle(FreshnestColors.secondaryText)

                    FreshnessStatusLabel(state: result.state)
                }

                Spacer()

                Text("\(FreshnessStateMapper.clamp(result.score))")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(FreshnestColors.color(for: result.state))
                    .accessibilityHidden(true)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("\(definition.name), \(quantityText), \(batch.storageLocation.displayName), \(result.state.displayName), score \(result.score)"))
        .accessibilityIdentifier("kitchen.foodCard.\(definition.id)")
    }

    private var quantityText: String {
        "\(batch.quantity.formattedQuantity) \(batch.unit.displayName)"
    }
}

extension Double {
    var formattedQuantity: String {
        truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", self)
            : String(format: "%.1f", self)
    }
}

#Preview {
    let definition = FoodDefinition(
        id: "avocado", name: "Avocado", category: .fruit, aliases: [], iconName: "leaf.fill",
        defaultUnit: .piece, counterShelfLifeDays: 5, fridgeShelfLifeDays: 10, freezerShelfLifeDays: 150,
        ripeningDays: 4, ethyleneProduction: .high, ethyleneSensitivity: .high,
        storageTips: [], ripenessTips: [], freezingTips: [], rescueTags: []
    )
    let batch = FoodBatch(
        foodDefinitionID: "avocado", purchaseDate: .now, quantity: 3, unit: .piece,
        storageLocation: .counter, initialRipeness: .almostRipe
    )
    return BatchSummaryRow(definition: definition, batch: batch, result: FreshnessResult(score: 72, state: .useSoon, estimatedFreshUntil: nil))
        .padding()
        .background(FreshnestColors.background)
}
