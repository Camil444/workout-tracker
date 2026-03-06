import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(ThemeManager.self) private var theme
    @Environment(WorkoutViewModel.self) private var viewModel
    @Query(sort: \Workout.sortOrder) private var workouts: [Workout]
    @Query private var profiles: [UserProfile]

    @State private var showCreateSheet = false

    private var profile: UserProfile? { profiles.first }

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Bonne séance")
                        .font(.subheadline)
                        .foregroundStyle(DesignTokens.textSecondary)
                    Text("Bonjour, \(profile?.firstName ?? "")")
                        .font(.system(size: 30, weight: .heavy))
                        .foregroundStyle(.white)
                }
                .padding(.horizontal)

                Text("Quelle séance aujourd'hui ?")
                    .font(.subheadline)
                    .foregroundStyle(DesignTokens.textSecondary)
                    .padding(.horizontal)

                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(workouts) { workout in
                        Button {
                            viewModel.navigateToWorkout(workout)
                        } label: {
                            WorkoutCard(
                                workout: workout,
                                bestExercise: viewModel.bestExercise(in: workout)
                            )
                        }
                        .buttonStyle(.plain)
                    }

                    Button {
                        showCreateSheet = true
                    } label: {
                        NewWorkoutCard()
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
            }
            .padding(.top)
        }
        .background(DesignTokens.bgPrimary)
        .sheet(isPresented: $showCreateSheet) {
            CreateWorkoutSheet()
        }
    }
}
