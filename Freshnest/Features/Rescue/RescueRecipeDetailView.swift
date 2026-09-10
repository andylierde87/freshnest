import SwiftUI

struct RescueRecipeDetailView: View {
    let suggestion: RescueSuggestion
    let availableFoodIDs: Set<String>

    @Environment(AppContainer.self) private var container

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: FreshnestSpacing.lg) {
                Text(suggestion.recipe.name)
                    .font(FreshnestTypography.largeTitle)

                ingredientsSection(title: String(localized: "Required"), ids: suggestion.recipe.requiredFoodIDs)
                if !suggestion.recipe.optionalFoodIDs.isEmpty {
                    ingredientsSection(title: String(localized: "Optional"), ids: suggestion.recipe.optionalFoodIDs)
                }

                VStack(alignment: .leading, spacing: FreshnestSpacing.xs) {
                    Text("Steps")
                        .font(FreshnestTypography.sectionTitle)
                    ForEach(Array(suggestion.recipe.steps.enumerated()), id: \.offset) { index, step in
                        HStack(alignment: .top, spacing: FreshnestSpacing.xs) {
                            Text("\(index + 1).")
                                .foregroundStyle(FreshnestColors.accent)
                                .fontWeight(.semibold)
                            Text(step)
                        }
                        .font(FreshnestTypography.body)
                    }
                }
            }
            .padding(FreshnestSpacing.md)
        }
        .background(FreshnestColors.background)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func ingredientsSection(title: String, ids: [String]) -> some View {
        VStack(alignment: .leading, spacing: FreshnestSpacing.xs) {
            Text(title)
                .font(FreshnestTypography.sectionTitle)
            ForEach(ids, id: \.self) { id in
                let definition = container.foodRepository.definition(for: id)
                let owned = availableFoodIDs.contains(id)
                Label(definition.name, systemImage: owned ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(owned ? FreshnestColors.success : FreshnestColors.secondaryText)
            }
        }
    }
}
