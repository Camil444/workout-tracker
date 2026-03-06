import Foundation
import SwiftData

@Model
final class ExerciseLog {
    var id: UUID
    var weekNumber: Int
    var date: Date
    var setsData: Data
    var notes: String
    var exercise: Exercise?

    var sets: [SetEntry] {
        get {
            do {
                return try JSONDecoder().decode([SetEntry].self, from: setsData)
            } catch {
                print("[ExerciseLog] Failed to decode sets: \(error)")
                return []
            }
        }
        set {
            do {
                setsData = try JSONEncoder().encode(newValue)
            } catch {
                print("[ExerciseLog] Failed to encode sets: \(error) — keeping previous data")
            }
        }
    }

    init(weekNumber: Int, sets: [SetEntry] = [], notes: String = "") {
        self.id = UUID()
        self.weekNumber = weekNumber
        self.date = Date()
        self.setsData = (try? JSONEncoder().encode(sets)) ?? Data()
        self.notes = notes
    }

    var maxWeight: Double {
        sets.map(\.weight).max() ?? 0
    }

    var maxReps: Int {
        sets.map(\.reps).max() ?? 0
    }
}
