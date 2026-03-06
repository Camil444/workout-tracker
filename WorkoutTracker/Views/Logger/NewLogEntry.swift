import SwiftUI
import SwiftData

struct NewLogEntry: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) private var theme

    let exercise: Exercise
    let onSave: () -> Void

    @State private var sets: [EditableSet]

    init(exercise: Exercise, onSave: @escaping () -> Void) {
        self.exercise = exercise
        self.onSave = onSave
        _sets = State(initialValue: [
            EditableSet(), EditableSet(), EditableSet()
        ])
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Semaine \(exercise.nextWeekNumber)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.white)

            ForEach(Array(sets.enumerated()), id: \.element.id) { index, _ in
                HStack(spacing: 8) {
                    Text("S\(index + 1)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(DesignTokens.textSecondary)
                        .frame(width: 28)

                    TextField("Reps", text: $sets[index].repsText)
                        .textFieldStyle(.plain)
                        .keyboardType(.numberPad)
                        .padding(10)
                        .background(DesignTokens.card1)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .foregroundStyle(.white)
                        .frame(width: 70)

                    if exercise.unit == .kg {
                        Text("x")
                            .foregroundStyle(DesignTokens.textSecondary)
                        TextField("Kg", text: $sets[index].weightText)
                            .textFieldStyle(.plain)
                            .keyboardType(.decimalPad)
                            .padding(10)
                            .background(DesignTokens.card1)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .foregroundStyle(.white)
                            .frame(width: 80)
                        Text("kg")
                            .font(.caption)
                            .foregroundStyle(DesignTokens.textSecondary)
                    } else {
                        Text("x PDC")
                            .font(.subheadline)
                            .foregroundStyle(theme.accentColor)
                    }

                    Spacer()

                    if index == sets.count - 1 && sets.count > 1 {
                        Button {
                            sets.removeLast()
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .foregroundStyle(DesignTokens.destructive)
                        }
                    }
                }
            }

            HStack(spacing: 12) {
                Button {
                    sets.append(EditableSet())
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                        Text("Série")
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignTokens.textSecondary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [5]))
                            .foregroundStyle(DesignTokens.border)
                    )
                }

                Spacer()

                Button {
                    saveLog()
                } label: {
                    Text("Valider")
                        .fontWeight(.bold)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(theme.accentColor)
                        .foregroundStyle(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .sensoryFeedback(.success, trigger: false)
            }
        }
        .padding()
        .background(DesignTokens.card2)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func saveLog() {
        let entries = sets.compactMap { s -> SetEntry? in
            guard let reps = Int(s.repsText), reps > 0 else { return nil }
            let weight = Double(s.weightText.replacingOccurrences(of: ",", with: ".")) ?? 0
            return SetEntry(reps: reps, weight: exercise.unit == .pdc ? 0 : weight)
        }
        guard !entries.isEmpty else { return }

        let log = ExerciseLog(weekNumber: exercise.nextWeekNumber, sets: entries)
        log.exercise = exercise
        modelContext.insert(log)
        onSave()
    }
}

private struct EditableSet: Identifiable {
    let id = UUID()
    var repsText: String = ""
    var weightText: String = ""
}
