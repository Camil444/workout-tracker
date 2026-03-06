import Foundation
import SwiftData

@Model
final class SportActivity {
    var id: UUID
    var name: String
    var iconName: String
    var sortOrder: Int
    @Relationship(deleteRule: .cascade, inverse: \SportActivityLog.activity)
    var logs: [SportActivityLog]

    init(name: String, iconName: String = "figure.mixed.cardio", sortOrder: Int = 0) {
        self.id = UUID()
        self.name = name
        self.iconName = iconName
        self.sortOrder = sortOrder
        self.logs = []
    }
}

@Model
final class SportActivityLog {
    var id: UUID
    var date: Date
    var durationMinutes: Double
    var notes: String
    var activity: SportActivity?

    init(date: Date = Date(), durationMinutes: Double = 0, notes: String = "") {
        self.id = UUID()
        self.date = date
        self.durationMinutes = durationMinutes
        self.notes = notes
    }

    var durationFormatted: String {
        let hours = Int(durationMinutes) / 60
        let mins = Int(durationMinutes) % 60
        if hours > 0 {
            return "\(hours)h\(String(format: "%02d", mins))"
        }
        return "\(mins) min"
    }
}
