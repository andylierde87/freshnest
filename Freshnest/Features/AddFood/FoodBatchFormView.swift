import PhotosUI
import SwiftData
import SwiftUI

enum FoodBatchFormMode {
    case add(FoodDefinition)
    case edit(FoodBatch)
}

struct FoodBatchFormView: View {
    let mode: FoodBatchFormMode

    @Environment(AppContainer.self) private var container
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var quantity: Double
    @State private var unit: FoodUnit
    @State private var storage: StorageLocation
    @State private var ripeness: RipenessState
    @State private var purchaseDate: Date
    @State private var notes: String
    @State private var isSaving = false

    init(mode: FoodBatchFormMode) {
        self.mode = mode
        switch mode {
        case .add(let definition):
            _quantity = State(initialValue: 1)
            _unit = State(initialValue: definition.defaultUnit)
            _storage = State(initialValue: .counter)
            _ripeness = State(initialValue: .notSure)
            _purchaseDate = State(initialValue: .now)
            _notes = State(initialValue: "")
        case .edit(let batch):
            _quantity = State(initialValue: batch.quantity)
            _unit = State(initialValue: batch.unit)
            _storage = State(initialValue: batch.storageLocation)
            _ripeness = State(initialValue: batch.initialRipeness)
            _purchaseDate = State(initialValue: batch.purchaseDate)
            _notes = State(initialValue: batch.notes ?? "")
        }
    }

    private var definition: FoodDefinition {
        switch mode {
        case .add(let definition): return definition
        case .edit(let batch): return container.foodRepository.definition(for: batch.foodDefinitionID)
        }
    }

    var body: some View {
        Form {
            Section {
                HStack {
                    Image(systemName: definition.iconName)
                        .foregroundStyle(FreshnestColors.accent)
                    Text(definition.name)
                        .font(FreshnestTypography.cardTitle)
                }
            }

            Section(String(localized: "Quantity")) {
                Stepper(value: $quantity, in: 0...999, step: 1) {
                    Text("\(quantity.formattedQuantity) \(unit.displayName)")
                }
                .accessibilityIdentifier("addFood.quantityStepper")

                Picker(String(localized: "Unit"), selection: $unit) {
                    ForEach(FoodUnit.allCases, id: \.self) { unit in
                        Text(unit.displayName).tag(unit)
                    }
                }
            }

            Section(String(localized: "Storage")) {
                Picker(String(localized: "Storage"), selection: $storage) {
                    ForEach(StorageLocation.allCases, id: \.self) { location in
                        Text(location.displayName).tag(location)
                    }
                }
                .pickerStyle(.segmented)
                .accessibilityIdentifier("addFood.storagePicker")
            }

            Section(String(localized: "Ripeness")) {
                Picker(String(localized: "Ripeness"), selection: $ripeness) {
                    ForEach(RipenessState.allCases, id: \.self) { state in
                        Text(state.displayName).tag(state)
                    }
                }
                .accessibilityIdentifier("addFood.ripenessPicker")
            }

            Section(String(localized: "Purchase Date")) {
                DatePicker(String(localized: "Purchase Date"), selection: $purchaseDate, displayedComponents: .date)
            }

            Section(String(localized: "Notes")) {
                TextField(String(localized: "Optional notes"), text: $notes, axis: .vertical)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(confirmTitle, action: save)
                    .accessibilityIdentifier("addFood.saveButton")
                    .disabled(isSaving)
            }
        }
        .background(FreshnestColors.background)
    }

    private var title: String {
        switch mode {
        case .add: return String(localized: "Add Food")
        case .edit: return String(localized: "Edit Food")
        }
    }

    private var confirmTitle: String {
        switch mode {
        case .add: return String(localized: "Add to Kitchen")
        case .edit: return String(localized: "Save")
        }
    }

    private func save() {
        // Guards against a duplicate FoodBatch/FoodEvent being inserted from a
        // second tap before `dismiss()` below closes this screen.
        guard !isSaving else { return }
        isSaving = true

        switch mode {
        case .add(let definition):
            let batch = FoodBatch(
                foodDefinitionID: definition.id,
                purchaseDate: purchaseDate,
                quantity: quantity,
                unit: unit,
                storageLocation: storage,
                initialRipeness: ripeness,
                notes: notes.isEmpty ? nil : notes
            )
            modelContext.insert(batch)
            let event = FoodEvent(batchID: batch.id, createdAt: container.clock.now, type: .added, quantity: quantity)
            event.batch = batch
            modelContext.insert(event)
        case .edit(let batch):
            batch.quantity = quantity
            batch.unit = unit
            batch.storageLocation = storage
            batch.initialRipeness = ripeness
            batch.purchaseDate = purchaseDate
            batch.notes = notes.isEmpty ? nil : notes
            batch.updatedAt = container.clock.now
        }
        dismiss()
    }
}

#Preview {
    NavigationStack {
        FoodBatchFormView(mode: .add(FoodDefinition(
            id: "avocado", name: "Avocado", category: .fruit, aliases: [], iconName: "leaf.fill",
            defaultUnit: .piece, counterShelfLifeDays: 5, fridgeShelfLifeDays: 10, freezerShelfLifeDays: 150,
            ripeningDays: 4, ethyleneProduction: .high, ethyleneSensitivity: .high,
            storageTips: [], ripenessTips: [], freezingTips: [], rescueTags: []
        )))
    }
    .environment(AppContainer.makePreview())
}
