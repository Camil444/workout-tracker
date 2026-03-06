import SwiftUI
import SwiftData

@Observable
final class WorkoutViewModel {
    var selectedTab: Int = 0
    var expandedWorkoutID: UUID?
    var expandedExerciseID: UUID?
    var isLogging: Bool = false

    func navigateToWorkout(_ workout: Workout) {
        expandedWorkoutID = workout.id
        expandedExerciseID = nil
        isLogging = false
        selectedTab = 1
    }

    func toggleWorkout(_ workout: Workout) {
        if expandedWorkoutID == workout.id {
            expandedWorkoutID = nil
            expandedExerciseID = nil
            isLogging = false
        } else {
            expandedWorkoutID = workout.id
            expandedExerciseID = nil
            isLogging = false
        }
    }

    func toggleExercise(_ exercise: Exercise) {
        if expandedExerciseID == exercise.id {
            expandedExerciseID = nil
        } else {
            expandedExerciseID = exercise.id
        }
    }

    func startLogging() {
        isLogging = true
    }

    func cancelLogging() {
        isLogging = false
    }

    func bestExercise(in workout: Workout) -> (name: String, value: Double, unit: ExerciseUnit)? {
        var best: (name: String, value: Double, unit: ExerciseUnit)?
        for exercise in workout.exercises {
            let max = exercise.currentMax
            if max > 0 {
                if best == nil || (exercise.unit == .kg && max > (best?.value ?? 0)) {
                    best = (exercise.name, max, exercise.unit)
                }
            }
        }
        if best == nil {
            for exercise in workout.exercises {
                let max = exercise.currentMax
                if max > 0 {
                    best = (exercise.name, max, exercise.unit)
                    break
                }
            }
        }
        return best
    }
}
