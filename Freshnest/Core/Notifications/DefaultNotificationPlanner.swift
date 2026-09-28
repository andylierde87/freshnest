import Foundation

/// Decides which local reminders should exist right now, purely from data —
/// scheduling side effects are handled separately by `NotificationScheduling`.
struct DefaultNotificationPlanner: NotificationPlanning {
    private static let urgentStates: Set<FreshnessState> = [.useSoon, .eatToday, .checkCarefully]

    func plan(
        for batches: [BatchNotificationSnapshot],
        settings: NotificationSettings,
        now: Date
    ) -> [PlannedNotification] {
        guard settings.remindersEnabled else { return [] }

        var seenBatchIDs = Set<UUID>()
        let urgentActiveBatches = batches.filter {
            $0.status == .active
                && Self.urgentStates.contains($0.freshnessState)
                && seenBatchIDs.insert($0.batchID).inserted
        }

        guard !urgentActiveBatches.isEmpty else { return [] }

        let fireDate = nextFireDate(hour: settings.reminderHour, minute: settings.reminderMinute, after: now)

        var notifications = urgentActiveBatches.map { batch in
            PlannedNotification(
                id: "freshness-\(batch.batchID.uuidString)",
                title: String(localized: "Freshness Reminder"),
                body: reminderBody(foodName: batch.foodName, state: batch.freshnessState),
                fireDate: fireDate
            )
        }

        if settings.dailySummaryEnabled {
            notifications.append(
                PlannedNotification(
                    id: "daily-summary",
                    title: String(localized: "Daily Summary"),
                    body: String(localized: "\(urgentActiveBatches.count) items in your kitchen should be used soon."),
                    fireDate: fireDate
                )
            )
        }

        return notifications
    }

    private func reminderBody(foodName: String, state: FreshnessState) -> String {
        switch state {
        case .checkCarefully:
            return String(localized: "Your \(foodName) may need attention today.")
        case .eatToday:
            return String(localized: "Your \(foodName) should be eaten today.")
        default:
            return String(localized: "Your \(foodName) should be used soon.")
        }
    }

    private func nextFireDate(hour: Int, minute: Int, after now: Date) -> Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        components.second = 0
        // `nextDate` finds the next occurrence of this wall-clock time strictly
        // after `now` and correctly rolls past a nonexistent local time (e.g. a
        // DST spring-forward gap), unlike manually building components and
        // falling back to `now` when they don't resolve to a valid date.
        return calendar.nextDate(
            after: now,
            matching: components,
            matchingPolicy: .nextTimePreservingSmallerComponents
        ) ?? calendar.date(byAdding: .day, value: 1, to: now) ?? now
    }
}
