import SwiftUI
import SwiftData

struct ProgramChoiceStep: View {
    @Environment(ThemeManager.self) private var theme

    let onComplete: () -> Void

    @State private var selectedTemplate: ProgramTemplate?
    @State private var showCustomize = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Choisis ton programme")
                        .font(.system(size: 28, weight: .heavy))
                        .foregroundStyle(.primary)
                    Text("Selectionne un split ou cree tes seances")
                        .font(.subheadline)
                        .foregroundStyle(DesignTokens.textSecondary)
                }
                .padding(.horizontal)

                ForEach(ProgramTemplates.allMuscu, id: \.name) { template in
                    Button {
                        selectedTemplate = template
                        showCustomize = true
                    } label: {
                        templateCard(template)
                    }
                    .buttonStyle(.plain)
                }

                Button {
                    selectedTemplate = nil
                    showCustomize = true
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "pencil.and.list.clipboard")
                            .font(.title2)
                            .foregroundStyle(theme.accentColor)
                            .frame(width: 44)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Seances personnalisees")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)
                            Text("Cree tes propres seances de zero")
                                .font(.caption)
                                .foregroundStyle(DesignTokens.textSecondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(DesignTokens.textSecondary)
                    }
                    .padding()
                    .background(DesignTokens.card1)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [6]))
                            .foregroundStyle(DesignTokens.border)
                    )
                    .padding(.horizontal)
                }
                .buttonStyle(.plain)

                Button {
                    onComplete()
                } label: {
                    Text("Passer cette etape")
                        .font(.subheadline)
                        .foregroundStyle(DesignTokens.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .padding(.top)
            .padding(.bottom, 32)
        }
        .background(DesignTokens.bgPrimary)
        .sheet(isPresented: $showCustomize) {
            CustomizeWorkoutsSheet(template: selectedTemplate, onComplete: onComplete)
        }
    }

    @ViewBuilder
    private func templateCard(_ template: ProgramTemplate) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(template.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                    Text(template.description)
                        .font(.caption)
                        .foregroundStyle(DesignTokens.textSecondary)
                }
                Spacer()
                Text("\(template.daysPerWeek)j/sem")
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(theme.accentColor)
                    .foregroundStyle(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            HStack(spacing: 6) {
                ForEach(template.days.prefix(6), id: \.name) { day in
                    VStack(spacing: 2) {
                        Image(systemName: day.iconName)
                            .font(.caption2)
                            .foregroundStyle(theme.accentColor)
                        Text(day.name)
                            .font(.system(size: 8))
                            .foregroundStyle(DesignTokens.textSecondary)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(DesignTokens.card2)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
        }
        .padding()
        .background(DesignTokens.card1)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
}

// MARK: - Customize Workouts Sheet

struct CustomizeWorkoutsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) private var theme

    let template: ProgramTemplate?
    let onComplete: () -> Void

    @State private var workouts: [EditableWorkout] = []

    init(template: ProgramTemplate?, onComplete: @escaping () -> Void) {
        self.template = template
        self.onComplete = onComplete
        if let template {
            _workouts = State(initialValue: template.days.map { day in
                EditableWorkout(
                    name: day.name,
                    iconName: day.iconName,
                    exercises: day.exercises.map { EditableExerciseItem(name: $0.name, unit: $0.unit) }
                )
            })
        } else {
            _workouts = State(initialValue: [
                EditableWorkout(name: "", iconName: "bolt.fill", exercises: [])
            ])
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(template != nil
                         ? "Tes seances sont pretes. Modifie-les si besoin."
                         : "Cree tes seances et ajoute des exercices.")
                        .font(.subheadline)
                        .foregroundStyle(DesignTokens.textSecondary)
                        .padding(.horizontal)

                    ForEach(Array(workouts.enumerated()), id: \.element.id) { index, _ in
                        WorkoutEditorCard(
                            workout: $workouts[index],
                            onDelete: {
                                workouts.remove(at: index)
                            }
                        )
                    }

                    // Add workout
                    Button {
                        workouts.append(EditableWorkout(name: "", iconName: "bolt.fill", exercises: []))
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "plus")
                            Text("Ajouter une seance")
                        }
                        .fontWeight(.semibold)
                        .foregroundStyle(theme.accentColor)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [6]))
                                .foregroundStyle(DesignTokens.border)
                        )
                        .padding(.horizontal)
                    }

                    Button {
                        saveAndFinish()
                    } label: {
                        Text("Valider et commencer")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(canSave ? theme.accentColor : DesignTokens.card2)
                            .foregroundStyle(canSave ? .black : DesignTokens.textSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .padding(.horizontal)
                    }
                    .disabled(!canSave)
                }
                .padding(.top)
                .padding(.bottom, 32)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(DesignTokens.bgPrimary)
            .navigationTitle(template?.name ?? "Mes seances")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Retour") { dismiss() }
                        .foregroundStyle(DesignTokens.textSecondary)
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private var canSave: Bool {
        workouts.contains { !$0.name.trimmingCharacters(in: .whitespaces).isEmpty && !$0.exercises.isEmpty }
    }

    private func saveAndFinish() {
        let validWorkouts = workouts.filter {
            !$0.name.trimmingCharacters(in: .whitespaces).isEmpty
        }
        for (index, w) in validWorkouts.enumerated() {
            let workout = Workout(
                name: w.name.trimmingCharacters(in: .whitespaces),
                iconName: w.iconName,
                sortOrder: index
            )
            modelContext.insert(workout)

            let validExercises = w.exercises.filter {
                !$0.name.trimmingCharacters(in: .whitespaces).isEmpty
            }
            for (exIndex, ex) in validExercises.enumerated() {
                let exercise = Exercise(
                    name: ex.name.trimmingCharacters(in: .whitespaces),
                    unit: ex.unit,
                    sortOrder: exIndex
                )
                exercise.workout = workout
                modelContext.insert(exercise)
            }
        }
        dismiss()
        onComplete()
    }
}

// MARK: - Workout Editor Card

struct WorkoutEditorCard: View {
    @Environment(ThemeManager.self) private var theme
    @Binding var workout: EditableWorkout
    let onDelete: () -> Void

    @State private var newExerciseName = ""
    @State private var newExerciseUnit: ExerciseUnit = .kg

    private var suggestions: [ExerciseRecommendation] {
        let existing = Set(workout.exercises.map { $0.name.lowercased() })
        return ExerciseRecommendations.suggestions(for: workout.name)
            .filter { !existing.contains($0.name.lowercased()) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header: name + delete
            HStack {
                Image(systemName: workout.iconName)
                    .foregroundStyle(theme.accentColor)
                    .frame(width: 28)
                TextField("Nom de la seance", text: $workout.name)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                Spacer()
                Button { onDelete() } label: {
                    Image(systemName: "trash.fill")
                        .font(.caption)
                        .foregroundStyle(DesignTokens.destructive)
                }
            }

            Divider().background(DesignTokens.border)

            // Exercises list
            if workout.exercises.isEmpty {
                Text("Aucun exercice")
                    .font(.caption)
                    .foregroundStyle(DesignTokens.textSecondary)
                    .padding(.vertical, 4)
            } else {
                ForEach(workout.exercises) { exercise in
                    HStack(spacing: 8) {
                        Text(exercise.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)
                        Spacer()
                        Text(exercise.unit.rawValue)
                            .font(.caption2)
                            .fontWeight(.bold)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(exercise.unit == .pdc ? theme.accentColor.opacity(0.2) : DesignTokens.card2)
                            .foregroundStyle(exercise.unit == .pdc ? theme.accentColor : DesignTokens.textSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                        Button {
                            workout.exercises.removeAll { $0.id == exercise.id }
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .font(.caption)
                                .foregroundStyle(DesignTokens.destructive)
                        }
                    }
                    .padding(.vertical, 2)
                }
            }

            // Suggestions (based on workout name)
            if !suggestions.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Suggestions")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(DesignTokens.textSecondary)
                    FlowLayout(spacing: 6) {
                        ForEach(suggestions) { rec in
                            Button {
                                workout.exercises.append(EditableExerciseItem(name: rec.name, unit: rec.unit))
                            } label: {
                                HStack(spacing: 3) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 8, weight: .bold))
                                    Text(rec.name)
                                        .font(.caption)
                                }
                                .fontWeight(.medium)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 6)
                                .background(DesignTokens.card2)
                                .foregroundStyle(.primary)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                }
            }

            // Always-visible exercise input
            VStack(spacing: 8) {
                TextField("Nom de l'exercice", text: $newExerciseName)
                    .textFieldStyle(.plain)
                    .font(.subheadline)
                    .padding(10)
                    .background(DesignTokens.card2)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .foregroundStyle(.primary)
                    .submitLabel(.done)
                    .onSubmit { addExercise() }

                HStack {
                    ForEach(ExerciseUnit.allCases, id: \.self) { unit in
                        Button {
                            newExerciseUnit = unit
                        } label: {
                            Text(unit.rawValue)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(newExerciseUnit == unit ? theme.accentColor : DesignTokens.card2)
                                .foregroundStyle(newExerciseUnit == unit ? .black : .primary)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    Spacer()
                    Button("Ajouter") { addExercise() }
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(newExerciseName.trimmingCharacters(in: .whitespaces).isEmpty ? DesignTokens.textSecondary : theme.accentColor)
                        .disabled(newExerciseName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .padding()
        .background(DesignTokens.card1)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }

    private func addExercise() {
        let trimmed = newExerciseName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        workout.exercises.append(EditableExerciseItem(name: trimmed, unit: newExerciseUnit))
        newExerciseName = ""
        newExerciseUnit = .kg
    }
}

// MARK: - Editable Models

struct EditableWorkout: Identifiable {
    let id = UUID()
    var name: String
    var iconName: String
    var exercises: [EditableExerciseItem]
}

struct EditableExerciseItem: Identifiable {
    let id = UUID()
    var name: String
    var unit: ExerciseUnit
}
