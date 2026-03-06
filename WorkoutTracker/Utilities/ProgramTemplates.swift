import Foundation

struct ProgramTemplate {
    let name: String
    let description: String
    let daysPerWeek: Int
    let days: [ProgramDay]
}

struct ProgramDay {
    let name: String
    let iconName: String
    let exercises: [TemplateExercise]
}

struct TemplateExercise {
    let name: String
    let unit: ExerciseUnit
    let sets: Int
    let reps: String // "8-12" or "15"
}

struct IntervalTemplate {
    let name: String
    let warmUpMin: Int
    let coolDownMin: Int
    let intervals: Int
    let workSec: Int
    let restSec: Int
    let description: String
}

struct ProgramTemplates {

    // MARK: - PPL (Push/Pull/Legs) - 6 days
    static let ppl = ProgramTemplate(
        name: "Push / Pull / Legs",
        description: "6 jours/semaine - Programme classique pour hypertrophie",
        daysPerWeek: 6,
        days: [
            ProgramDay(name: "Push A", iconName: "figure.strengthtraining.traditional", exercises: [
                TemplateExercise(name: "Developpe couche", unit: .kg, sets: 4, reps: "6-8"),
                TemplateExercise(name: "Developpe incline halteres", unit: .kg, sets: 3, reps: "8-10"),
                TemplateExercise(name: "Ecarte poulie vis-a-vis", unit: .kg, sets: 3, reps: "12-15"),
                TemplateExercise(name: "Developpe militaire", unit: .kg, sets: 4, reps: "8-10"),
                TemplateExercise(name: "Elevations laterales", unit: .kg, sets: 4, reps: "12-15"),
                TemplateExercise(name: "Triceps poulie haute", unit: .kg, sets: 3, reps: "10-12"),
                TemplateExercise(name: "Dips", unit: .pdc, sets: 3, reps: "8-12"),
            ]),
            ProgramDay(name: "Pull A", iconName: "figure.strengthtraining.functional", exercises: [
                TemplateExercise(name: "Tractions", unit: .pdc, sets: 4, reps: "6-10"),
                TemplateExercise(name: "Rowing barre", unit: .kg, sets: 4, reps: "8-10"),
                TemplateExercise(name: "Tirage vertical prise serree", unit: .kg, sets: 3, reps: "10-12"),
                TemplateExercise(name: "Rowing un bras haltere", unit: .kg, sets: 3, reps: "10-12"),
                TemplateExercise(name: "Face pull", unit: .kg, sets: 3, reps: "15-20"),
                TemplateExercise(name: "Curl barre EZ", unit: .kg, sets: 3, reps: "10-12"),
                TemplateExercise(name: "Curl marteau", unit: .kg, sets: 3, reps: "10-12"),
            ]),
            ProgramDay(name: "Legs A", iconName: "figure.walk", exercises: [
                TemplateExercise(name: "Squat", unit: .kg, sets: 4, reps: "6-8"),
                TemplateExercise(name: "Presse a cuisses", unit: .kg, sets: 4, reps: "10-12"),
                TemplateExercise(name: "Fentes marchees", unit: .kg, sets: 3, reps: "10/jambe"),
                TemplateExercise(name: "Leg curl", unit: .kg, sets: 4, reps: "10-12"),
                TemplateExercise(name: "Extension mollets debout", unit: .kg, sets: 4, reps: "12-15"),
                TemplateExercise(name: "Hip thrust", unit: .kg, sets: 3, reps: "10-12"),
            ]),
            ProgramDay(name: "Push B", iconName: "figure.strengthtraining.traditional", exercises: [
                TemplateExercise(name: "Developpe incline barre", unit: .kg, sets: 4, reps: "6-8"),
                TemplateExercise(name: "Developpe couche halteres", unit: .kg, sets: 3, reps: "8-10"),
                TemplateExercise(name: "Poulie vis-a-vis basse", unit: .kg, sets: 3, reps: "12-15"),
                TemplateExercise(name: "Elevations laterales", unit: .kg, sets: 4, reps: "12-15"),
                TemplateExercise(name: "Oiseau arriere", unit: .kg, sets: 3, reps: "12-15"),
                TemplateExercise(name: "Barre au front", unit: .kg, sets: 3, reps: "10-12"),
                TemplateExercise(name: "Extension triceps poulie", unit: .kg, sets: 3, reps: "12-15"),
            ]),
            ProgramDay(name: "Pull B", iconName: "figure.strengthtraining.functional", exercises: [
                TemplateExercise(name: "Souleve de terre", unit: .kg, sets: 4, reps: "5-6"),
                TemplateExercise(name: "Tirage horizontal poulie", unit: .kg, sets: 4, reps: "10-12"),
                TemplateExercise(name: "Tirage vertical prise large", unit: .kg, sets: 3, reps: "8-10"),
                TemplateExercise(name: "Pullover poulie", unit: .kg, sets: 3, reps: "12-15"),
                TemplateExercise(name: "Face pull", unit: .kg, sets: 3, reps: "15-20"),
                TemplateExercise(name: "Curl incline", unit: .kg, sets: 3, reps: "10-12"),
                TemplateExercise(name: "Curl concentration", unit: .kg, sets: 3, reps: "10-12"),
            ]),
            ProgramDay(name: "Legs B", iconName: "figure.walk", exercises: [
                TemplateExercise(name: "Souleve de terre roumain", unit: .kg, sets: 4, reps: "8-10"),
                TemplateExercise(name: "Squat bulgare", unit: .kg, sets: 3, reps: "10/jambe"),
                TemplateExercise(name: "Leg extension", unit: .kg, sets: 4, reps: "12-15"),
                TemplateExercise(name: "Leg curl", unit: .kg, sets: 4, reps: "10-12"),
                TemplateExercise(name: "Adducteurs machine", unit: .kg, sets: 3, reps: "12-15"),
                TemplateExercise(name: "Extension mollets assis", unit: .kg, sets: 4, reps: "15-20"),
            ]),
        ]
    )

    // MARK: - Upper/Lower - 4 days
    static let upperLower = ProgramTemplate(
        name: "Upper / Lower",
        description: "4 jours/semaine - Equilibre force et volume",
        daysPerWeek: 4,
        days: [
            ProgramDay(name: "Upper A (Force)", iconName: "figure.strengthtraining.traditional", exercises: [
                TemplateExercise(name: "Developpe couche", unit: .kg, sets: 4, reps: "5-6"),
                TemplateExercise(name: "Rowing barre", unit: .kg, sets: 4, reps: "5-6"),
                TemplateExercise(name: "Developpe militaire", unit: .kg, sets: 3, reps: "6-8"),
                TemplateExercise(name: "Tractions lestees", unit: .kg, sets: 3, reps: "6-8"),
                TemplateExercise(name: "Curl barre", unit: .kg, sets: 3, reps: "8-10"),
                TemplateExercise(name: "Triceps poulie", unit: .kg, sets: 3, reps: "8-10"),
            ]),
            ProgramDay(name: "Lower A (Force)", iconName: "figure.walk", exercises: [
                TemplateExercise(name: "Squat", unit: .kg, sets: 4, reps: "5-6"),
                TemplateExercise(name: "Souleve de terre roumain", unit: .kg, sets: 4, reps: "6-8"),
                TemplateExercise(name: "Presse a cuisses", unit: .kg, sets: 3, reps: "8-10"),
                TemplateExercise(name: "Leg curl", unit: .kg, sets: 3, reps: "8-10"),
                TemplateExercise(name: "Extension mollets", unit: .kg, sets: 4, reps: "10-12"),
                TemplateExercise(name: "Crunch poulie", unit: .kg, sets: 3, reps: "12-15"),
            ]),
            ProgramDay(name: "Upper B (Volume)", iconName: "figure.strengthtraining.traditional", exercises: [
                TemplateExercise(name: "Developpe incline halteres", unit: .kg, sets: 4, reps: "10-12"),
                TemplateExercise(name: "Tirage vertical", unit: .kg, sets: 4, reps: "10-12"),
                TemplateExercise(name: "Ecarte poulie", unit: .kg, sets: 3, reps: "12-15"),
                TemplateExercise(name: "Rowing haltere", unit: .kg, sets: 3, reps: "10-12"),
                TemplateExercise(name: "Elevations laterales", unit: .kg, sets: 4, reps: "15-20"),
                TemplateExercise(name: "Curl marteau", unit: .kg, sets: 3, reps: "12-15"),
                TemplateExercise(name: "Dips", unit: .pdc, sets: 3, reps: "10-15"),
            ]),
            ProgramDay(name: "Lower B (Volume)", iconName: "figure.walk", exercises: [
                TemplateExercise(name: "Squat bulgare", unit: .kg, sets: 4, reps: "10-12"),
                TemplateExercise(name: "Hip thrust", unit: .kg, sets: 4, reps: "10-12"),
                TemplateExercise(name: "Leg extension", unit: .kg, sets: 3, reps: "12-15"),
                TemplateExercise(name: "Leg curl", unit: .kg, sets: 3, reps: "12-15"),
                TemplateExercise(name: "Adducteurs", unit: .kg, sets: 3, reps: "12-15"),
                TemplateExercise(name: "Gainage", unit: .pdc, sets: 3, reps: "45sec"),
            ]),
        ]
    )

    // MARK: - Full Body - 3 days
    static let fullBody = ProgramTemplate(
        name: "Full Body",
        description: "3 jours/semaine - Ideal pour debutants/intermediaires",
        daysPerWeek: 3,
        days: [
            ProgramDay(name: "Jour A", iconName: "bolt.fill", exercises: [
                TemplateExercise(name: "Squat", unit: .kg, sets: 4, reps: "6-8"),
                TemplateExercise(name: "Developpe couche", unit: .kg, sets: 4, reps: "6-8"),
                TemplateExercise(name: "Rowing barre", unit: .kg, sets: 4, reps: "8-10"),
                TemplateExercise(name: "Developpe militaire", unit: .kg, sets: 3, reps: "8-10"),
                TemplateExercise(name: "Curl barre", unit: .kg, sets: 3, reps: "10-12"),
                TemplateExercise(name: "Extension mollets", unit: .kg, sets: 3, reps: "12-15"),
            ]),
            ProgramDay(name: "Jour B", iconName: "bolt.fill", exercises: [
                TemplateExercise(name: "Souleve de terre", unit: .kg, sets: 4, reps: "5-6"),
                TemplateExercise(name: "Developpe incline halteres", unit: .kg, sets: 4, reps: "8-10"),
                TemplateExercise(name: "Tractions", unit: .pdc, sets: 4, reps: "6-10"),
                TemplateExercise(name: "Elevations laterales", unit: .kg, sets: 3, reps: "12-15"),
                TemplateExercise(name: "Dips", unit: .pdc, sets: 3, reps: "8-12"),
                TemplateExercise(name: "Crunch", unit: .pdc, sets: 3, reps: "15-20"),
            ]),
            ProgramDay(name: "Jour C", iconName: "bolt.fill", exercises: [
                TemplateExercise(name: "Presse a cuisses", unit: .kg, sets: 4, reps: "10-12"),
                TemplateExercise(name: "Developpe couche halteres", unit: .kg, sets: 4, reps: "8-10"),
                TemplateExercise(name: "Tirage horizontal", unit: .kg, sets: 4, reps: "10-12"),
                TemplateExercise(name: "Hip thrust", unit: .kg, sets: 3, reps: "10-12"),
                TemplateExercise(name: "Face pull", unit: .kg, sets: 3, reps: "15-20"),
                TemplateExercise(name: "Curl marteau", unit: .kg, sets: 3, reps: "10-12"),
            ]),
        ]
    )

    // MARK: - Bro Split - 5 days
    static let broSplit = ProgramTemplate(
        name: "Bro Split",
        description: "5 jours/semaine - Un groupe musculaire par jour",
        daysPerWeek: 5,
        days: [
            ProgramDay(name: "Pecs", iconName: "figure.strengthtraining.traditional", exercises: [
                TemplateExercise(name: "Developpe couche", unit: .kg, sets: 4, reps: "6-8"),
                TemplateExercise(name: "Developpe incline halteres", unit: .kg, sets: 4, reps: "8-10"),
                TemplateExercise(name: "Ecarte couche", unit: .kg, sets: 3, reps: "10-12"),
                TemplateExercise(name: "Poulie vis-a-vis", unit: .kg, sets: 3, reps: "12-15"),
                TemplateExercise(name: "Pullover", unit: .kg, sets: 3, reps: "10-12"),
            ]),
            ProgramDay(name: "Dos", iconName: "figure.strengthtraining.functional", exercises: [
                TemplateExercise(name: "Souleve de terre", unit: .kg, sets: 4, reps: "5-6"),
                TemplateExercise(name: "Tractions", unit: .pdc, sets: 4, reps: "6-10"),
                TemplateExercise(name: "Rowing barre", unit: .kg, sets: 4, reps: "8-10"),
                TemplateExercise(name: "Tirage vertical prise serree", unit: .kg, sets: 3, reps: "10-12"),
                TemplateExercise(name: "Rowing un bras", unit: .kg, sets: 3, reps: "10-12"),
            ]),
            ProgramDay(name: "Epaules", iconName: "figure.arms.open", exercises: [
                TemplateExercise(name: "Developpe militaire", unit: .kg, sets: 4, reps: "6-8"),
                TemplateExercise(name: "Elevations laterales", unit: .kg, sets: 4, reps: "12-15"),
                TemplateExercise(name: "Oiseau arriere", unit: .kg, sets: 4, reps: "12-15"),
                TemplateExercise(name: "Face pull", unit: .kg, sets: 3, reps: "15-20"),
                TemplateExercise(name: "Shrugs", unit: .kg, sets: 3, reps: "10-12"),
            ]),
            ProgramDay(name: "Bras", iconName: "figure.boxing", exercises: [
                TemplateExercise(name: "Curl barre EZ", unit: .kg, sets: 4, reps: "8-10"),
                TemplateExercise(name: "Barre au front", unit: .kg, sets: 4, reps: "8-10"),
                TemplateExercise(name: "Curl marteau", unit: .kg, sets: 3, reps: "10-12"),
                TemplateExercise(name: "Triceps poulie haute", unit: .kg, sets: 3, reps: "10-12"),
                TemplateExercise(name: "Curl concentration", unit: .kg, sets: 3, reps: "12-15"),
                TemplateExercise(name: "Kickback triceps", unit: .kg, sets: 3, reps: "12-15"),
            ]),
            ProgramDay(name: "Jambes", iconName: "figure.walk", exercises: [
                TemplateExercise(name: "Squat", unit: .kg, sets: 4, reps: "6-8"),
                TemplateExercise(name: "Presse a cuisses", unit: .kg, sets: 4, reps: "10-12"),
                TemplateExercise(name: "Leg curl", unit: .kg, sets: 4, reps: "10-12"),
                TemplateExercise(name: "Leg extension", unit: .kg, sets: 3, reps: "12-15"),
                TemplateExercise(name: "Hip thrust", unit: .kg, sets: 3, reps: "10-12"),
                TemplateExercise(name: "Extension mollets", unit: .kg, sets: 4, reps: "12-15"),
            ]),
        ]
    )

    static let allMuscu: [ProgramTemplate] = [ppl, upperLower, fullBody, broSplit]

    // MARK: - Interval Running Templates
    static let intervalTemplates: [IntervalTemplate] = [
        IntervalTemplate(name: "30/30 Classique", warmUpMin: 10, coolDownMin: 5, intervals: 10, workSec: 30, restSec: 30, description: "10x (30s sprint / 30s repos) - Ideal pour debuter le fractionne"),
        IntervalTemplate(name: "1min/1min", warmUpMin: 10, coolDownMin: 5, intervals: 8, workSec: 60, restSec: 60, description: "8x (1min effort / 1min repos) - Endurance a haute intensite"),
        IntervalTemplate(name: "Tabata Running", warmUpMin: 10, coolDownMin: 5, intervals: 8, workSec: 20, restSec: 10, description: "8x (20s sprint max / 10s repos) - Intensite maximale, 4min d'effort"),
        IntervalTemplate(name: "Pyramide", warmUpMin: 10, coolDownMin: 5, intervals: 5, workSec: 60, restSec: 45, description: "30s-45s-60s-45s-30s effort avec repos egal - Progressif"),
        IntervalTemplate(name: "Long Intervals", warmUpMin: 10, coolDownMin: 5, intervals: 5, workSec: 180, restSec: 120, description: "5x (3min soutenu / 2min repos) - Seuil anaerobie"),
    ]
}
