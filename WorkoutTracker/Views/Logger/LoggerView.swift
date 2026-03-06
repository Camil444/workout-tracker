import SwiftUI
import SwiftData

struct LoggerView: View {
    @Query(sort: \Workout.sortOrder) private var workouts: [Workout]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Logger")
                        .font(.system(size: 30, weight: .heavy))
                        .foregroundStyle(.white)
                    Text("Sélectionne une séance")
                        .font(.subheadline)
                        .foregroundStyle(DesignTokens.textSecondary)
                }
                .padding(.horizontal)

                VStack(spacing: 8) {
                    ForEach(workouts) { workout in
                        WorkoutAccordion(workout: workout)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top)
        }
        .background(DesignTokens.bgPrimary)
    }
}
