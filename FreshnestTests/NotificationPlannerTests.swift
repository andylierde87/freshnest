import XCTest
@testable import Freshnest

final class NotificationPlannerTests: XCTestCase {
    private let planner = DefaultNotificationPlanner()
    private let now = Date(timeIntervalSince1970: 1_700_000_000)

    private func urgentBatch(id: UUID = UUID(), status: FoodBatchStatus = .active) -> BatchNotificationSnapshot {
        BatchNotificationSnapshot(batchID: id, foodName: "Strawberry", freshnessState: .eatToday, status: status)
    }

    func testDisabledRemindersProduceNoNotifications() {
        let settings = NotificationSettings(remindersEnabled: false, dailySummaryEnabled: false, reminderHour: 9, reminderMinute: 0)
        let plan = planner.plan(for: [urgentBatch()], settings: settings, now: now)
        XCTAssertTrue(plan.isEmpty)
    }

    func testUrgentProducePlansAReminder() {
        let settings = NotificationSettings(remindersEnabled: true, dailySummaryEnabled: false, reminderHour: 9, reminderMinute: 0)
        let plan = planner.plan(for: [urgentBatch()], settings: settings, now: now)
        XCTAssertEqual(plan.count, 1)
    }

    func testDuplicateReminderIsNotCreatedForTheSameBatch() {
        let id = UUID()
        let settings = NotificationSettings(remindersEnabled: true, dailySummaryEnabled: false, reminderHour: 9, reminderMinute: 0)
        let plan = planner.plan(for: [urgentBatch(id: id), urgentBatch(id: id)], settings: settings, now: now)
        XCTAssertEqual(plan.count, 1)
    }

    func testFinishedBatchProducesNoReminder() {
        let settings = NotificationSettings(remindersEnabled: true, dailySummaryEnabled: false, reminderHour: 9, reminderMinute: 0)
        let plan = planner.plan(for: [urgentBatch(status: .finished)], settings: settings, now: now)
        XCTAssertTrue(plan.isEmpty)
    }

    func testDiscardedBatchProducesNoReminder() {
        let settings = NotificationSettings(remindersEnabled: true, dailySummaryEnabled: false, reminderHour: 9, reminderMinute: 0)
        let plan = planner.plan(for: [urgentBatch(status: .discarded)], settings: settings, now: now)
        XCTAssertTrue(plan.isEmpty)
    }

    func testReminderTimeRespectsConfiguredLocalTime() {
        let settings = NotificationSettings(remindersEnabled: true, dailySummaryEnabled: false, reminderHour: 20, reminderMinute: 30)
        let plan = planner.plan(for: [urgentBatch()], settings: settings, now: now)
        let components = Calendar.current.dateComponents([.hour, .minute], from: plan[0].fireDate)
        XCTAssertEqual(components.hour, 20)
        XCTAssertEqual(components.minute, 30)
    }

    func testDailySummaryAddsAnExtraNotificationWhenEnabled() {
        let settings = NotificationSettings(remindersEnabled: true, dailySummaryEnabled: true, reminderHour: 9, reminderMinute: 0)
        let plan = planner.plan(for: [urgentBatch()], settings: settings, now: now)
        XCTAssertEqual(plan.count, 2)
    }
}

final class NotificationCoordinatorTests: XCTestCase {
    private final class DenyingScheduler: NotificationScheduling {
        var scheduledCount = 0
        func requestAuthorization() async -> Bool { false }
        func schedule(_ notification: PlannedNotification) async { scheduledCount += 1 }
        func removeAllPending() async {}
        func pendingIdentifiers() async -> Set<String> { [] }
    }

    @MainActor
    func testDeniedPermissionDoesNotCrashAndSchedulesNothing() async {
        let scheduler = DenyingScheduler()
        let coordinator = NotificationCoordinator(scheduler: scheduler, planner: DefaultNotificationPlanner(), clock: SystemClock())
        let settings = NotificationSettings(remindersEnabled: true, dailySummaryEnabled: false, reminderHour: 9, reminderMinute: 0)
        await coordinator.sync(batches: [], settings: settings)
        XCTAssertEqual(scheduler.scheduledCount, 0)
    }
}
