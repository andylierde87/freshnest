import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(AppContainer.self) private var container
    @Environment(\.modelContext) private var modelContext

    @State private var showDeleteConfirmation = false
    @State private var notificationPermissionDenied = false

    var body: some View {
        @Bindable var settings = container.settingsStore

        Form {
            Section(String(localized: "More")) {
                NavigationLink("Food Library") { FoodLibraryView() }
                NavigationLink("Shopping List") { ShoppingListView() }
                NavigationLink("Storage Advisor") { StorageAdvisorView() }
            }

            Section {
                Picker(String(localized: "Appearance"), selection: $settings.colorSchemePreference) {
                    ForEach(AppColorSchemePreference.allCases, id: \.self) { preference in
                        Text(preference.displayName).tag(preference)
                    }
                }
                .accessibilityIdentifier("settings.appearancePicker")
            } header: {
                Text("Appearance")
            }

            Section {
                Toggle(String(localized: "Store Scan Photos"), isOn: $settings.storeScanPhotos)
                    .accessibilityIdentifier("settings.storeScanPhotosToggle")
            } header: {
                Text("Privacy")
            } footer: {
                Text("Freshness analysis is performed on your device. Freshnest does not upload your food photos for analysis.")
            }

            Section {
                Toggle(String(localized: "Freshness Reminders"), isOn: $settings.remindersEnabled)
                    .accessibilityIdentifier("settings.remindersToggle")
                    .onChange(of: settings.remindersEnabled) { _, enabled in
                        Task {
                            if enabled {
                                let granted = await container.notificationCoordinator.requestPermissionIfNeeded()
                                notificationPermissionDenied = !granted
                                if !granted { settings.remindersEnabled = false }
                            }
                        }
                    }

                Toggle(String(localized: "Daily Summary"), isOn: $settings.dailySummaryEnabled)
                    .disabled(!settings.remindersEnabled)
                    .accessibilityIdentifier("settings.dailySummaryToggle")

                DatePicker(
                    String(localized: "Reminder Time"),
                    selection: reminderTimeBinding,
                    displayedComponents: .hourAndMinute
                )
                .disabled(!settings.remindersEnabled)
            } header: {
                Text("Notifications")
            } footer: {
                if notificationPermissionDenied {
                    Text("Notifications are disabled for Freshnest in iOS Settings.")
                        .foregroundStyle(FreshnestColors.danger)
                }
            }

            Section {
                Button("Delete All Data", role: .destructive) {
                    showDeleteConfirmation = true
                }
                .accessibilityIdentifier("settings.deleteAllDataButton")
            }
        }
        .navigationTitle("Settings")
        .confirmationDialog(
            "This permanently deletes all Freshnest data on this device. This cannot be undone.",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete Everything", role: .destructive, action: deleteAllData)
        }
        .background(FreshnestColors.background)
    }

    private var reminderTimeBinding: Binding<Date> {
        Binding(
            get: {
                Calendar.current.date(
                    bySettingHour: container.settingsStore.reminderHour,
                    minute: container.settingsStore.reminderMinute,
                    second: 0,
                    of: .now
                ) ?? .now
            },
            set: { newValue in
                let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                container.settingsStore.reminderHour = components.hour ?? 9
                container.settingsStore.reminderMinute = components.minute ?? 0
            }
        )
    }

    private func deleteAllData() {
        for batch in (try? modelContext.fetch(FetchDescriptor<FoodBatch>())) ?? [] { modelContext.delete(batch) }
        for waste in (try? modelContext.fetch(FetchDescriptor<WasteEvent>())) ?? [] { modelContext.delete(waste) }
        for item in (try? modelContext.fetch(FetchDescriptor<ShoppingItem>())) ?? [] { modelContext.delete(item) }
        container.settingsStore.resetAll()
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .environment(AppContainer.makePreview())
}
