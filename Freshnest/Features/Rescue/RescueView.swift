import SwiftData
import SwiftUI

struct RescueView: View {
    @Environment(AppContainer.self) private var container
    @Environment(AppRouter.self) private var router

    @Query(filter: #Predicate<FoodBatch> { $0.statusRawValue == "active" })
    private var activeBatches: [FoodBatch]

    private var presenter: BatchFreshnessPresenter {
        BatchFreshnessPresenter(calculator: container.freshnessCalculator, repository: container.foodRepository)
    }

    private var suggestions: [RescueSuggestion] {
        let now = container.clock.now
        let scored = activeBatches.map { (id: $0.foodDefinitionID, state: presenter.result(for: $0, now: now).state) }
        let available = Set(scored.map(\.id))
        let urgent = Set(scored.filter { [.useSoon, .eatToday, .checkCarefully].contains($0.state) }.map(\.id))
        return container.rescueEngine.suggestions(
            availableFoodIDs: available,
            urgentFoodIDs: urgent,
            recipes: container.foodRepository.recipes
        )
    }

    var body: some View {
        Group {
            if suggestions.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(spacing: FreshnestSpacing.sm) {
                        ForEach(suggestions) { suggestion in
                            NavigationLink {
                                RescueRecipeDetailView(suggestion: suggestion, availableFoodIDs: Set(activeBatches.map(\.foodDefinitionID)))
                            } label: {
                                RescueSuggestionCard(suggestion: suggestion)
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("rescue.recipe.\(suggestion.recipe.id)")
                        }
                    }
                    .padding(FreshnestSpacing.md)
                }
            }
        }
        .navigationTitle("Rescue")
        .background(FreshnestColors.background)
    }

    private var emptyState: some View {
        VStack(spacing: FreshnestSpacing.sm) {
            Spacer()
            Image(systemName: "leaf")
                .font(.system(size: 40))
                .foregroundStyle(FreshnestColors.secondaryText)
            Text("Nothing needs rescuing.")
                .font(FreshnestTypography.cardTitle)
            Text("Your produce is in good shape.")
                .font(FreshnestTypography.secondary)
                .foregroundStyle(FreshnestColors.secondaryText)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .accessibilityIdentifier("rescue.emptyState")
    }
}

private struct RescueSuggestionCard: View {
    let suggestion: RescueSuggestion

    var body: some View {
        FreshnestCard {
            VStack(alignment: .leading, spacing: 4) {
                Text(suggestion.recipe.name)
                    .font(FreshnestTypography.cardTitle)
                    .foregroundStyle(FreshnestColors.primaryText)
                if suggestion.urgentFoodsRescued > 0 {
                    Label("Rescues \(suggestion.urgentFoodsRescued) urgent item\(suggestion.urgentFoodsRescued == 1 ? "" : "s")", systemImage: "leaf")
                        .font(.caption)
                        .foregroundStyle(FreshnestColors.success)
                }
                Text(suggestion.recipe.tags.joined(separator: " · "))
                    .font(.caption)
                    .foregroundStyle(FreshnestColors.tertiaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    NavigationStack {
        RescueView()
    }
    .environment(AppContainer.makePreview())
    .environment(AppRouter())
}
