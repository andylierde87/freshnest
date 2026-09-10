import SwiftUI

struct FoodLibraryView: View {
    @Environment(AppContainer.self) private var container
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var selected: FoodDefinition?

    private var grouped: [(category: FoodCategory, items: [FoodDefinition])] {
        FoodCategory.allCases.compactMap { category in
            let items = container.foodRepository.definitions(in: category).sorted { $0.name < $1.name }
            return items.isEmpty ? nil : (category, items)
        }
    }

    var body: some View {
        if horizontalSizeClass == .regular {
            NavigationSplitView {
                list
            } detail: {
                if let selected {
                    FoodLibraryDetailView(definition: selected)
                } else {
                    ContentUnavailableView("Select a food", systemImage: "leaf")
                }
            }
        } else {
            list
                .navigationDestination(item: $selected) { definition in
                    FoodLibraryDetailView(definition: definition)
                }
        }
    }

    private var list: some View {
        List {
            ForEach(grouped, id: \.category) { section in
                Section(section.category.displayName) {
                    ForEach(section.items) { definition in
                        Button {
                            selected = definition
                        } label: {
                            HStack {
                                Image(systemName: definition.iconName).foregroundStyle(FreshnestColors.accent)
                                Text(definition.name).foregroundStyle(FreshnestColors.primaryText)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Food Library")
        .background(FreshnestColors.background)
    }
}

private struct FoodLibraryDetailView: View {
    let definition: FoodDefinition

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: FreshnestSpacing.lg) {
                Text(definition.name)
                    .font(FreshnestTypography.largeTitle)

                tipsSection(title: String(localized: "Storage Tips"), tips: definition.storageTips)
                tipsSection(title: String(localized: "Ripeness Tips"), tips: definition.ripenessTips)
                tipsSection(title: String(localized: "Freezing Tips"), tips: definition.freezingTips)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Shelf Life")
                        .font(FreshnestTypography.sectionTitle)
                    Text("Counter: \(definition.counterShelfLifeDays) days")
                    Text("Fridge: \(definition.fridgeShelfLifeDays) days")
                    Text("Freezer: \(definition.freezerShelfLifeDays) days")
                }
                .font(FreshnestTypography.secondary)
                .foregroundStyle(FreshnestColors.secondaryText)
            }
            .padding(FreshnestSpacing.md)
        }
        .background(FreshnestColors.background)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func tipsSection(title: String, tips: [String]) -> some View {
        Group {
            if !tips.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title).font(FreshnestTypography.sectionTitle)
                    ForEach(tips, id: \.self) { Text("• \($0)").font(FreshnestTypography.body) }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        FoodLibraryView()
    }
    .environment(AppContainer.makePreview())
}
