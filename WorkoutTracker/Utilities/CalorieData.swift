import Foundation

struct CalorieData {
    // All values are kcal/hour for a 70kg reference person
    // Scale by: userWeight / 70.0

    // MARK: - Musculation (weight training)
    static let musculationPerHour: [String: Double] = [
        "push": 400,
        "pull": 380,
        "legs": 450,
        "upper": 380,
        "lower": 420,
        "full body": 430,
        "fullbody": 430,
        "bras": 320,
        "arms": 320,
        "epaules": 350,
        "shoulders": 350,
        "pecs": 380,
        "chest": 380,
        "dos": 380,
        "back": 380,
        "abdos": 300,
        "abs": 300,
        "core": 300,
    ]

    static let defaultMusculationPerHour: Double = 400

    // MARK: - Running (kcal per minute by pace)
    // Approximate MET values: jogging 7 MET, running 10-12 MET
    static func runningCaloriesPerMinute(paceKmh: Double, weightKg: Double) -> Double {
        let met: Double
        switch paceKmh {
        case ..<7: met = 6.0     // ~6-7 km/h slow jog
        case 7..<9: met = 8.0   // ~8 km/h easy jog
        case 9..<11: met = 10.0 // ~10 km/h moderate
        case 11..<13: met = 11.5 // ~12 km/h fast
        case 13..<15: met = 13.0 // ~14 km/h tempo
        default: met = 15.0     // 15+ km/h sprint
        }
        // kcal/min = MET * weight(kg) * 3.5 / 200
        return met * weightKg * 3.5 / 200.0
    }

    // Simplified: running kcal for a given duration and distance
    static func runningCalories(durationMinutes: Double, distanceKm: Double, weightKg: Double) -> Double {
        guard durationMinutes > 0 else { return 0 }
        if distanceKm > 0 {
            let paceKmh = distanceKm / (durationMinutes / 60.0)
            return runningCaloriesPerMinute(paceKmh: paceKmh, weightKg: weightKg) * durationMinutes
        }
        // Default moderate pace if no distance
        return runningCaloriesPerMinute(paceKmh: 10, weightKg: weightKg) * durationMinutes
    }

    // Fractionne: higher intensity
    static func intervalCalories(durationMinutes: Double, weightKg: Double) -> Double {
        // HIIT running averages ~12 MET
        let met = 12.0
        return met * weightKg * 3.5 / 200.0 * durationMinutes
    }

    // MARK: - Sport Activities (kcal/hour for 70kg person)
    static let sportActivities: [String: Double] = [
        // Combat
        "boxe": 600,
        "boxing": 600,
        "kickboxing": 650,
        "mma": 650,
        "judo": 580,
        "karate": 550,
        "taekwondo": 580,
        "lutte": 550,
        "arts martiaux": 580,
        "martial arts": 580,
        "escrime": 400,

        // Ball sports
        "football": 500,
        "soccer": 500,
        "basketball": 520,
        "handball": 500,
        "rugby": 550,
        "volleyball": 350,
        "tennis": 450,
        "badminton": 400,
        "padel": 420,
        "squash": 550,
        "ping pong": 280,
        "table tennis": 280,
        "golf": 250,
        "baseball": 300,
        "cricket": 350,
        "hockey": 530,

        // Water
        "natation": 500,
        "swimming": 500,
        "surf": 350,
        "kayak": 400,
        "aviron": 500,
        "rowing": 500,
        "plongee": 350,
        "water polo": 580,

        // Cycling & wheels
        "velo": 450,
        "cycling": 450,
        "vtt": 520,
        "skateboard": 350,
        "roller": 400,
        "spinning": 550,

        // Fitness
        "crossfit": 600,
        "hiit": 550,
        "yoga": 200,
        "pilates": 250,
        "stretching": 150,
        "danse": 380,
        "dance": 380,
        "zumba": 450,
        "corde a sauter": 600,
        "jump rope": 600,
        "aerobic": 400,

        // Outdoor
        "escalade": 500,
        "climbing": 500,
        "randonnee": 350,
        "hiking": 350,
        "ski": 450,
        "snowboard": 400,
        "ski de fond": 550,
        "equitation": 280,
        "horse riding": 280,
        "marche": 250,
        "walking": 250,
        "trail": 500,
    ]

    static let defaultSportPerHour: Double = 400

    // MARK: - Estimation helpers

    static func musculationCalories(workoutName: String, durationMinutes: Double, weightKg: Double) -> Double {
        let name = workoutName.lowercased()
        let basePerHour = musculationPerHour.first(where: { name.contains($0.key) })?.value ?? defaultMusculationPerHour
        let scaled = basePerHour * (weightKg / 70.0)
        return scaled * (durationMinutes / 60.0)
    }

    static func sportCalories(activityName: String, durationMinutes: Double, weightKg: Double) -> Double {
        let name = activityName.lowercased()
        let basePerHour = sportActivities.first(where: { name.contains($0.key) })?.value ?? defaultSportPerHour
        let scaled = basePerHour * (weightKg / 70.0)
        return scaled * (durationMinutes / 60.0)
    }

    static func formatCalories(_ kcal: Double) -> String {
        if kcal >= 1000 {
            return String(format: "%.1fk", kcal / 1000)
        }
        return "\(Int(kcal))"
    }
}
