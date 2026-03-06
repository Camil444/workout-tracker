import Foundation
import SwiftData

enum RunningType: String, Codable, CaseIterable {
    case footing = "Footing"
    case interval = "Fractionné"
}

@Model
final class RunningSessionType {
    var id: UUID
    var name: String
    var type: String // RunningType rawValue
    var sortOrder: Int
    @Relationship(deleteRule: .cascade, inverse: \RunningLog.sessionType)
    var logs: [RunningLog]

    var runningType: RunningType {
        get { RunningType(rawValue: type) ?? .footing }
        set { type = newValue.rawValue }
    }

    init(name: String, runningType: RunningType = .footing, sortOrder: Int = 0) {
        self.id = UUID()
        self.name = name
        self.type = runningType.rawValue
        self.sortOrder = sortOrder
        self.logs = []
    }
}

@Model
final class RunningLog {
    var id: UUID
    var date: Date
    var durationMinutes: Double
    var distanceKm: Double
    var averagePaceSecondsPerKm: Double
    // Fractionné fields
    var warmUpMinutes: Double
    var coolDownMinutes: Double
    var intervalCount: Int
    var workDurationSeconds: Int
    var restDurationSeconds: Int
    var sessionType: RunningSessionType?

    init(
        date: Date = Date(),
        durationMinutes: Double = 0,
        distanceKm: Double = 0,
        averagePaceSecondsPerKm: Double = 0,
        warmUpMinutes: Double = 0,
        coolDownMinutes: Double = 0,
        intervalCount: Int = 0,
        workDurationSeconds: Int = 0,
        restDurationSeconds: Int = 0
    ) {
        self.id = UUID()
        self.date = date
        self.durationMinutes = durationMinutes
        self.distanceKm = distanceKm
        self.averagePaceSecondsPerKm = averagePaceSecondsPerKm
        self.warmUpMinutes = warmUpMinutes
        self.coolDownMinutes = coolDownMinutes
        self.intervalCount = intervalCount
        self.workDurationSeconds = workDurationSeconds
        self.restDurationSeconds = restDurationSeconds
    }

    var paceFormatted: String {
        guard averagePaceSecondsPerKm > 0 else { return "-" }
        let mins = Int(averagePaceSecondsPerKm) / 60
        let secs = Int(averagePaceSecondsPerKm) % 60
        return String(format: "%d'%02d\"/km", mins, secs)
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
