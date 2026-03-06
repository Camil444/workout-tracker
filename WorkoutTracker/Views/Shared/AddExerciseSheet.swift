import SwiftUI
import SwiftData

struct AddExerciseSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) private var theme

    let workout: Workout

    @State private var name = ""
    @State private var unit: ExerciseUnit = .kg

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                TextField("Nom de l'exercice", text: $name)
                    .textFieldStyle(.plain)
                    .padding()
                    .background(DesignTokens.card2)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .foregroundStyle(.white)

                HStack(spacing: 12) {
                    ForEach(ExerciseUnit.allCases, id: \.self) { u in
                        Button {
                            unit = u
                        } label: {
                            Text(u.rawValue)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(unit == u ? theme.accentColor : DesignTokens.card2)
                                .foregroundStyle(unit == u ? .black : .white)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }

                Button {
                    addExercise()
                } label: {
                    Text("Ajouter")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(canAdd ? theme.accentColor : DesignTokens.card2)
                        .foregroundStyle(canAdd ? .black : DesignTokens.textSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .disabled(!canAdd)

                Spacer()
            }
            .padding()
            .background(DesignTokens.bgPrimary)
            .navigationTitle("Nouvel exercice")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                        .foregroundStyle(DesignTokens.textSecondary)
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .presentationDetents([.medium])
    }

    private var canAdd: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func addExercise() {
        let exercise = Exercise(
            name: name.trimmingCharacters(in: .whitespaces),
            unit: unit,
            sortOrder: workout.exercises.count
        )
        exercise.workout = workout
        modelContext.insert(exercise)
        dismiss()
    }
}
