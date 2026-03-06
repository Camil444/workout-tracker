import SwiftUI

struct SummaryCards: View {
    @Environment(ThemeManager.self) private var theme

    let exercises: [Exercise]

    private var bestLift: (name: String, value: Double, unit: ExerciseUnit)? {
        var best: (String, Double, ExerciseUnit)?
        for ex in exercises where ex.unit == .kg {
            let max = ex.currentMax
            if max > (best?.1 ?? 0) {
                best = (ex.name, max, .kg)
            }
        }
        if best == nil {
            for ex in exercises where ex.unit == .pdc {
                let max = ex.currentMax
                if max > (best?.1 ?? 0) {
                    best = (ex.name, max, .pdc)
                }
            }
        }
        return best
    }

    private var averageProgression: Double? {
        let progs = exercises.compactMap(\.progression)
        guard !progs.isEmpty else { return nil }
        return progs.reduce(0, +) / Double(progs.count)
    }

    private var totalWeeks: Int {
        exercises.flatMap(\.logs).map(\.weekNumber).max() ?? 0
    }

    var body: some View {
        HStack(spacing: 12) {
            if let best = bestLift {
                VStack(alignment: .leading, spacing: 6) {
                    Text("MEILLEUR LIFT")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(DesignTokens.textSecondary)
                    Text(best.unit == .pdc ? "\(Int(best.value)) reps" : "\(Int(best.value))kg")
                        .font(.title2)
                        .fontWeight(.heavy)
                        .foregroundStyle(theme.accentColor)
                    Text(best.name)
                        .font(.caption)
                        .foregroundStyle(DesignTokens.textSecondary)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(DesignTokens.card1)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("PROGRESSION")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignTokens.textSecondary)
                if let avg = averageProgression {
                    Text(String(format: "%+.0f%%", avg))
                        .font(.title2)
                        .fontWeight(.heavy)
                        .foregroundStyle(avg >= 0 ? theme.accentColor : DesignTokens.destructive)
                } else {
                    Text("-")
                        .font(.title2)
                        .fontWeight(.heavy)
                        .foregroundStyle(DesignTokens.textSecondary)
                }
                Text("moyenne sur \(totalWeeks) sem.")
                    .font(.caption)
                    .foregroundStyle(DesignTokens.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(DesignTokens.card1)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}
