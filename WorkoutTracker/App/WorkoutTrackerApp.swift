import SwiftUI
import SwiftData

@main
struct WorkoutTrackerApp: App {
    @State private var themeManager = ThemeManager()
    @State private var workoutViewModel = WorkoutViewModel()
    @State private var locationManager = LocationManager()
    @State private var healthKitManager = HealthKitManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(themeManager)
                .environment(workoutViewModel)
                .environment(locationManager)
                .environment(healthKitManager)
        }
        .modelContainer(for: [
            UserProfile.self, Workout.self, Exercise.self, ExerciseLog.self,
            RunningSessionType.self, RunningLog.self,
            SportActivity.self, SportActivityLog.self,
            GymLocation.self
        ])
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) private var theme
    @Environment(LocationManager.self) private var locationManager
    @Environment(WorkoutViewModel.self) private var viewModel
    @Environment(HealthKitManager.self) private var healthKit
    @Query private var profiles: [UserProfile]
    @Query private var gymLocations: [GymLocation]

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        ZStack {
            Group {
                if let profile {
                    if profile.hasCompletedOnboarding {
                        MainTabView()
                    } else {
                        OnboardingView(profile: profile)
                    }
                } else {
                    Color.black
                        .onAppear { createProfile() }
                }
            }
            .preferredColorScheme(theme.colorScheme)

            // PR Celebration overlay
            PRCelebrationOverlay(
                exerciseName: viewModel.prExerciseName,
                value: viewModel.prValue,
                isShowing: viewModel.showPRCelebration,
                onDismiss: { viewModel.showPRCelebration = false }
            )
        }
        .onAppear {
            if let profile {
                theme.accentHex = profile.accentColor
                theme.isDarkMode = profile.isDarkMode
            }
            LocationManager.requestNotificationPermission()
            if !gymLocations.isEmpty {
                locationManager.startMonitoring(locations: gymLocations)
            }
            healthKit.requestAuthorization()
        }
    }

    private func createProfile() {
        let profile = UserProfile()
        modelContext.insert(profile)
    }
}
