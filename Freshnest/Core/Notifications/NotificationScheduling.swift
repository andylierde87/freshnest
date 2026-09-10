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

        let interval = max(60, notification.fireDate.timeIntervalSinceNow)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
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
