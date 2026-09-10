import SwiftData
import SwiftUI

struct ShoppingListView: View {
    @Environment(AppContainer.self) private var container
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \ShoppingItem.createdAt) private var items: [ShoppingItem]
    @State private var showAddSheet = false
    @State private var pendingAddToKitchen: [ShoppingItem] = []

    var body: some View {
        List {
            if items.isEmpty {
                ContentUnavailableView(
                    "Your shopping list is empty.",
                    systemImage: "cart",
                    description: Text("Add produce you need to buy.")
                )
                .accessibilityIdentifier("shoppingList.emptyState")
            } else {
                ForEach(items) { item in
                    ShoppingItemRow(item: item) {
                        toggle(item)
                    }
                }
                .onDelete(perform: delete)
            }
        }
        .navigationTitle("Shopping List")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAddSheet = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityIdentifier("shoppingList.addButton")
            }
        }
        .sheet(isPresented: $showAddSheet) {
            NavigationStack {
                AddShoppingItemView()
            }
        }
        .confirmationDialog(
            "Add purchased items to Kitchen?",
            isPresented: Binding(get: { !pendingAddToKitchen.isEmpty }, set: { if !$0 { pendingAddToKitchen = [] } }),
            titleVisibility: .visible
        ) {
            Button("Add to Kitchen") {
                addToKitchen(pendingAddToKitchen)
                pendingAddToKitchen = []
            }
            Button("Not Now", role: .cancel) { pendingAddToKitchen = [] }
        }
        .background(FreshnestColors.background)
    }

    private func toggle(_ item: ShoppingItem) {
        item.isPurchased.toggle()
        if item.isPurchased {
            pendingAddToKitchen = [item]
        }
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets { modelContext.delete(items[index]) }
    }

    private func addToKitchen(_ purchasedItems: [ShoppingItem]) {
        for item in purchasedItems {
            let batch = FoodBatch(
                foodDefinitionID: item.foodDefinitionID,
                purchaseDate: container.clock.now,
                quantity: item.quantity,
                unit: item.unit,
                storageLocation: .counter,
                initialRipeness: .notSure
            )
            modelContext.insert(batch)
            let event = FoodEvent(batchID: batch.id, createdAt: container.clock.now, type: .added, quantity: item.quantity)
            event.batch = batch
            modelContext.insert(event)
        }
    }
}

private struct ShoppingItemRow: View {
    let item: ShoppingItem
    let onToggle: () -> Void

    @Environment(AppContainer.self) private var container

    var body: some View {
        let definition = container.foodRepository.definition(for: item.foodDefinitionID)
        HStack {
            Button(action: onToggle) {
                Image(systemName: item.isPurchased ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(item.isPurchased ? FreshnestColors.success : FreshnestColors.secondaryText)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("shoppingList.toggle.\(item.foodDefinitionID)")

            VStack(alignment: .leading) {
                Text(definition.name)
                    .strikethrough(item.isPurchased)
                Text("\(item.quantity.formattedQuantity) \(item.unit.displayName)")
                    .font(.caption)
                    .foregroundStyle(FreshnestColors.secondaryText)
            }
            Spacer()
        }
    }
}

private struct AddShoppingItemView: View {
    @Environment(AppContainer.self) private var container
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var query = ""
    @State private var selected: FoodDefinition?
    @State private var quantity: Double = 1
    @State private var unit: FoodUnit = .piece

    private var results: [FoodDefinition] {
        query.isEmpty
            ? container.foodRepository.definitions.sorted { $0.name < $1.name }
            : FoodSearchEngine.search(query, in: container.foodRepository.definitions)
    }

    var body: some View {
        Form {
            if let selected {
                Section {
                    HStack {
                        Text(selected.name)
                        Spacer()
                        Button("Change") { self.selected = nil }
                            .font(.caption)
                    }
                }
                Section(String(localized: "Quantity")) {
                    Stepper(value: $quantity, in: 1...999) {
                        Text("\(quantity.formattedQuantity) \(unit.displayName)")
                    }
                    .accessibilityIdentifier("shoppingItem.quantityStepper")
                    Picker(String(localized: "Unit"), selection: $unit) {
                        ForEach(FoodUnit.allCases, id: \.self) { Text($0.displayName).tag($0) }
                    }
                }
            } else {
                Section {
                    TextField(String(localized: "Search"), text: $query)
                        .accessibilityIdentifier("shoppingItem.searchField")
                }
                Section {
                    ForEach(results.prefix(20)) { definition in
                        Button(definition.name) {
                            selected = definition
                            unit = definition.defaultUnit
                        }
                        .accessibilityIdentifier("shoppingItem.result.\(definition.id)")
                    }
                }
            }
        }
        .navigationTitle("Add Item")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Add") {
                    guard let selected else { return }
                    let item = ShoppingItem(foodDefinitionID: selected.id, quantity: quantity, unit: unit)
                    modelContext.insert(item)
                    dismiss()
                }
                .disabled(selected == nil)
                .accessibilityIdentifier("shoppingItem.addButton")
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ShoppingListView()
    }
    .environment(AppContainer.makePreview())
}
