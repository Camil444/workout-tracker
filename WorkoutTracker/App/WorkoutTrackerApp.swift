import SwiftUI
import SwiftData

@main
struct WorkoutTrackerApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var themeManager = ThemeManager()
    @State private var workoutViewModel = WorkoutViewModel()
    @State private var healthKitManager = HealthKitManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(themeManager)
                .environment(workoutViewModel)
                .environment(healthKitManager)
                .onChange(of: scenePhase) { _, phase in
                    workoutViewModel.handleScenePhase(phase)
                }
                .onOpenURL { url in
                    workoutViewModel.handleDeepLink(url)
                }
        }
        .modelContainer(for: [
            UserProfile.self, Workout.self, Exercise.self, ExerciseLog.self,
            RunningSessionType.self, RunningLog.self,
            SportActivity.self, SportActivityLog.self
        ])
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) private var theme
    @Environment(WorkoutViewModel.self) private var viewModel
    @Environment(HealthKitManager.self) private var healthKit
    @Query private var profiles: [UserProfile]

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
            healthKit.requestAuthorization()
        }
    }

    private func createProfile() {
        let profile = UserProfile()
        modelContext.insert(profile)
    }
}
