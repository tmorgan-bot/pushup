import Foundation
import Combine

struct PushupSet: Codable, Identifiable, Equatable {
    let id: UUID
    let date: Date
    let reps: Int

    init(id: UUID = UUID(), date: Date = Date(), reps: Int) {
        self.id = id
        self.date = date
        self.reps = reps
    }
}

@MainActor
final class WorkoutStore: ObservableObject {
    @Published private(set) var sets: [PushupSet] = []
    @Published private(set) var goal = 50
    @Published var errorMessage: String?
    private let defaults: UserDefaults
    private let key = "pushup.workouts.v1"
    private var canSave = true

    private struct Snapshot: Codable {
        var sets: [PushupSet]
        var goal: Int
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        guard let data = defaults.data(forKey: key) else { return }
        do {
            let snapshot = try JSONDecoder().decode(Snapshot.self, from: data)
            guard (1...1000).contains(snapshot.goal),
                  snapshot.sets.allSatisfy({ (1...10000).contains($0.reps) }) else {
                throw CocoaError(.coderReadCorrupt)
            }
            sets = snapshot.sets.sorted { $0.date > $1.date }
            goal = snapshot.goal
        } catch {
            // Preserve unreadable data instead of overwriting it with an empty history.
            canSave = false
            errorMessage = "Saved history could not be read. Changes cannot be saved until the stored data is recovered or the app is reinstalled."
        }
    }

    func total(on date: Date = Date(), calendar: Calendar = .current) -> Int {
        sets.filter { calendar.isDate($0.date, inSameDayAs: date) }
            .reduce(0) { $0 + $1.reps }
    }

    @discardableResult
    func add(reps: Int, date: Date = Date()) -> Bool {
        guard canSave, (1...10000).contains(reps) else { return false }
        return persist(sets: ([PushupSet(date: date, reps: reps)] + sets)
            .sorted { $0.date > $1.date }, goal: goal)
    }

    func delete(ids: Set<UUID>) {
        _ = persist(sets: sets.filter { !ids.contains($0.id) }, goal: goal)
    }

    func setGoal(_ value: Int) {
        guard (1...1000).contains(value) else { return }
        _ = persist(sets: sets, goal: value)
    }

    private func persist(sets: [PushupSet], goal: Int) -> Bool {
        guard canSave else { return false }
        do {
            let data = try JSONEncoder().encode(Snapshot(sets: sets, goal: goal))
            defaults.set(data, forKey: key)
            self.sets = sets
            self.goal = goal
            return true
        } catch {
            errorMessage = "Your changes could not be saved. Please try again."
            return false
        }
    }
}
