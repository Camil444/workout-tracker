import SwiftUI
import SwiftData

@Observable
final class WorkoutViewModel {
    var selectedTab: Int = 0
    var expandedWorkoutID: UUID?
    var expandedExerciseID: UUID?

    // Session state: started (timer running) vs logging (can log sets)
    var isSessionActive: Bool = false
    var isLogging: Bool = false

    // Session timer
    var sessionStartDate: Date?
    var sessionElapsed: TimeInterval = 0
    private var sessionTimer: Timer?

    // Rest timer
    var restTimerTotal: Int = 90
    var restTimerRemaining: Int = 0
    var isRestTimerRunning: Bool = false
    private var restTimer: Timer?

    // PR celebration
    var showPRCelebration: Bool = false
    var prExerciseName: String = ""
    var prValue: String = ""

    // Session end recap
    var showEndConfirmation: Bool = false
    var showSessionRecap: Bool = false
    var lastSessionDuration: TimeInterval = 0
    var lastSessionExerciseCount: Int = 0
    var sessionFeeling: String = ""

    func navigateToWorkout(_ workout: Workout) {
        expandedWorkoutID = workout.id
        expandedExerciseID = nil
        selectedTab = 1
        startSession()
    }

    func toggleWorkout(_ workout: Workout) {
        if expandedWorkoutID == workout.id {
            expandedWorkoutID = nil
            expandedExerciseID = nil
            isLogging = false
            if isSessionActive {
                // Ne pas stopper la session quand on ferme l'accordion
            }
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

    // MARK: - Session lifecycle

    func startSession() {
        isSessionActive = true
        isLogging = true
        startSessionTimer()
    }

    func startLogging() {
        isLogging = true
    }

    func stopLogging() {
        isLogging = false
    }

    func requestEndSession() {
        showEndConfirmation = true
    }

    func endSession(exerciseCount: Int) {
        lastSessionDuration = sessionElapsed
        lastSessionExerciseCount = exerciseCount
        sessionFeeling = ""
        isLogging = false
        isSessionActive = false
        stopRestTimer()
        stopSessionTimer()
        showEndConfirmation = false
        showSessionRecap = true
    }

    func dismissRecap() {
        showSessionRecap = false
        sessionFeeling = ""
    }

    // MARK: - Session Timer

    private func startSessionTimer() {
        guard sessionStartDate == nil else { return }
        sessionStartDate = Date()
        sessionTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                guard let self, let start = self.sessionStartDate else { return }
                self.sessionElapsed = Date().timeIntervalSince(start)
            }
        }
    }

    func stopSessionTimer() {
        sessionTimer?.invalidate()
        sessionTimer = nil
        sessionStartDate = nil
        sessionElapsed = 0
    }

    var sessionTimerFormatted: String {
        let total = Int(sessionElapsed)
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, s)
        }
        return String(format: "%02d:%02d", m, s)
    }

    func formatDuration(_ duration: TimeInterval) -> String {
        let total = Int(duration)
        let h = total / 3600
        let m = (total % 3600) / 60
        if h > 0 {
            return "\(h)h\(String(format: "%02d", m))"
        }
        return "\(m)min"
    }

    // MARK: - Rest Timer

    func startRestTimer(seconds: Int) {
        restTimerTotal = seconds
        restTimerRemaining = seconds
        isRestTimerRunning = true
        restTimer?.invalidate()
        restTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                guard let self else { return }
                if self.restTimerRemaining > 0 {
                    self.restTimerRemaining -= 1
                } else {
                    self.stopRestTimer()
                }
            }
        }
    }

    func stopRestTimer() {
        restTimer?.invalidate()
        restTimer = nil
        isRestTimerRunning = false
        restTimerRemaining = 0
    }

    var restTimerProgress: Double {
        guard restTimerTotal > 0 else { return 0 }
        return Double(restTimerTotal - restTimerRemaining) / Double(restTimerTotal)
    }

    // MARK: - PR Detection

    func checkForPR(exercise: Exercise, newSets: [SetEntry]) {
        let previousMax: Double
        if exercise.unit == .pdc {
            previousMax = Double(exercise.logs.flatMap(\.sets).map(\.reps).max() ?? 0)
        } else {
            previousMax = exercise.logs.flatMap(\.sets).map(\.weight).max() ?? 0
        }

        let newMax: Double
        if exercise.unit == .pdc {
            newMax = Double(newSets.map(\.reps).max() ?? 0)
        } else {
            newMax = newSets.map(\.weight).max() ?? 0
        }

        if newMax > previousMax && previousMax > 0 {
            prExerciseName = exercise.name
            if exercise.unit == .pdc {
                prValue = "\(Int(newMax)) reps"
            } else {
                prValue = "\(Int(newMax))kg"
            }
            showPRCelebration = true
        }
    }

    // MARK: - Best Exercise

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
