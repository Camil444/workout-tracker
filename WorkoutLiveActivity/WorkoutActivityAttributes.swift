import ActivityKit
import Foundation

struct WorkoutActivityAttributes: ActivityAttributes {
    // Fixed: set once when activity starts
    var sessionStartDate: Date

    struct ContentState: Codable, Hashable {
        var isRestTimerRunning: Bool
        var restTimerEndDate: Date?
        var restTimerTotal: Int // seconds
        var exerciseCount: Int
    }
}
