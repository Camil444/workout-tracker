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
    @State private var showAISearch = false
    @State private var aiDescription = ""
    @State private var aiLoading = false
    @State private var aiError: String?
    @FocusState private var isExerciseFieldFocused: Bool

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
            ScrollViewReader { proxy in
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
                            .foregroundStyle(.primary)
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
                                            .foregroundStyle(selectedIcon == icon ? .black : .primary)
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
                                            .foregroundStyle(.primary)
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

                        VStack(spacing: 8) {
                            TextField("Nom de l'exercice", text: $newExerciseName)
                                .textFieldStyle(.plain)
                                .font(.subheadline)
                                .padding(10)
                                .background(DesignTokens.card2)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .foregroundStyle(.primary)
                                .focused($isExerciseFieldFocused)
                                .submitLabel(.done)
                                .onSubmit { addQuickExercise() }

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
                                Button("Ajouter") { addQuickExercise() }
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundStyle(newExerciseName.trimmingCharacters(in: .whitespaces).isEmpty ? DesignTokens.textSecondary : theme.accentColor)
                                    .disabled(newExerciseName.trimmingCharacters(in: .whitespaces).isEmpty)
                            }
                        }
                    }

                    // AI search
                    VStack(alignment: .leading, spacing: 10) {
                        Button {
                            withAnimation { showAISearch.toggle() }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "sparkles")
                                Text("Decrire un exercice")
                                    .fontWeight(.semibold)
                            }
                            .font(.subheadline)
                            .foregroundStyle(theme.accentColor)
                        }

                        if showAISearch {
                            VStack(spacing: 12) {
                                TextField("Ex: la machine ou on pousse les poids avec les jambes...", text: $aiDescription, axis: .vertical)
                                    .textFieldStyle(.plain)
                                    .lineLimit(2...4)
                                    .padding()
                                    .background(DesignTokens.card2)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .foregroundStyle(.primary)

                                Button {
                                    searchWithAI()
                                } label: {
                                    HStack(spacing: 6) {
                                        if aiLoading {
                                            ProgressView()
                                                .tint(.black)
                                                .scaleEffect(0.8)
                                        }
                                        Text(aiLoading ? "Recherche..." : "Identifier")
                                            .fontWeight(.semibold)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(
                                        aiDescription.trimmingCharacters(in: .whitespaces).isEmpty || aiLoading
                                            ? DesignTokens.card2
                                            : theme.accentColor
                                    )
                                    .foregroundStyle(
                                        aiDescription.trimmingCharacters(in: .whitespaces).isEmpty || aiLoading
                                            ? DesignTokens.textSecondary
                                            : .black
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                                .disabled(aiDescription.trimmingCharacters(in: .whitespaces).isEmpty || aiLoading)

                                if let error = aiError {
                                    Text(error)
                                        .font(.caption)
                                        .foregroundStyle(DesignTokens.destructive)
                                }
                            }
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
                    .id("bottomButton")
                }
                .padding()
            }
            .scrollDismissesKeyboard(.interactively)
            .dismissKeyboardOnTap()
            .onChange(of: isExerciseFieldFocused) { _, focused in
                if focused {
                    scrollToBottom(proxy)
                }
            }
            .onChange(of: exercises.count) {
                if isExerciseFieldFocused {
                    scrollToBottom(proxy)
                }
            }
            .background(DesignTokens.bgPrimary)
            }
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

    private func scrollToBottom(_ proxy: ScrollViewProxy) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.easeOut(duration: 0.25)) {
                proxy.scrollTo("bottomButton", anchor: .bottom)
            }
        }
    }

    private var recommendedExercises: [ExerciseRecommendation] {
        let existing = Set(exercises.map { $0.name.lowercased() })
        return ExerciseRecommendations.suggestions(for: name)
            .filter { !existing.contains($0.name.lowercased()) }
    }

    private var canCreate: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && !exercises.isEmpty
    }

    private func addQuickExercise() {
        let trimmed = newExerciseName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        exercises.append((name: trimmed, unit: newExerciseUnit, id: UUID()))
        newExerciseName = ""
        newExerciseUnit = .kg
    }

    private func searchWithAI() {
        aiLoading = true
        aiError = nil
        Task {
            do {
                let result = try await OpenAIService.identifyExercise(description: aiDescription)
                await MainActor.run {
                    newExerciseName = result.name
                    newExerciseUnit = result.unit
                    aiLoading = false
                    showAISearch = false
                    aiDescription = ""
                }
            } catch {
                await MainActor.run {
                    aiError = "Erreur : \(error.localizedDescription)"
                    aiLoading = false
                }
            }
        }
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
