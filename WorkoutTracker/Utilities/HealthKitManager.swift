import Foundation

@Observable
final class HealthKitManager {
    var isAuthorized = false
    var isAvailable: Bool { false }

    func requestAuthorization() {
        // HealthKit nécessite un compte Apple Developer payant.
        // Cette classe est un stub no-op pour l'instant.
    }

    func saveWorkout(calories: Double, durationMinutes: Double, date: Date = Date()) {
        // No-op sans HealthKit entitlement
    }

    func readWeight(completion: @escaping (Double?) -> Void) {
        completion(nil)
    }
}
