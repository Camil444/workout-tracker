import SwiftUI
import SwiftData

struct FirstWorkoutStep: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) private var theme

    @State private var name = ""
    @State private var selectedIcon = "bolt.fill"
    @State private var exercises: [(name: String, unit: ExerciseUnit, id: UUID)] = []
    @State private var newExerciseName = ""
    @State private var newExerciseUnit: ExerciseUnit = .kg
    @State private var showingAddExercise = false

    let onComplete: (Workout) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Crée ta première séance")
                    .font(.system(size: 28, weight: .heavy))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .center)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Nom de la séance")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(DesignTokens.textSecondary)
                    TextField("Ex: Push, Pull, Legs...", text: $name)
                        .textFieldStyle(.plain)
                        .padding()
                        .background(DesignTokens.card2)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Icône")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(DesignTokens.textSecondary)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(CreateWorkoutSheet.availableIcons, id: \.self) { icon in
                                Button {
                                    selectedIcon = icon
                                } label: {
                                    Image(systemName: icon)
                                        .font(.title2)
                                        .frame(width: 50, height: 50)
                                        .background(selectedIcon == icon ? theme.accentColor : DesignTokens.card2)
                                        .foregroundStyle(selectedIcon == icon ? .black : .white)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Exercices")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(DesignTokens.textSecondary)

                    ForEach(exercises, id: \.id) { exercise in
                        HStack {
                            Text(exercise.name)
                                .fontWeight(.semibold)
                            Spacer()
                            Text(exercise.unit.rawValue)
                                .font(.caption)
                                .fontWeight(.bold)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(exercise.unit == .pdc ? theme.accentColor.opacity(0.2) : DesignTokens.card2)
                                .foregroundStyle(exercise.unit == .pdc ? theme.accentColor : DesignTokens.textSecondary)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                            Button {
                                exercises.removeAll { $0.id == exercise.id }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(DesignTokens.destructive)
                            }
                        }
                        .padding()
                        .background(DesignTokens.card1)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    if showingAddExercise {
                        VStack(spacing: 12) {
                            TextField("Nom de l'exercice", text: $newExerciseName)
                                .textFieldStyle(.plain)
                                .padding()
                                .background(DesignTokens.card2)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .foregroundStyle(.white)

                            HStack {
                                ForEach(ExerciseUnit.allCases, id: \.self) { unit in
                                    Button {
                                        newExerciseUnit = unit
                                    } label: {
                                        Text(unit.rawValue)
                                            .fontWeight(.semibold)
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 10)
                                            .background(newExerciseUnit == unit ? theme.accentColor : DesignTokens.card2)
                                            .foregroundStyle(newExerciseUnit == unit ? .black : .white)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                }
                                Spacer()
                                Button("Ajouter") {
                                    guard !newExerciseName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                                    exercises.append((name: newExerciseName.trimmingCharacters(in: .whitespaces), unit: newExerciseUnit, id: UUID()))
                                    newExerciseName = ""
                                    newExerciseUnit = .kg
                                    showingAddExercise = false
                                }
                                .fontWeight(.semibold)
                                .foregroundStyle(theme.accentColor)
                            }
                        }
                    }

                    Button {
                        showingAddExercise = true
                    } label: {
                        HStack {
                            Image(systemName: "plus")
                            Text("Ajouter un exercice")
                        }
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

                Button {
                    let workout = createWorkout()
                    onComplete(workout)
                } label: {
                    Text("Terminer")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(canCreate ? theme.accentColor : DesignTokens.card2)
                        .foregroundStyle(canCreate ? .black : DesignTokens.textSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .disabled(!canCreate)
            }
            .padding(24)
        }
        .scrollDismissesKeyboard(.interactively)
        .dismissKeyboardOnTap()
        .background(DesignTokens.bgPrimary)
    }

    private var canCreate: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && !exercises.isEmpty
    }

    private func createWorkout() -> Workout {
        let workout = Workout(name: name.trimmingCharacters(in: .whitespaces), iconName: selectedIcon, sortOrder: 0)
        modelContext.insert(workout)

        for (index, ex) in exercises.enumerated() {
            let exercise = Exercise(name: ex.name, unit: ex.unit, sortOrder: index)
            exercise.workout = workout
            modelContext.insert(exercise)
        }
        return workout
    }
}
