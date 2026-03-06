import SwiftUI
import Charts

struct ExerciseChart: View {
    @Environment(ThemeManager.self) private var theme

    let exercise: Exercise

    private var chartData: [(week: String, value: Double)] {
        exercise.sortedLogs.map { log in
            let value: Double = exercise.unit == .pdc
                ? Double(log.maxReps)
                : log.maxWeight
            return (week: "S\(log.weekNumber)", value: value)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(exercise.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                    Text(exercise.unit == .pdc ? "reps max" : "kg max")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(DesignTokens.card2)
                        .foregroundStyle(DesignTokens.textSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }

                Spacer()

                if let prog = exercise.progression {
                    Text(String(format: "%+.0f%%", prog))
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(prog >= 0 ? theme.accentColor : DesignTokens.destructive)
                }
            }

            if chartData.count >= 2 {
                Chart {
                    ForEach(Array(chartData.enumerated()), id: \.offset) { index, data in
                        LineMark(
                            x: .value("Semaine", data.week),
                            y: .value("Valeur", data.value)
                        )
                        .foregroundStyle(theme.accentColor)
                        .interpolationMethod(.catmullRom)
                        .lineStyle(StrokeStyle(lineWidth: 2.5))

                        AreaMark(
                            x: .value("Semaine", data.week),
                            y: .value("Valeur", data.value)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [theme.accentColor.opacity(0.3), theme.accentColor.opacity(0)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .interpolationMethod(.catmullRom)

                        PointMark(
                            x: .value("Semaine", data.week),
                            y: .value("Valeur", data.value)
                        )
                        .foregroundStyle(theme.accentColor)
                        .symbolSize(30)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(DesignTokens.border)
                        AxisValueLabel()
                            .foregroundStyle(DesignTokens.textSecondary)
                    }
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel()
                            .foregroundStyle(DesignTokens.textSecondary)
                    }
                }
                .frame(height: 200)
            } else {
                Text("Pas assez de données")
                    .font(.subheadline)
                    .foregroundStyle(DesignTokens.textSecondary)
                    .frame(maxWidth: .infinity, minHeight: 100)
            }
        }
        .padding()
        .background(DesignTokens.card1)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
