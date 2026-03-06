import SwiftUI
import SwiftData

struct WorkoutAccordion: View {
    @Environment(ThemeManager.self) private var theme
    @Environment(WorkoutViewModel.self) private var viewModel
    @Query private var profiles: [UserProfile]

    let workout: Workout

    @State private var showAddExercise = false

    private var isExpanded: Bool {
        viewModel.expandedWorkoutID == workout.id
    }

    private var sortedExercises: [Exercise] {
        workout.exercises.sorted { $0.sortOrder < $1.sortOrder }
    }

    private var currentWeek: Int {
        let maxWeek = workout.exercises.flatMap(\.logs).map(\.weekNumber).max() ?? 0
        return maxWeek > 0 ? maxWeek : 1
    }

    private var restTimerSeconds: Int {
        profiles.first?.restTimerSeconds ?? 90
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            Button {
                withAnimation(.snappy(duration: 0.3)) {
                    viewModel.toggleWorkout(workout)
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: workout.iconName)
                        .font(.title3)
                        .foregroundStyle(isExpanded ? .black : .white)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(workout.name)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(isExpanded ? .black : .white)
                        Text("\(workout.exercises.count) exos · Semaine \(currentWeek)")
                            .font(.caption)
                            .foregroundStyle(isExpanded ? .black.opacity(0.6) : DesignTokens.textSecondary)
                    }

                    Spacer()

                    // Session timer
                    if isExpanded && viewModel.sessionStartDate != nil {
                        Text(viewModel.sessionTimerFormatted)
                            .font(.system(.caption, design: .monospaced))
                            .fontWeight(.bold)
                            .foregroundStyle(isExpanded ? .black.opacity(0.7) : theme.accentColor)
                    }

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(isExpanded ? .black.opacity(0.6) : DesignTokens.textSecondary)
                }
                .padding()
                .background(isExpanded ? theme.accentColor : DesignTokens.card1)
            }
            .buttonStyle(.plain)

            // Content
            if isExpanded {
                VStack(spacing: 8) {
                    HStack {
                        Spacer()
                        if viewModel.isLogging {
                            Button {
                                withAnimation(.snappy(duration: 0.25)) { viewModel.cancelLogging() }
                            } label: {
                                Text("Annuler")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(DesignTokens.destructive)
                            }
                        } else {
                            Button {
                                withAnimation(.snappy(duration: 0.25)) { viewModel.startLogging() }
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "pencil.line")
                                    Text("Logger")
                                }
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(theme.accentColor)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)

                    // Rest timer (visible when logging)
                    if viewModel.isLogging {
                        RestTimerView(defaultSeconds: restTimerSeconds)
                            .padding(.horizontal)
                    }

                    ForEach(sortedExercises) { exercise in
                        ExerciseRow(exercise: exercise, isLogging: viewModel.isLogging)
                    }

                    Button {
                        showAddExercise = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                            Text("Ajouter un exercice")
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(DesignTokens.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [6]))
                                .foregroundStyle(DesignTokens.border)
                        )
                    }
                }
                .padding(12)
                .background(DesignTokens.card1)
                .sheet(isPresented: $showAddExercise) {
                    AddExerciseSheet(workout: workout)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .animation(.snappy(duration: 0.3), value: isExpanded)
    }
}
