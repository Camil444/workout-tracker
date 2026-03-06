import SwiftUI
import SwiftData

struct AddExerciseSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) private var theme

    let workout: Workout

    @State private var name = ""
    @State private var unit: ExerciseUnit = .kg
    @State private var addedExercises: [(name: String, unit: ExerciseUnit, id: UUID)] = []
    @FocusState private var isExerciseFieldFocused: Bool
    @State private var showAISearch = false
    @State private var aiDescription = ""
    @State private var aiLoading = false
    @State private var aiError: String?

    private var suggestions: [ExerciseRecommendation] {
        let existingNames = Set(workout.exercises.map { $0.name.lowercased() })
        let addedNames = Set(addedExercises.map { $0.name.lowercased() })
        let allExisting = existingNames.union(addedNames)
        return ExerciseRecommendations.suggestions(for: workout.name)
            .filter { !allExisting.contains($0.name.lowercased()) }
    }

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Exercices ajoutes dans cette session
                    if !addedExercises.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Ajoutes")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(DesignTokens.textSecondary)
                            ForEach(addedExercises, id: \.id) { ex in
                                HStack {
                                    Text(ex.name)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundStyle(.primary)
                                    Spacer()
                                    Text(ex.unit.rawValue)
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 3)
                                        .background(ex.unit == .pdc ? theme.accentColor.opacity(0.2) : DesignTokens.card2)
                                        .foregroundStyle(ex.unit == .pdc ? theme.accentColor : DesignTokens.textSecondary)
                                        .clipShape(RoundedRectangle(cornerRadius: 4))
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.caption)
                                        .foregroundStyle(theme.accentColor)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }

                    // Suggestions
                    if !suggestions.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Suggestions")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(DesignTokens.textSecondary)

                            FlowLayout(spacing: 8) {
                                ForEach(suggestions) { rec in
                                    Button {
                                        addExercise(name: rec.name, unit: rec.unit)
                                    } label: {
                                        HStack(spacing: 4) {
                                            Image(systemName: "plus")
                                                .font(.system(size: 8, weight: .bold))
                                            Text(rec.name)
                                                .font(.subheadline)
                                            if rec.unit == .pdc {
                                                Text("PDC")
                                                    .font(.caption2)
                                                    .fontWeight(.bold)
                                                    .foregroundStyle(theme.accentColor)
                                            }
                                        }
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(DesignTokens.card2)
                                        .foregroundStyle(.primary)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                }
                            }
                        }
                    }

                    // Input toujours visible
                    VStack(spacing: 8) {
                        TextField("Nom de l'exercice", text: $name)
                            .textFieldStyle(.plain)
                            .font(.subheadline)
                            .padding(10)
                            .background(DesignTokens.card2)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .foregroundStyle(.primary)
                            .focused($isExerciseFieldFocused)
                            .submitLabel(.done)
                            .onSubmit { addCurrentExercise() }

                        HStack {
                            ForEach(ExerciseUnit.allCases, id: \.self) { u in
                                Button {
                                    unit = u
                                } label: {
                                    Text(u.rawValue)
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(unit == u ? theme.accentColor : DesignTokens.card2)
                                        .foregroundStyle(unit == u ? .black : .primary)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                            Spacer()
                            Button("Ajouter") { addCurrentExercise() }
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundStyle(name.trimmingCharacters(in: .whitespaces).isEmpty ? DesignTokens.textSecondary : theme.accentColor)
                                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
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

                    // Bouton Terminer
                    Button {
                        dismiss()
                    } label: {
                        Text(addedExercises.isEmpty ? "Fermer" : "Terminer")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(addedExercises.isEmpty ? DesignTokens.card2 : theme.accentColor)
                            .foregroundStyle(addedExercises.isEmpty ? DesignTokens.textSecondary : .black)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .id("bottomButton")
                }
                .padding()
            }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: isExerciseFieldFocused) { _, focused in
                if focused {
                    scrollToBottom(proxy)
                }
            }
            .onChange(of: addedExercises.count) {
                if isExerciseFieldFocused {
                    scrollToBottom(proxy)
                }
            }
            .background(DesignTokens.bgPrimary)
            }
            .navigationTitle("Ajouter des exercices")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") { dismiss() }
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

    private func addCurrentExercise() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        addExercise(name: trimmed, unit: unit)
        name = ""
        unit = .kg
    }

    private func addExercise(name: String, unit: ExerciseUnit) {
        let exercise = Exercise(
            name: name,
            unit: unit,
            sortOrder: workout.exercises.count + addedExercises.count
        )
        exercise.workout = workout
        modelContext.insert(exercise)
        addedExercises.append((name: name, unit: unit, id: UUID()))
    }

    private func searchWithAI() {
        aiLoading = true
        aiError = nil
        Task {
            do {
                let result = try await OpenAIService.identifyExercise(description: aiDescription)
                await MainActor.run {
                    name = result.name
                    unit = result.unit
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
}
