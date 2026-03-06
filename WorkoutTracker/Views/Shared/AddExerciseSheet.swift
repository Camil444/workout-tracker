import SwiftUI
import SwiftData

struct AddExerciseSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) private var theme

    let workout: Workout

    @State private var name = ""
    @State private var unit: ExerciseUnit = .kg
    @State private var showAISearch = false
    @State private var aiDescription = ""
    @State private var aiLoading = false
    @State private var aiError: String?

    private var suggestions: [ExerciseRecommendation] {
        let existing = Set(workout.exercises.map { $0.name.lowercased() })
        return ExerciseRecommendations.suggestions(for: workout.name)
            .filter { !existing.contains($0.name.lowercased()) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    TextField("Nom de l'exercice", text: $name)
                        .textFieldStyle(.plain)
                        .padding()
                        .background(DesignTokens.card2)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .foregroundStyle(.primary)
                        .submitLabel(.done)

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

                    if !suggestions.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Suggestions")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(DesignTokens.textSecondary)

                            FlowLayout(spacing: 8) {
                                ForEach(suggestions) { rec in
                                    Button {
                                        name = rec.name
                                        unit = rec.unit
                                    } label: {
                                        HStack(spacing: 4) {
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
                                        .background(
                                            name == rec.name
                                                ? theme.accentColor.opacity(0.2)
                                                : DesignTokens.card2
                                        )
                                        .foregroundStyle(
                                            name == rec.name
                                                ? theme.accentColor
                                                : .white
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                }
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Button {
                            withAnimation { showAISearch.toggle() }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "sparkles")
                                Text("Décrire un exercice")
                                    .fontWeight(.semibold)
                            }
                            .font(.subheadline)
                            .foregroundStyle(theme.accentColor)
                        }

                        if showAISearch {
                            VStack(spacing: 12) {
                                TextField("Ex: la machine où on pousse les poids avec les jambes...", text: $aiDescription, axis: .vertical)
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
                }
                .padding()
            }
            .scrollDismissesKeyboard(.interactively)
            .dismissKeyboardOnTap()
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
        .presentationDetents([.large])
        .presentationBackground(DesignTokens.bgPrimary)
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
