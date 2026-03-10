import SwiftUI
import SwiftData
import AudioToolbox
import UserNotifications

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
    private var restTimerEndDate: Date?

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

    // MARK: - Persistence Keys
    private let kSessionStartDate = "session_startDate"
    private let kSessionActive = "session_isActive"
    private let kSessionWorkoutID = "session_workoutID"
    private let kRestTimerEndDate = "rest_timerEndDate"
    private let kRestTimerTotal = "rest_timerTotal"

    init() {
        requestNotificationPermission()
        restoreSessionIfNeeded()
    }

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
        } else {
            expandedWorkoutID = workout.id
            expandedExerciseID = nil
            isLogging = isSessionActive
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
        persistSession()
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
        clearPersistedSession()
    }

    func dismissRecap() {
        showSessionRecap = false
        sessionFeeling = ""
    }

    // MARK: - Session Timer

    private func startSessionTimer() {
        if sessionStartDate == nil {
            sessionStartDate = Date()
        }
        sessionTimer?.invalidate()
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
        restTimerEndDate = Date().addingTimeInterval(Double(seconds))
        restTimer?.invalidate()
        restTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                guard let self else { return }
                if self.restTimerRemaining > 0 {
                    self.restTimerRemaining -= 1
                    if self.restTimerRemaining == 0 {
                        self.onRestTimerFinished()
                    }
                } else {
                    self.stopRestTimer()
                }
            }
        }
        persistRestTimer()
        scheduleRestTimerNotification(seconds: seconds)
    }

    func stopRestTimer() {
        restTimer?.invalidate()
        restTimer = nil
        isRestTimerRunning = false
        restTimerRemaining = 0
        restTimerEndDate = nil
        clearPersistedRestTimer()
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["restTimerEnd"])
    }

    private func onRestTimerFinished() {
        // Play sound
        AudioServicesPlaySystemSound(1007) // Tock sound
        // Vibrate
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        stopRestTimer()
    }

    var restTimerProgress: Double {
        guard restTimerTotal > 0 else { return 0 }
        return Double(restTimerTotal - restTimerRemaining) / Double(restTimerTotal)
    }

    // MARK: - Notifications

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    private func scheduleRestTimerNotification(seconds: Int) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["restTimerEnd"])
        let content = UNMutableNotificationContent()
        content.title = "Repos termine"
        content.body = "C'est reparti ! Lance ta prochaine serie."
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: Double(seconds), repeats: false)
        let request = UNNotificationRequest(identifier: "restTimerEnd", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Background Persistence

    private func persistSession() {
        let ud = UserDefaults.standard
        ud.set(true, forKey: kSessionActive)
        if let date = sessionStartDate {
            ud.set(date, forKey: kSessionStartDate)
        }
        if let wid = expandedWorkoutID {
            ud.set(wid.uuidString, forKey: kSessionWorkoutID)
        }
    }

    private func clearPersistedSession() {
        let ud = UserDefaults.standard
        ud.removeObject(forKey: kSessionActive)
        ud.removeObject(forKey: kSessionStartDate)
        ud.removeObject(forKey: kSessionWorkoutID)
    }

    private func persistRestTimer() {
        let ud = UserDefaults.standard
        if let endDate = restTimerEndDate {
            ud.set(endDate, forKey: kRestTimerEndDate)
            ud.set(restTimerTotal, forKey: kRestTimerTotal)
        }
    }

    private func clearPersistedRestTimer() {
        let ud = UserDefaults.standard
        ud.removeObject(forKey: kRestTimerEndDate)
        ud.removeObject(forKey: kRestTimerTotal)
    }

    func restoreSessionIfNeeded() {
        let ud = UserDefaults.standard
        guard ud.bool(forKey: kSessionActive),
              let startDate = ud.object(forKey: kSessionStartDate) as? Date else { return }

        // Restore session
        sessionStartDate = startDate
        isSessionActive = true
        isLogging = true
        sessionElapsed = Date().timeIntervalSince(startDate)
        startSessionTimer()

        // Restore workout ID
        if let widStr = ud.string(forKey: kSessionWorkoutID),
           let wid = UUID(uuidString: widStr) {
            expandedWorkoutID = wid
            selectedTab = 1
        }

        // Restore rest timer if still running
        if let endDate = ud.object(forKey: kRestTimerEndDate) as? Date {
            let remaining = Int(endDate.timeIntervalSinceNow)
            if remaining > 0 {
                restTimerTotal = ud.integer(forKey: kRestTimerTotal)
                restTimerRemaining = remaining
                isRestTimerRunning = true
                restTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                    DispatchQueue.main.async {
                        guard let self else { return }
                        if self.restTimerRemaining > 0 {
                            self.restTimerRemaining -= 1
                            if self.restTimerRemaining == 0 {
                                self.onRestTimerFinished()
                            }
                        } else {
                            self.stopRestTimer()
                        }
                    }
                }
            } else {
                clearPersistedRestTimer()
            }
        }
    }

    // MARK: - App lifecycle
    func handleScenePhase(_ phase: ScenePhase) {
        switch phase {
        case .active:
            // Recalculate elapsed from persisted start date
            if let start = sessionStartDate, isSessionActive {
                sessionElapsed = Date().timeIntervalSince(start)
                if sessionTimer == nil {
                    startSessionTimer()
                }
            }
            // Recalculate rest timer
            if let endDate = restTimerEndDate {
                let remaining = Int(endDate.timeIntervalSinceNow)
                if remaining > 0 {
                    restTimerRemaining = remaining
                } else if isRestTimerRunning {
                    onRestTimerFinished()
                }
            }
        case .background:
            // Timers will be killed by OS, but we have dates persisted
            sessionTimer?.invalidate()
            sessionTimer = nil
            restTimer?.invalidate()
            restTimer = nil
        default:
            break
        }
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
