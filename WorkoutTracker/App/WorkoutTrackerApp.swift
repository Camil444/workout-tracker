import SwiftUI
import SwiftData

@main
struct WorkoutTrackerApp: App {
    @State private var themeManager = ThemeManager()
    @State private var workoutViewModel = WorkoutViewModel()
    @State private var locationManager = LocationManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(themeManager)
                .environment(workoutViewModel)
                .environment(locationManager)
                .preferredColorScheme(.dark)
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
    @Query private var profiles: [UserProfile]
    @Query private var gymLocations: [GymLocation]

    private var profile: UserProfile? { profiles.first }

    var body: some View {
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
        .onAppear {
            if let profile {
                theme.accentHex = profile.accentColor
            }
            LocationManager.requestNotificationPermission()
            if !gymLocations.isEmpty {
                locationManager.startMonitoring(locations: gymLocations)
            }
        }
    }

    private func createProfile() {
        let profile = UserProfile()
        modelContext.insert(profile)
    }
}
