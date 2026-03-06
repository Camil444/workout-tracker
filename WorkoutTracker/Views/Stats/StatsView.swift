import SwiftUI
import SwiftData

struct StatsView: View {
    @Environment(ThemeManager.self) private var theme
    @Query(sort: \Workout.sortOrder) private var workouts: [Workout]

    @State private var selectedWorkoutID: UUID?

    private var selectedWorkout: Workout? {
        if let id = selectedWorkoutID {
            return workouts.first { $0.id == id }
        }
        return workouts.first
    }

    private var exercises: [Exercise] {
        (selectedWorkout?.exercises ?? []).sorted { $0.sortOrder < $1.sortOrder }
    }

    private var totalWeeks: Int {
        exercises.flatMap(\.logs).map(\.weekNumber).max() ?? 0
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Stats")
                        .font(.system(size: 30, weight: .heavy))
                        .foregroundStyle(.white)
                    Text("Progression sur \(totalWeeks) semaines")
                        .font(.subheadline)
                        .foregroundStyle(DesignTokens.textSecondary)
                }
                .padding(.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(workouts) { workout in
                            let isSelected = (selectedWorkoutID ?? workouts.first?.id) == workout.id
                            Button {
                                selectedWorkoutID = workout.id
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: workout.iconName)
                                        .font(.caption)
                                    Text(workout.name)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(isSelected ? theme.accentColor : DesignTokens.card1)
                                .foregroundStyle(isSelected ? .black : .white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                SummaryCards(exercises: exercises)
                    .padding(.horizontal)

                VStack(spacing: 12) {
                    ForEach(exercises) { exercise in
                        ExerciseChart(exercise: exercise)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top)
        }
        .background(DesignTokens.bgPrimary)
    }
}
