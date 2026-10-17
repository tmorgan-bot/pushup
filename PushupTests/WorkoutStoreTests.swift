import XCTest
@testable import Pushup

@MainActor
final class WorkoutStoreTests: XCTestCase {
    private var defaults: UserDefaults!
    private var suite: String!

    override func setUp() async throws {
        suite = "PushupTests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suite)!
    }

    override func tearDown() async throws {
        defaults.removePersistentDomain(forName: suite)
    }

    func testSaveReloadAndDelete() {
        let store = WorkoutStore(defaults: defaults)
        XCTAssertTrue(store.add(reps: 12))
        store.setGoal(75)
        let reloaded = WorkoutStore(defaults: defaults)
        XCTAssertEqual(reloaded.sets.first?.reps, 12)
        XCTAssertEqual(reloaded.goal, 75)
        reloaded.delete(ids: Set(reloaded.sets.map(\.id)))
        XCTAssertTrue(WorkoutStore(defaults: defaults).sets.isEmpty)
    }

    func testTotalsUseCalendarDayAndRejectInvalidValues() {
        let store = WorkoutStore(defaults: defaults)
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 36000)!
        let today = calendar.date(from: DateComponents(year: 2026, month: 10, day: 17, hour: 12))!
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        XCTAssertTrue(store.add(reps: 10, date: today))
        XCTAssertTrue(store.add(reps: 20, date: yesterday))
        XCTAssertFalse(store.add(reps: 0))
        XCTAssertFalse(store.add(reps: 10001))
        XCTAssertEqual(store.total(on: today, calendar: calendar), 10)
        store.setGoal(0)
        XCTAssertEqual(store.goal, 50)
    }

    func testCorruptDataIsPreserved() {
        let data = Data("invalid".utf8)
        defaults.set(data, forKey: "pushup.workouts.v1")
        let store = WorkoutStore(defaults: defaults)
        XCTAssertNotNil(store.errorMessage)
        XCTAssertFalse(store.add(reps: 10))
        XCTAssertEqual(defaults.data(forKey: "pushup.workouts.v1"), data)
    }
}
