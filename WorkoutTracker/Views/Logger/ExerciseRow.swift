import SwiftUI

struct ExerciseRow: View {
    @Environment(ThemeManager.self) private var theme
    @Environment(WorkoutViewModel.self) private var viewModel

    let exercise: Exercise
    let isLogging: Bool

    private var isExpanded: Bool {
        viewModel.expandedExerciseID == exercise.id
    }

    var body: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    viewModel.toggleExercise(exercise)
                }
            } label: {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(exercise.name)
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)
                            if exercise.unit == .pdc {
                                Text("PDC")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(theme.accentColor.opacity(0.2))
                                    .foregroundStyle(theme.accentColor)
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                            }
                        }
                        HStack(spacing: 8) {
                            let logCount = exercise.logs.count
                            let maxStr: String = {
                                if exercise.unit == .pdc {
                                    return "\(Int(exercise.currentMax)) reps"
                                } else {
                                    return exercise.currentMax > 0 ? "\(Int(exercise.currentMax))kg" : "-"
                                }
                            }()
                            Text("\(logCount) séries · \(maxStr)")
                                .font(.caption)
                                .foregroundStyle(DesignTokens.textSecondary)
                        }
                    }

                    Spacer()

                    if exercise.maxValues.count >= 2 {
                        SparklineView(values: exercise.maxValues, accentColor: theme.accentColor)
                            .frame(width: 50, height: 20)
                    }

                    if let prog = exercise.progression {
                        Text(String(format: "%+.0f%%", prog))
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(prog >= 0 ? theme.accentColor : DesignTokens.destructive)
                    }

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(DesignTokens.textSecondary)
                }
                .padding()
                .background(DesignTokens.card2)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)

            if isExpanded {
                ExerciseDetail(
                    exercise: exercise,
                    isLogging: isLogging,
                    onLogSaved: {
                        withAnimation {
                            viewModel.cancelLogging()
                        }
                    }
                )
                .padding(.horizontal, 8)
                .padding(.vertical, 12)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}
