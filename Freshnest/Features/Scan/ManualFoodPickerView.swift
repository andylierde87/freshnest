import SwiftUI

struct ManualFoodPickerView: View {
    let title: String
    let definitions: [FoodDefinition]
    let onSelect: (FoodDefinition) -> Void

    @State private var query = ""

    private var results: [FoodDefinition] {
        query.trimmingCharacters(in: .whitespaces).isEmpty
            ? definitions.sorted { $0.name < $1.name }
            : FoodSearchEngine.search(query, in: definitions)
    }

    var body: some View {
        VStack(spacing: 0) {
            Text(title)
                .font(FreshnestTypography.cardTitle)
                .multilineTextAlignment(.center)
                .padding()
                .accessibilityIdentifier("scan.lowConfidenceMessage")

            List(results) { definition in
                Button {
                    onSelect(definition)
                } label: {
                    HStack {
                        Image(systemName: definition.iconName)
                            .foregroundStyle(FreshnestColors.accent)
                        Text(definition.name)
                            .foregroundStyle(FreshnestColors.primaryText)
                    }
                }
                .accessibilityIdentifier("scan.manualResult.\(definition.id)")
            }
            .searchable(text: $query)
            .listStyle(.plain)
        }
        .background(FreshnestColors.background)
    }
}
