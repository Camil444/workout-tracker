import SwiftUI
import SwiftData

enum StatsTab: String, CaseIterable {
    case progression = "Progression"
    case calendrier = "Calendrier"
}

struct StatsView: View {
    @Environment(ThemeManager.self) private var theme
    @Query(sort: \Workout.sortOrder) private var workouts: [Workout]

    @State private var selectedWorkoutID: UUID?
    @State private var selectedTab: StatsTab = .progression

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
                    Text(selectedTab == .progression
                         ? "Progression sur \(totalWeeks) semaines"
                         : "Ton activité sportive")
                        .font(.subheadline)
                        .foregroundStyle(DesignTokens.textSecondary)
                }
                .padding(.horizontal)

                // Tab picker
                HStack(spacing: 4) {
                    ForEach(StatsTab.allCases, id: \.self) { tab in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedTab = tab
                            }
                        } label: {
                            Text(tab.rawValue)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(selectedTab == tab ? theme.accentColor : Color.clear)
                                .foregroundStyle(selectedTab == tab ? .black : DesignTokens.textSecondary)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }
                .padding(4)
                .background(DesignTokens.card1)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)

                switch selectedTab {
                case .progression:
                    progressionContent
                case .calendrier:
                    ActivityCalendarView()
                }
            }
            .padding(.top)
        }
        .background(DesignTokens.bgPrimary)
    }

    @ViewBuilder
    private var progressionContent: some View {
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
}
