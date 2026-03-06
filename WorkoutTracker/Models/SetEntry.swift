import Foundation

struct SetEntry: Codable, Hashable {
    var reps: Int
    var weight: Double

    init(reps: Int = 0, weight: Double = 0) {
        self.reps = reps
        self.weight = weight
    }

    var displayString: String {
        if weight == 0 {
            return "\(reps) x PDC"
        }
        let weightStr = weight.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", weight)
            : String(format: "%.1f", weight)
        return "\(reps) x \(weightStr)kg"
    }
}
