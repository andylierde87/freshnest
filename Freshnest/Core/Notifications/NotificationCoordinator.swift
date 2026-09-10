import Foundation

/// Bridges the pure `NotificationPlanning` decision with the side-effecting
/// `NotificationScheduling` service. A denied permission is a normal,
/// recoverable outcome — never a crash.
@MainActor
final class NotificationCoordinator {
    private let scheduler: NotificationScheduling
    private let planner: NotificationPlanning
    private let clock: ClockProviding

    init(
        scheduler: NotificationScheduling = SystemNotificationScheduler(),
        planner: NotificationPlanning = DefaultNotificationPlanner(),
        clock: ClockProviding = SystemClock()
    ) {
        self.scheduler = scheduler
        self.planner = planner
        self.clock = clock
    }

    @discardableResult
    func requestPermissionIfNeeded() async -> Bool {
        await scheduler.requestAuthorization()
    }

    func sync(batches: [BatchNotificationSnapshot], settings: NotificationSettings) async {
        await scheduler.removeAllPending()

        guard settings.remindersEnabled else { return }

        let granted = await scheduler.requestAuthorization()
        guard granted else { return }

        let plan = planner.plan(for: batches, settings: settings, now: clock.now)
        for notification in plan {
            await scheduler.schedule(notification)
        }
    }
}
