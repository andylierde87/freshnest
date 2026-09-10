import SwiftUI

struct AddFoodView: View {
    @Environment(AppContainer.self) private var container
    @Environment(\.dismiss) private var dismiss

    @State private var query = ""
    @State private var selectedCategory: FoodCategory?
    @FocusState private var isSearchFocused: Bool

    private var results: [FoodDefinition] {
        let base = query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? container.foodRepository.definitions.sorted { $0.name < $1.name }
            : FoodSearchEngine.search(query, in: container.foodRepository.definitions)

        guard let selectedCategory else { return base }
        return base.filter { $0.category == selectedCategory }
    }

    var body: some View {
        VStack(spacing: 0) {
            searchField
            categoryFilterBar

            List {
                ForEach(results) { definition in
                    NavigationLink {
                        FoodBatchFormView(mode: .add(definition))
                    } label: {
                        HStack(spacing: FreshnestSpacing.sm) {
                            Image(systemName: definition.iconName)
                                .foregroundStyle(FreshnestColors.accent)
                            Text(definition.name)
                                .foregroundStyle(FreshnestColors.primaryText)
                        }
                    }
                    .accessibilityIdentifier("addFood.result.\(definition.id)")
                    .simultaneousGesture(TapGesture().onEnded { isSearchFocused = false })
                }

                if results.isEmpty {
                    ContentUnavailableView.search(text: query)
                }
            }
            .listStyle(.plain)
        }
        .navigationTitle("Add Food")
        .navigationBarTitleDisplayMode(.inline)
        .background(FreshnestColors.background)
        .onDisappear { isSearchFocused = false }
    }

    private var searchField: some View {
        HStack(spacing: FreshnestSpacing.xs) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(FreshnestColors.secondaryText)
            TextField(String(localized: "Search fruits and vegetables"), text: $query)
                .textFieldStyle(.plain)
                .autocorrectionDisabled()
                .focused($isSearchFocused)
                .accessibilityIdentifier("addFood.searchField")
        }
        .padding(FreshnestSpacing.sm)
        .background(FreshnestColors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: FreshnestRadius.control, style: .continuous))
        .padding(.horizontal, FreshnestSpacing.md)
        .padding(.top, FreshnestSpacing.xs)
    }

    private var categoryFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: FreshnestSpacing.xs) {
                FilterChip(title: String(localized: "All"), isSelected: selectedCategory == nil) {
                    selectedCategory = nil
                }
                ForEach(FoodCategory.allCases, id: \.self) { category in
                    FilterChip(title: category.displayName, isSelected: selectedCategory == category) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.horizontal, FreshnestSpacing.md)
            .padding(.vertical, FreshnestSpacing.xs)
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(FreshnestTypography.secondary.weight(.semibold))
                .padding(.horizontal, FreshnestSpacing.sm)
                .padding(.vertical, 6)
                .foregroundStyle(isSelected ? Color.white : FreshnestColors.primaryText)
                .background(isSelected ? FreshnestColors.accent : FreshnestColors.secondaryBackground)
                .clipShape(Capsule())
        }
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

#Preview {
    NavigationStack {
        AddFoodView()
    }
    .environment(AppContainer.makePreview())
}
