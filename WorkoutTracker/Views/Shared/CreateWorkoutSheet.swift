import SwiftUI
import SwiftData

struct CreateWorkoutSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) private var theme

    @Query private var workouts: [Workout]

    @State private var name = ""
    @State private var selectedIcon = "bolt.fill"
    @State private var exercises: [(name: String, unit: ExerciseUnit, id: UUID)] = []
    @State private var newExerciseName = ""
    @State private var newExerciseUnit: ExerciseUnit = .kg
    @State private var showingAddExercise = false

    var onCreated: (() -> Void)?

    static let availableIcons = [
        "bolt.fill", "flame.fill", "target", "dumbbell.fill",
        "heart.fill", "waveform.path.ecg", "figure.run",
        "figure.strengthtraining.traditional", "figure.boxing",
        "figure.cooldown", "figure.core.training", "figure.yoga",
        "trophy.fill", "star.fill"
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
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
                                ForEach(Self.availableIcons, id: \.self) { icon in
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

                        if !recommendedExercises.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Suggestions")
                                    .font(.caption)
                                    .foregroundStyle(DesignTokens.textSecondary)
                                FlowLayout(spacing: 6) {
                                    ForEach(recommendedExercises) { rec in
                                        Button {
                                            if !exercises.contains(where: { $0.name.lowercased() == rec.name.lowercased() }) {
                                                exercises.append((name: rec.name, unit: rec.unit, id: UUID()))
                                            }
                                        } label: {
                                            HStack(spacing: 4) {
                                                Image(systemName: "plus.circle.fill")
                                                    .font(.caption2)
                                                Text(rec.name)
                                                    .font(.caption)
                                            }
                                            .fontWeight(.medium)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 7)
                                            .background(DesignTokens.card2)
                                            .foregroundStyle(.white)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                        }
                                    }
                                }
                            }
                        }

                        ForEach(exercises, id: \.id) { exercise in
                            HStack {
                                Text(exercise.name)
                                    .fontWeight(.semibold)
                                Spacer()
                                if exercise.unit == .pdc {
                                    Text("PDC")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(theme.accentColor.opacity(0.2))
                                        .foregroundStyle(theme.accentColor)
                                        .clipShape(RoundedRectangle(cornerRadius: 6))
                                } else {
                                    Text("KG")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(DesignTokens.card2)
                                        .foregroundStyle(DesignTokens.textSecondary)
                                        .clipShape(RoundedRectangle(cornerRadius: 6))
                                }
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
                        createWorkout()
                    } label: {
                        Text("Créer la séance")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(canCreate ? theme.accentColor : DesignTokens.card2)
                            .foregroundStyle(canCreate ? .black : DesignTokens.textSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .disabled(!canCreate)
                }
                .padding()
            }
            .scrollDismissesKeyboard(.interactively)
            .dismissKeyboardOnTap()
            .background(DesignTokens.bgPrimary)
            .navigationTitle("Nouvelle séance")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                        .foregroundStyle(DesignTokens.textSecondary)
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .presentationDetents([.large])
        .presentationBackground(DesignTokens.bgPrimary)
    }

    private var recommendedExercises: [ExerciseRecommendation] {
        let existing = Set(exercises.map { $0.name.lowercased() })
        return ExerciseRecommendations.suggestions(for: name)
            .filter { !existing.contains($0.name.lowercased()) }
    }

    private var canCreate: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && !exercises.isEmpty
    }

    private func createWorkout() {
        let workout = Workout(
            name: name.trimmingCharacters(in: .whitespaces),
            iconName: selectedIcon,
            sortOrder: workouts.count
        )
        modelContext.insert(workout)

        for (index, ex) in exercises.enumerated() {
            let exercise = Exercise(name: ex.name, unit: ex.unit, sortOrder: index)
            exercise.workout = workout
            modelContext.insert(exercise)
        }

        onCreated?()
        dismiss()
    }
}
