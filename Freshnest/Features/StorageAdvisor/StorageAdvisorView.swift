import SwiftUI

struct StorageAdvisorView: View {
    @Environment(AppContainer.self) private var container

    @State private var query = ""
    @State private var selectedIDs: [String] = []

    private var allDefinitions: [FoodDefinition] { container.foodRepository.definitions }

    private var searchResults: [FoodDefinition] {
        let base = query.trimmingCharacters(in: .whitespaces).isEmpty
            ? allDefinitions.sorted { $0.name < $1.name }
            : FoodSearchEngine.search(query, in: allDefinitions)
        return base.filter { !selectedIDs.contains($0.id) }
    }

    private var selectedDefinitions: [FoodDefinition] {
        selectedIDs.map { container.foodRepository.definition(for: $0) }
    }

    private var result: StorageAdvisorResult {
        container.storageAdvisor.advise(for: selectedDefinitions)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: FreshnestSpacing.md) {
                Text("Select produce to check how well they store together.")
                    .font(FreshnestTypography.secondary)
                    .foregroundStyle(FreshnestColors.secondaryText)

                if !selectedDefinitions.isEmpty {
                    selectedChips
                }

                TextField("Search fruits and vegetables", text: $query)
                    .textFieldStyle(.roundedBorder)
                    .accessibilityIdentifier("storageAdvisor.searchField")

                ForEach(searchResults.prefix(8)) { definition in
                    Button {
                        selectedIDs.append(definition.id)
                        query = ""
                    } label: {
                        HStack {
                            Image(systemName: definition.iconName).foregroundStyle(FreshnestColors.accent)
                            Text(definition.name).foregroundStyle(FreshnestColors.primaryText)
                            Spacer()
                        }
                    }
                }

                if !selectedDefinitions.isEmpty {
                    resultsSection
                }
            }
            .padding(FreshnestSpacing.md)
        }
        .navigationTitle("Storage Advisor")
        .background(FreshnestColors.background)
    }

    private var selectedChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(selectedDefinitions) { definition in
                    HStack(spacing: 4) {
                        Text(definition.name)
                        Button {
                            selectedIDs.removeAll { $0 == definition.id }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                        }
                    }
                    .font(FreshnestTypography.secondary.weight(.semibold))
                    .padding(.horizontal, FreshnestSpacing.sm)
                    .padding(.vertical, 6)
                    .background(FreshnestColors.secondaryBackground)
                    .clipShape(Capsule())
                    .accessibilityIdentifier("storageAdvisor.selected.\(definition.id)")
                }
            }
        }
    }

    private var resultsSection: some View {
        VStack(alignment: .leading, spacing: FreshnestSpacing.sm) {
            FreshnestCard {
                VStack(alignment: .leading, spacing: FreshnestSpacing.xs) {
                    Text("Storage Compatibility")
                        .font(FreshnestTypography.cardTitle)
                    Text(result.compatibility.displayName)
                        .font(FreshnestTypography.largeTitle)
                        .foregroundStyle(compatibilityColor)
                        .accessibilityIdentifier("storageAdvisor.compatibilityLabel")

                    if !result.warnings.isEmpty {
                        Divider()
                        Text("Why")
                            .font(FreshnestTypography.cardTitle)
                        ForEach(result.warnings) { warning in
                            Text(warning.message)
                                .font(FreshnestTypography.secondary)
                                .foregroundStyle(FreshnestColors.secondaryText)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            ForEach(result.recommendations) { recommendation in
                let definition = container.foodRepository.definition(for: recommendation.foodID)
                FreshnestCard {
                    VStack(alignment: .leading, spacing: 4) {
                        Label(definition.name, systemImage: definition.iconName)
                            .font(FreshnestTypography.cardTitle)
                        Label("Best stored: \(recommendation.recommendedStorage.displayName)", systemImage: recommendation.recommendedStorage.symbolName)
                            .font(FreshnestTypography.secondary)
                            .foregroundStyle(FreshnestColors.secondaryText)
                        ForEach(recommendation.tips, id: \.self) { tip in
                            Text("• \(tip)")
                                .font(.caption)
                                .foregroundStyle(FreshnestColors.tertiaryText)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }

    private var compatibilityColor: Color {
        switch result.compatibility {
        case .good: return FreshnestColors.success
        case .fair: return FreshnestColors.warning
        case .poor: return FreshnestColors.danger
        }
    }
}

#Preview {
    NavigationStack {
        StorageAdvisorView()
    }
    .environment(AppContainer.makePreview())
}
