import SwiftUI
import SwiftData

struct LogRunningSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) private var theme

    let sessionType: RunningSessionType

    @State private var durationMinutes = ""
    @State private var distanceKm = ""
    @State private var paceMin = ""
    @State private var paceSec = ""
    // Fractionné
    @State private var warmUpMinutes = "10"
    @State private var coolDownMinutes = "5"
    @State private var intervalCount = "6"
    @State private var workDurationSeconds = "30"
    @State private var restDurationSeconds = "30"
    @State private var totalDistanceInterval = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(spacing: 12) {
                        Image(systemName: "figure.run")
                            .font(.title2)
                            .foregroundStyle(theme.accentColor)
                        VStack(alignment: .leading) {
                            Text(sessionType.name)
                                .font(.title3)
                                .fontWeight(.heavy)
                                .foregroundStyle(.white)
                            Text(sessionType.runningType.rawValue)
                                .font(.caption)
                                .foregroundStyle(DesignTokens.textSecondary)
                        }
                    }

                    if sessionType.runningType == .footing {
                        footingFields
                    } else {
                        intervalFields
                    }

                    Button {
                        saveLog()
                    } label: {
                        Text("Enregistrer")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(canSave ? theme.accentColor : DesignTokens.card2)
                            .foregroundStyle(canSave ? .black : DesignTokens.textSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .disabled(!canSave)
                    .sensoryFeedback(.success, trigger: false)
                }
                .padding()
            }
            .scrollDismissesKeyboard(.interactively)
            .dismissKeyboardOnTap()
            .background(DesignTokens.bgPrimary)
            .navigationTitle("Nouvelle session")
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

    @ViewBuilder
    private var footingFields: some View {
        VStack(alignment: .leading, spacing: 16) {
            fieldRow("Durée", suffix: "min") {
                TextField("45", text: $durationMinutes)
                    .keyboardType(.numberPad)
            }
            fieldRow("Distance", suffix: "km") {
                TextField("8.5", text: $distanceKm)
                    .keyboardType(.decimalPad)
            }
            VStack(alignment: .leading, spacing: 8) {
                Text("Allure moyenne")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignTokens.textSecondary)
                HStack(spacing: 8) {
                    HStack {
                        TextField("5", text: $paceMin)
                            .keyboardType(.numberPad)
                            .frame(width: 50)
                        Text("min")
                            .foregroundStyle(DesignTokens.textSecondary)
                    }
                    .padding()
                    .background(DesignTokens.card2)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    HStack {
                        TextField("30", text: $paceSec)
                            .keyboardType(.numberPad)
                            .frame(width: 50)
                        Text("sec / km")
                            .foregroundStyle(DesignTokens.textSecondary)
                    }
                    .padding()
                    .background(DesignTokens.card2)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .foregroundStyle(.white)
        }
    }

    @ViewBuilder
    private var intervalFields: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Structure de la séance")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.white)

            fieldRow("Échauffement", suffix: "min") {
                TextField("10", text: $warmUpMinutes)
                    .keyboardType(.numberPad)
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Intervalles")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignTokens.textSecondary)

                HStack(spacing: 12) {
                    VStack(spacing: 4) {
                        Text("Répétitions")
                            .font(.caption)
                            .foregroundStyle(DesignTokens.textSecondary)
                        TextField("6", text: $intervalCount)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .padding(10)
                            .background(DesignTokens.card2)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .foregroundStyle(.white)
                    }
                    VStack(spacing: 4) {
                        Text("Effort (sec)")
                            .font(.caption)
                            .foregroundStyle(DesignTokens.textSecondary)
                        TextField("30", text: $workDurationSeconds)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .padding(10)
                            .background(theme.accentColor.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .foregroundStyle(.white)
                    }
                    VStack(spacing: 4) {
                        Text("Repos (sec)")
                            .font(.caption)
                            .foregroundStyle(DesignTokens.textSecondary)
                        TextField("30", text: $restDurationSeconds)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .padding(10)
                            .background(DesignTokens.card2)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .foregroundStyle(.white)
                    }
                }

                // Visual preview
                intervalPreview
            }

            fieldRow("Retour au calme", suffix: "min") {
                TextField("5", text: $coolDownMinutes)
                    .keyboardType(.numberPad)
            }

            Divider().background(DesignTokens.border)

            Text("Résultats")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.white)

            fieldRow("Durée totale", suffix: "min") {
                TextField("35", text: $durationMinutes)
                    .keyboardType(.numberPad)
            }
            fieldRow("Distance", suffix: "km") {
                TextField("5.0", text: $totalDistanceInterval)
                    .keyboardType(.decimalPad)
            }
        }
    }

    @ViewBuilder
    private var intervalPreview: some View {
        let count = Int(intervalCount) ?? 0
        let work = Int(workDurationSeconds) ?? 0
        let rest = Int(restDurationSeconds) ?? 0
        let warm = Int(warmUpMinutes) ?? 0
        let cool = Int(coolDownMinutes) ?? 0

        if count > 0 && work > 0 {
            VStack(alignment: .leading, spacing: 6) {
                Text("Aperçu")
                    .font(.caption)
                    .foregroundStyle(DesignTokens.textSecondary)
                HStack(spacing: 2) {
                    // Warm-up block
                    if warm > 0 {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(DesignTokens.card2)
                            .frame(height: 24)
                            .overlay(
                                Text("\(warm)'")
                                    .font(.system(size: 9))
                                    .foregroundStyle(DesignTokens.textSecondary)
                            )
                    }
                    // Intervals
                    ForEach(0..<min(count, 10), id: \.self) { i in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(theme.accentColor)
                            .frame(height: 24)
                            .overlay(
                                Text("\(work)\"")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundStyle(.black)
                            )
                        if rest > 0 && i < count - 1 {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(DesignTokens.border)
                                .frame(width: 12, height: 24)
                        }
                    }
                    if count > 10 {
                        Text("...")
                            .font(.caption2)
                            .foregroundStyle(DesignTokens.textSecondary)
                    }
                    // Cool-down block
                    if cool > 0 {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(DesignTokens.card2)
                            .frame(height: 24)
                            .overlay(
                                Text("\(cool)'")
                                    .font(.system(size: 9))
                                    .foregroundStyle(DesignTokens.textSecondary)
                            )
                    }
                }
                let totalSec = warm * 60 + count * (work + rest) - rest + cool * 60
                Text("Durée estimée : \(totalSec / 60) min")
                    .font(.caption)
                    .foregroundStyle(DesignTokens.textSecondary)
            }
            .padding(12)
            .background(DesignTokens.card1)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    @ViewBuilder
    private func fieldRow(_ label: String, suffix: String, @ViewBuilder field: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(DesignTokens.textSecondary)
            HStack {
                field()
                    .textFieldStyle(.plain)
                    .foregroundStyle(.white)
                Text(suffix)
                    .foregroundStyle(DesignTokens.textSecondary)
            }
            .padding()
            .background(DesignTokens.card2)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var canSave: Bool {
        if sessionType.runningType == .footing {
            return !durationMinutes.isEmpty || !distanceKm.isEmpty
        } else {
            return !durationMinutes.isEmpty || !totalDistanceInterval.isEmpty
        }
    }

    private func saveLog() {
        let paceTotal = (Double(paceMin) ?? 0) * 60 + (Double(paceSec) ?? 0)
        let dist = sessionType.runningType == .footing
            ? (Double(distanceKm.replacingOccurrences(of: ",", with: ".")) ?? 0)
            : (Double(totalDistanceInterval.replacingOccurrences(of: ",", with: ".")) ?? 0)

        let log = RunningLog(
            date: Date(),
            durationMinutes: Double(durationMinutes) ?? 0,
            distanceKm: dist,
            averagePaceSecondsPerKm: paceTotal,
            warmUpMinutes: Double(warmUpMinutes) ?? 0,
            coolDownMinutes: Double(coolDownMinutes) ?? 0,
            intervalCount: Int(intervalCount) ?? 0,
            workDurationSeconds: Int(workDurationSeconds) ?? 0,
            restDurationSeconds: Int(restDurationSeconds) ?? 0
        )
        log.sessionType = sessionType
        modelContext.insert(log)
        dismiss()
    }
}
