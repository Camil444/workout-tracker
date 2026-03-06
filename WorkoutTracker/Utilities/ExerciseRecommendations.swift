import Foundation

struct ExerciseRecommendation: Identifiable {
    let id = UUID()
    let name: String
    let unit: ExerciseUnit
}

enum ExerciseRecommendations {
    static func suggestions(for workoutName: String) -> [ExerciseRecommendation] {
        let name = workoutName.lowercased()
            .folding(options: .diacriticInsensitive, locale: .current)

        for (keywords, exercises) in mappings {
            if keywords.contains(where: { name.contains($0) }) {
                return exercises
            }
        }
        return []
    }

    private static let mappings: [([String], [ExerciseRecommendation])] = [
        // Push
        (["push", "poussee", "pousser", "poussée"], [
            ExerciseRecommendation(name: "Développé couché", unit: .kg),
            ExerciseRecommendation(name: "Développé incliné haltères", unit: .kg),
            ExerciseRecommendation(name: "Développé militaire", unit: .kg),
            ExerciseRecommendation(name: "Dips", unit: .pdc),
            ExerciseRecommendation(name: "Élévations latérales", unit: .kg),
            ExerciseRecommendation(name: "Butterfly pec deck", unit: .kg),
            ExerciseRecommendation(name: "Extension triceps poulie", unit: .kg),
            ExerciseRecommendation(name: "Skull crushers", unit: .kg),
            ExerciseRecommendation(name: "Développé couché haltères", unit: .kg),
            ExerciseRecommendation(name: "Élévations frontales", unit: .kg),
        ]),

        // Pull
        (["pull", "tirage", "tirer"], [
            ExerciseRecommendation(name: "Tractions", unit: .pdc),
            ExerciseRecommendation(name: "Rowing barre", unit: .kg),
            ExerciseRecommendation(name: "Tirage vertical", unit: .kg),
            ExerciseRecommendation(name: "Rowing haltère", unit: .kg),
            ExerciseRecommendation(name: "Curl biceps barre", unit: .kg),
            ExerciseRecommendation(name: "Curl haltères", unit: .kg),
            ExerciseRecommendation(name: "Face pull", unit: .kg),
            ExerciseRecommendation(name: "Tirage horizontal", unit: .kg),
            ExerciseRecommendation(name: "Curl marteau", unit: .kg),
            ExerciseRecommendation(name: "Shrugs", unit: .kg),
        ]),

        // Legs
        (["leg", "jambe", "jambes", "lower", "bas du corps"], [
            ExerciseRecommendation(name: "Squat", unit: .kg),
            ExerciseRecommendation(name: "Presse à cuisses", unit: .kg),
            ExerciseRecommendation(name: "Soulevé de terre roumain", unit: .kg),
            ExerciseRecommendation(name: "Fentes", unit: .kg),
            ExerciseRecommendation(name: "Leg extension", unit: .kg),
            ExerciseRecommendation(name: "Leg curl", unit: .kg),
            ExerciseRecommendation(name: "Hip thrust", unit: .kg),
            ExerciseRecommendation(name: "Mollets debout", unit: .kg),
            ExerciseRecommendation(name: "Hack squat", unit: .kg),
            ExerciseRecommendation(name: "Bulgarian split squat", unit: .kg),
        ]),

        // Chest / Pectoraux
        (["chest", "pec", "pecs", "pectora", "poitrine", "torse"], [
            ExerciseRecommendation(name: "Développé couché", unit: .kg),
            ExerciseRecommendation(name: "Développé incliné", unit: .kg),
            ExerciseRecommendation(name: "Développé décliné", unit: .kg),
            ExerciseRecommendation(name: "Écarté haltères", unit: .kg),
            ExerciseRecommendation(name: "Butterfly pec deck", unit: .kg),
            ExerciseRecommendation(name: "Pompes", unit: .pdc),
            ExerciseRecommendation(name: "Poulie vis-à-vis", unit: .kg),
            ExerciseRecommendation(name: "Dips", unit: .pdc),
        ]),

        // Back / Dos
        (["back", "dos"], [
            ExerciseRecommendation(name: "Tractions", unit: .pdc),
            ExerciseRecommendation(name: "Soulevé de terre", unit: .kg),
            ExerciseRecommendation(name: "Rowing barre", unit: .kg),
            ExerciseRecommendation(name: "Tirage vertical", unit: .kg),
            ExerciseRecommendation(name: "Tirage horizontal", unit: .kg),
            ExerciseRecommendation(name: "Rowing haltère", unit: .kg),
            ExerciseRecommendation(name: "Pull-over", unit: .kg),
            ExerciseRecommendation(name: "Face pull", unit: .kg),
        ]),

        // Shoulders / Épaules
        (["shoulder", "epaule", "épaule", "epaules", "épaules", "delto"], [
            ExerciseRecommendation(name: "Développé militaire", unit: .kg),
            ExerciseRecommendation(name: "Élévations latérales", unit: .kg),
            ExerciseRecommendation(name: "Élévations frontales", unit: .kg),
            ExerciseRecommendation(name: "Oiseau", unit: .kg),
            ExerciseRecommendation(name: "Face pull", unit: .kg),
            ExerciseRecommendation(name: "Arnold press", unit: .kg),
            ExerciseRecommendation(name: "Shrugs", unit: .kg),
        ]),

        // Arms / Bras
        (["arm", "bras", "bicep", "tricep"], [
            ExerciseRecommendation(name: "Curl biceps barre", unit: .kg),
            ExerciseRecommendation(name: "Curl haltères", unit: .kg),
            ExerciseRecommendation(name: "Curl marteau", unit: .kg),
            ExerciseRecommendation(name: "Extension triceps poulie", unit: .kg),
            ExerciseRecommendation(name: "Skull crushers", unit: .kg),
            ExerciseRecommendation(name: "Dips", unit: .pdc),
            ExerciseRecommendation(name: "Curl concentré", unit: .kg),
            ExerciseRecommendation(name: "Kickback triceps", unit: .kg),
        ]),

        // Full body
        (["full", "complet", "total"], [
            ExerciseRecommendation(name: "Squat", unit: .kg),
            ExerciseRecommendation(name: "Développé couché", unit: .kg),
            ExerciseRecommendation(name: "Soulevé de terre", unit: .kg),
            ExerciseRecommendation(name: "Tractions", unit: .pdc),
            ExerciseRecommendation(name: "Développé militaire", unit: .kg),
            ExerciseRecommendation(name: "Rowing barre", unit: .kg),
            ExerciseRecommendation(name: "Dips", unit: .pdc),
            ExerciseRecommendation(name: "Fentes", unit: .kg),
        ]),

        // Upper body / Haut du corps
        (["upper", "haut du corps", "haut"], [
            ExerciseRecommendation(name: "Développé couché", unit: .kg),
            ExerciseRecommendation(name: "Tractions", unit: .pdc),
            ExerciseRecommendation(name: "Développé militaire", unit: .kg),
            ExerciseRecommendation(name: "Rowing barre", unit: .kg),
            ExerciseRecommendation(name: "Dips", unit: .pdc),
            ExerciseRecommendation(name: "Curl biceps barre", unit: .kg),
            ExerciseRecommendation(name: "Élévations latérales", unit: .kg),
            ExerciseRecommendation(name: "Extension triceps poulie", unit: .kg),
        ]),

        // Abs / Abdos
        (["abs", "abdo", "abdos", "abdominaux", "core", "gainage"], [
            ExerciseRecommendation(name: "Crunch", unit: .pdc),
            ExerciseRecommendation(name: "Planche", unit: .pdc),
            ExerciseRecommendation(name: "Relevé de jambes", unit: .pdc),
            ExerciseRecommendation(name: "Russian twist", unit: .kg),
            ExerciseRecommendation(name: "Ab wheel", unit: .pdc),
            ExerciseRecommendation(name: "Mountain climbers", unit: .pdc),
            ExerciseRecommendation(name: "Crunch câble", unit: .kg),
        ]),
    ]
}
