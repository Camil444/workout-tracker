import SwiftUI
import SwiftData

struct ProgramTemplateSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) private var theme

    @Query(sort: \Workout.sortOrder) private var existingWorkouts: [Workout]

    @State private var selectedTemplate: ProgramTemplate?
    @State private var showConfirm = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Choisis un programme et on genere tes seances automatiquement.")
                        .font(.subheadline)
                        .foregroundStyle(DesignTokens.textSecondary)
                        .padding(.horizontal)

                    ForEach(ProgramTemplates.allMuscu, id: \.name) { template in
                        Button {
                            selectedTemplate = template
                            showConfirm = true
                        } label: {
                            templateCard(template)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top)
            }
            .background(DesignTokens.bgPrimary)
            .navigationTitle("Programmes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") { dismiss() }
                        .foregroundStyle(DesignTokens.textSecondary)
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
            .alert("Generer le programme ?", isPresented: $showConfirm) {
                Button("Annuler", role: .cancel) { }
                Button("Generer") {
                    if let template = selectedTemplate {
                        generateProgram(template)
                    }
                }
            } message: {
                if let template = selectedTemplate {
                    Text("\(template.name) — \(template.days.count) seances avec tous les exercices seront creees.")
                }
            }
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

            // Preview of days
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

    private func generateProgram(_ template: ProgramTemplate) {
        let startOrder = (existingWorkouts.last?.sortOrder ?? -1) + 1

        for (index, day) in template.days.enumerated() {
            let workout = Workout(
                name: day.name,
                iconName: day.iconName,
                sortOrder: startOrder + index
            )
            modelContext.insert(workout)

            for (exIndex, ex) in day.exercises.enumerated() {
                let exercise = Exercise(
                    name: ex.name,
                    unit: ex.unit,
                    sortOrder: exIndex
                )
                exercise.workout = workout
                modelContext.insert(exercise)
            }
        }

        dismiss()
    }
}

struct IntervalTemplateSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeManager.self) private var theme
    let onSelect: (IntervalTemplate) -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(ProgramTemplates.intervalTemplates, id: \.name) { template in
                        Button {
                            onSelect(template)
                            dismiss()
                        } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(template.name)
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.primary)
                                    Spacer()
                                    Text("\(template.intervals)x")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(theme.accentColor)
                                        .foregroundStyle(.black)
                                        .clipShape(RoundedRectangle(cornerRadius: 6))
                                }
                                Text(template.description)
                                    .font(.caption)
                                    .foregroundStyle(DesignTokens.textSecondary)
                                    .multilineTextAlignment(.leading)
                                HStack(spacing: 12) {
                                    Label("\(template.warmUpMin)min echauffe", systemImage: "flame")
                                    Label("\(template.workSec)s effort / \(template.restSec)s repos", systemImage: "bolt.fill")
                                }
                                .font(.caption2)
                                .foregroundStyle(DesignTokens.textSecondary)
                            }
                            .padding()
                            .background(DesignTokens.card1)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .background(DesignTokens.bgPrimary)
            .navigationTitle("Templates fractionne")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") { dismiss() }
                        .foregroundStyle(DesignTokens.textSecondary)
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}
