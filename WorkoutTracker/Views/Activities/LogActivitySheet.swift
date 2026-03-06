import SwiftUI
import SwiftData

struct LogActivitySheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) private var theme

    @Environment(HealthKitManager.self) private var healthKit
    @Query private var profiles: [UserProfile]

    let activity: SportActivity

    @State private var durationMinutes = ""
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(spacing: 12) {
                        Image(systemName: activity.iconName)
                            .font(.title2)
                            .foregroundStyle(theme.accentColor)
                        Text(activity.name)
                            .font(.title3)
                            .fontWeight(.heavy)
                            .foregroundStyle(.primary)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Durée")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(DesignTokens.textSecondary)
                        HStack {
                            TextField("60", text: $durationMinutes)
                                .textFieldStyle(.plain)
                                .keyboardType(.numberPad)
                                .foregroundStyle(.primary)
                            Text("min")
                                .foregroundStyle(DesignTokens.textSecondary)
                        }
                        .padding()
                        .background(DesignTokens.card2)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes (optionnel)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(DesignTokens.textSecondary)
                        TextField("Ex: sparring, sac de frappe...", text: $notes, axis: .vertical)
                            .textFieldStyle(.plain)
                            .lineLimit(2...4)
                            .padding()
                            .background(DesignTokens.card2)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .foregroundStyle(.primary)
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
        .presentationDetents([.medium])
        .presentationBackground(DesignTokens.bgPrimary)
    }

    private var canSave: Bool {
        !durationMinutes.isEmpty && (Double(durationMinutes) ?? 0) > 0
    }

    private func saveLog() {
        let log = SportActivityLog(
            date: Date(),
            durationMinutes: Double(durationMinutes) ?? 0,
            notes: notes.trimmingCharacters(in: .whitespaces)
        )
        log.activity = activity
        modelContext.insert(log)

        // Sync with HealthKit
        let weight = profiles.first?.weight ?? 70
        let duration = Double(durationMinutes) ?? 0
        let calories = CalorieData.sportCalories(activityName: activity.name, durationMinutes: duration, weightKg: weight)
        if calories > 0 {
            healthKit.saveWorkout(calories: calories, durationMinutes: duration)
        }

        dismiss()
    }
}
