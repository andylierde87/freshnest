import Foundation

struct BatchNotificationSnapshot: Sendable, Equatable {
    let batchID: UUID
    let foodName: String
    let freshnessState: FreshnessState
    let status: FoodBatchStatus
}

struct NotificationSettings: Sendable, Equatable {
    var remindersEnabled: Bool
    var dailySummaryEnabled: Bool
    var reminderHour: Int
    var reminderMinute: Int

    static let `default` = NotificationSettings(
        remindersEnabled: false,
        dailySummaryEnabled: false,
        reminderHour: 9,
        reminderMinute: 0
    )
}

struct PlannedNotification: Sendable, Equatable {
    let id: String
    let title: String
    let body: String
    let fireDate: Date
}

protocol NotificationPlanning: Sendable {
    func plan(
        for batches: [BatchNotificationSnapshot],
        settings: NotificationSettings,
        now: Date
    ) -> [PlannedNotification]
}
