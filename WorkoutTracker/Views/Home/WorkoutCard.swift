import SwiftUI

struct WorkoutCard: View {
    @Environment(ThemeManager.self) private var theme
    let workout: Workout
    let bestExercise: (name: String, value: Double, unit: ExerciseUnit)?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Image(systemName: workout.iconName)
                    .font(.title2)
                    .foregroundStyle(.primary)
                    .frame(width: 44, height: 44)
                    .background(DesignTokens.card2)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                Spacer()

                if let best = bestExercise {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("MAX")
                            .font(.caption2)
                            .foregroundStyle(DesignTokens.textSecondary)
                        Text(best.unit == .pdc ? "\(Int(best.value)) reps" : "\(Int(best.value))kg")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(theme.accentColor)
                        Text(best.name)
                            .font(.caption2)
                            .foregroundStyle(DesignTokens.textSecondary)
                            .lineLimit(1)
                    }
                }
            }

            Spacer()

            VStack(alignment: .leading, spacing: 4) {
                Text(workout.name)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                Text("\(workout.exercises.count) exos")
                    .font(.caption)
                    .foregroundStyle(DesignTokens.textSecondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 150, alignment: .topLeading)
        .background(DesignTokens.card1)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

struct NewWorkoutCard: View {
    @Environment(ThemeManager.self) private var theme

    var body: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "plus")
                .font(.title)
                .foregroundStyle(theme.accentColor)
            Text("Nouvelle")
                .font(.subheadline)
                .foregroundStyle(DesignTokens.textSecondary)
            Spacer()
        }
        .frame(maxWidth: .infinity, minHeight: 150)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [8]))
                .foregroundStyle(DesignTokens.border)
        )
    }
}
