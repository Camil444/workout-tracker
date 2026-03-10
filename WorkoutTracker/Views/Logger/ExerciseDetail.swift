import SwiftUI
import SwiftData

struct ExerciseDetail: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) private var theme

    let exercise: Exercise
    let isLogging: Bool
    let onLogSaved: () -> Void

    @State private var showDeleteConfirmation = false
    @State private var logToDelete: ExerciseLog?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(exercise.sortedLogs.reversed()) { log in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Semaine \(log.weekNumber)")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                        Spacer()
                        if exercise.unit == .pdc {
                            Text("\(log.maxReps) reps")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundStyle(theme.accentColor)
                        } else {
                            Text("\(Int(log.maxWeight))kg")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundStyle(theme.accentColor)
                        }
                        Button {
                            logToDelete = log
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.caption)
                                .foregroundStyle(DesignTokens.destructive.opacity(0.6))
                        }
                    }
                    FlowLayout(spacing: 8) {
                        ForEach(Array(log.sets.enumerated()), id: \.offset) { _, set in
                            Text(set.displayString)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(DesignTokens.card1)
                                .foregroundStyle(.primary)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    // Show notes if present
                    if !log.notes.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "note.text")
                                .font(.caption2)
                                .foregroundStyle(DesignTokens.textSecondary)
                            Text(log.notes)
                                .font(.caption)
                                .foregroundStyle(DesignTokens.textSecondary)
                                .italic()
                        }
                    }
                }
                .padding(.vertical, 4)
            }

            if isLogging {
                NewLogEntry(exercise: exercise, onSave: onLogSaved)
            }

            Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "trash")
                    Text("Supprimer")
                }
                .font(.caption)
                .foregroundStyle(DesignTokens.destructive.opacity(0.7))
            }
            .padding(.top, 4)
            .alert("Supprimer \(exercise.name) ?", isPresented: $showDeleteConfirmation) {
                Button("Annuler", role: .cancel) { }
                Button("Supprimer", role: .destructive) {
                    modelContext.delete(exercise)
                }
            } message: {
                Text("Cette action supprimera l'exercice et tout son historique.")
            }
            .alert(
                "Supprimer Semaine \(logToDelete?.weekNumber ?? 0) ?",
                isPresented: Binding(
                    get: { logToDelete != nil },
                    set: { if !$0 { logToDelete = nil } }
                )
            ) {
                Button("Annuler", role: .cancel) { logToDelete = nil }
                Button("Supprimer", role: .destructive) {
                    if let log = logToDelete {
                        modelContext.delete(log)
                        logToDelete = nil
                    }
                }
            } message: {
                Text("Les donnees de cette semaine seront supprimees.")
            }
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var totalHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            totalHeight = y + rowHeight
        }

        return (CGSize(width: maxWidth, height: totalHeight), positions)
    }
}
