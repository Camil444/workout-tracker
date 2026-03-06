import Foundation
import HealthKit

@Observable
final class HealthKitManager {
    private let store = HKHealthStore()
    var isAuthorized = false
    var isAvailable: Bool { HKHealthStore.isHealthDataAvailable() }

    func requestAuthorization() {
        guard isAvailable else { return }

        let writeTypes: Set<HKSampleType> = [
            HKQuantityType(.activeEnergyBurned),
            HKQuantityType(.appleExerciseTime),
        ]
        let readTypes: Set<HKObjectType> = [
            HKQuantityType(.bodyMass),
        ]

        store.requestAuthorization(toShare: writeTypes, read: readTypes) { [weak self] success, _ in
            DispatchQueue.main.async {
                self?.isAuthorized = success
            }
        }
    }

    func saveWorkout(calories: Double, durationMinutes: Double, date: Date = Date()) {
        guard isAuthorized, calories > 0, durationMinutes > 0 else { return }

        let energyType = HKQuantityType(.activeEnergyBurned)
        let energyQuantity = HKQuantity(unit: .kilocalorie(), doubleValue: calories)
        let start = date.addingTimeInterval(-durationMinutes * 60)
        let end = date

        let sample = HKQuantitySample(type: energyType, quantity: energyQuantity, start: start, end: end)
        store.save(sample) { _, error in
            if let error {
                print("[HealthKit] Save error: \(error.localizedDescription)")
            }
        }
    }

    func readWeight(completion: @escaping (Double?) -> Void) {
        guard isAvailable else {
            completion(nil)
            return
        }

        let weightType = HKQuantityType(.bodyMass)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: weightType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { _, samples, _ in
            guard let sample = samples?.first as? HKQuantitySample else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            let kg = sample.quantity.doubleValue(for: .gramUnit(with: .kilo))
            DispatchQueue.main.async { completion(kg) }
        }
        store.execute(query)
    }
}
