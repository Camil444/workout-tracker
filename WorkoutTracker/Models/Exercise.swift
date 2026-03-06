import Foundation
import SwiftData

enum ExerciseUnit: String, Codable, CaseIterable {
    case kg = "kg"
    case pdc = "PDC"
}

@Model
final class Exercise {
    var id: UUID
    var name: String
    var unitRaw: String
    var sortOrder: Int
    var workout: Workout?
    @Relationship(deleteRule: .cascade, inverse: \ExerciseLog.exercise)
    var logs: [ExerciseLog]

    var unit: ExerciseUnit {
        get { ExerciseUnit(rawValue: unitRaw) ?? .kg }
        set { unitRaw = newValue.rawValue }
    }

    init(
        name: String,
        unit: ExerciseUnit = .kg,
        sortOrder: Int = 0
    ) {
        self.id = UUID()
        self.name = name
        self.unitRaw = unit.rawValue
        self.sortOrder = sortOrder
        self.logs = []
    }

    var sortedLogs: [ExerciseLog] {
        logs.sorted { $0.weekNumber < $1.weekNumber }
    }

    var currentMax: Double {
        guard let lastLog = sortedLogs.last else { return 0 }
        if unit == .pdc {
            return Double(lastLog.sets.map(\.reps).max() ?? 0)
        } else {
            return lastLog.sets.map(\.weight).max() ?? 0
        }
    }

    var maxValues: [Double] {
        sortedLogs.map { log in
            if unit == .pdc {
                return Double(log.sets.map(\.reps).max() ?? 0)
            } else {
                return log.sets.map(\.weight).max() ?? 0
            }
        }
    }

    var progression: Double? {
        let values = maxValues
        guard values.count >= 2, let first = values.first, first > 0 else { return nil }
        guard let last = values.last else { return nil }
        return ((last - first) / first) * 100
    }

    var nextWeekNumber: Int {
        (sortedLogs.last?.weekNumber ?? 0) + 1
    }
}
