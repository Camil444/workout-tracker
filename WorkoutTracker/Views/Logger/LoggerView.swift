import SwiftUI
import SwiftData

struct LoggerView: View {
    @Environment(WorkoutViewModel.self) private var viewModel
    @Query(sort: \Workout.sortOrder) private var workouts: [Workout]

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Logger")
                            .font(.system(size: 30, weight: .heavy))
                            .foregroundStyle(.primary)
                        Text("Selectionne une seance")
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
            .scrollDismissesKeyboard(.interactively)
            .dismissKeyboardOnTap()
            .background(DesignTokens.bgPrimary)

            // Session recap overlay
            if viewModel.showSessionRecap {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .onTapGesture { viewModel.dismissRecap() }

                SessionRecapSheet()
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.showSessionRecap)
    }
}
