import Foundation
import UserNotifications

/// Abstraction over `UNUserNotificationCenter` so scheduling logic can be
/// unit-tested with a fake instead of touching the real notification center.
protocol NotificationScheduling: Sendable {
    func requestAuthorization() async -> Bool
    func schedule(_ notification: PlannedNotification) async
    func removeAllPending() async
    func pendingIdentifiers() async -> Set<String>
}

struct SystemNotificationScheduler: NotificationScheduling {
    func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    func schedule(_ notification: PlannedNotification) async {
        let content = UNMutableNotificationContent()
        content.title = notification.title
        content.body = notification.body
        content.sound = .default

        // A calendar trigger (not a fixed elapsed-seconds interval) so the
        // notification still fires at the intended local wall-clock time
        // across a DST transition between scheduling and delivery.
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: notification.fireDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: notification.id, content: content, trigger: trigger)

        try? await UNUserNotificationCenter.current().add(request)
    }

    func removeAllPending() async {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    func pendingIdentifiers() async -> Set<String> {
        let requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        return Set(requests.map(\.identifier))
    }
}
