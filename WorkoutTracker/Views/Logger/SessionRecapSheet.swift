import SwiftUI

struct SessionRecapSheet: View {
    @Environment(ThemeManager.self) private var theme
    @Environment(WorkoutViewModel.self) private var viewModel

    private let feelings = [
        ("Excellent", "face.smiling.inverse", Color.green),
        ("Bien", "hand.thumbsup.fill", Color.blue),
        ("Moyen", "face.dashed", Color.orange),
        ("Difficile", "bolt.slash.fill", DesignTokens.destructive),
    ]

    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(theme.accentColor)

                Text("Seance terminee")
                    .font(.title2)
                    .fontWeight(.heavy)
                    .foregroundStyle(.primary)
            }

            // Stats
            HStack(spacing: 24) {
                VStack(spacing: 4) {
                    Text(viewModel.formatDuration(viewModel.lastSessionDuration))
                        .font(.title3)
                        .fontWeight(.heavy)
                        .foregroundStyle(theme.accentColor)
                    Text("Duree")
                        .font(.caption)
                        .foregroundStyle(DesignTokens.textSecondary)
                }

                Rectangle()
                    .fill(DesignTokens.border)
                    .frame(width: 1, height: 32)

                VStack(spacing: 4) {
                    Text("\(viewModel.lastSessionExerciseCount)")
                        .font(.title3)
                        .fontWeight(.heavy)
                        .foregroundStyle(theme.accentColor)
                    Text("Exercices")
                        .font(.caption)
                        .foregroundStyle(DesignTokens.textSecondary)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(DesignTokens.card2)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // Feeling question
            VStack(alignment: .leading, spacing: 12) {
                Text("Comment tu te sens ?")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)

                HStack(spacing: 8) {
                    ForEach(feelings, id: \.0) { feeling in
                        Button {
                            viewModel.sessionFeeling = feeling.0
                        } label: {
                            VStack(spacing: 6) {
                                Image(systemName: feeling.1)
                                    .font(.title3)
                                Text(feeling.0)
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(viewModel.sessionFeeling == feeling.0 ? feeling.2.opacity(0.2) : DesignTokens.card2)
                            .foregroundStyle(viewModel.sessionFeeling == feeling.0 ? feeling.2 : DesignTokens.textSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(viewModel.sessionFeeling == feeling.0 ? feeling.2 : Color.clear, lineWidth: 2)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            Button {
                withAnimation { viewModel.dismissRecap() }
            } label: {
                Text("Fermer")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(theme.accentColor)
                    .foregroundStyle(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .padding(24)
        .background(DesignTokens.card1)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .padding(.horizontal, 16)
    }
}
