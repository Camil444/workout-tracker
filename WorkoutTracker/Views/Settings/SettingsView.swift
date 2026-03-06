import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) private var theme
    @Query private var profiles: [UserProfile]
    @Query(sort: \Workout.sortOrder) private var workouts: [Workout]

    @State private var workoutToDelete: Workout?

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Paramètres")
                    .font(.system(size: 30, weight: .heavy))
                    .foregroundStyle(.white)
                    .padding(.horizontal)

                if let profile {
                    section("Profil") {
                        VStack(spacing: 12) {
                            profileField("Prénom", text: Binding(
                                get: { profile.firstName },
                                set: { profile.firstName = $0 }
                            ))
                            profileNumberField("Âge", value: Binding(
                                get: { profile.age.map(String.init) ?? "" },
                                set: { profile.age = Int($0) }
                            ), suffix: "ans")
                            profileDecimalField("Poids", value: Binding(
                                get: { profile.weight.map { String(format: "%.1f", $0) } ?? "" },
                                set: { profile.weight = Double($0.replacingOccurrences(of: ",", with: ".")) }
                            ), suffix: "kg")
                            profileNumberField("Taille", value: Binding(
                                get: { profile.height.map { String(format: "%.0f", $0) } ?? "" },
                                set: { profile.height = Double($0) }
                            ), suffix: "cm")
                        }
                    }

                    section("Apparence") {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Couleur d'accent")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(DesignTokens.textSecondary)
                            AccentColorPicker(profile: profile)
                        }
                    }
                }

                section("Séances") {
                    if workouts.isEmpty {
                        Text("Aucune séance")
                            .font(.subheadline)
                            .foregroundStyle(DesignTokens.textSecondary)
                    } else {
                        VStack(spacing: 8) {
                            ForEach(workouts) { workout in
                                HStack {
                                    Image(systemName: workout.iconName)
                                        .foregroundStyle(.white)
                                        .frame(width: 32)
                                    Text(workout.name)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.white)
                                    Spacer()
                                    Text("\(workout.exercises.count) exos")
                                        .font(.caption)
                                        .foregroundStyle(DesignTokens.textSecondary)
                                    Button {
                                        workoutToDelete = workout
                                    } label: {
                                        Image(systemName: "trash")
                                            .foregroundStyle(DesignTokens.destructive)
                                    }
                                }
                                .padding()
                                .background(DesignTokens.card2)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                }

                section("À propos") {
                    HStack {
                        Text("Version")
                            .foregroundStyle(.white)
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(DesignTokens.textSecondary)
                    }
                }
            }
            .padding(.top)
        }
        .background(DesignTokens.bgPrimary)
        .alert(
            "Supprimer \(workoutToDelete?.name ?? "") ?",
            isPresented: Binding(
                get: { workoutToDelete != nil },
                set: { if !$0 { workoutToDelete = nil } }
            )
        ) {
            Button("Annuler", role: .cancel) { workoutToDelete = nil }
            Button("Supprimer", role: .destructive) {
                if let workout = workoutToDelete {
                    modelContext.delete(workout)
                    workoutToDelete = nil
                }
            }
        } message: {
            Text("Cette action est irréversible. Toutes les données de cette séance (exercices, historique) seront définitivement perdues.")
        }
    }

    @ViewBuilder
    private func section(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .padding(.horizontal)
            content()
                .padding()
                .background(DesignTokens.card1)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)
        }
    }

    private func profileField(_ label: String, text: Binding<String>) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(DesignTokens.textSecondary)
                .frame(width: 70, alignment: .leading)
            TextField(label, text: text)
                .textFieldStyle(.plain)
                .foregroundStyle(.white)
        }
        .padding()
        .background(DesignTokens.card2)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func profileNumberField(_ label: String, value: Binding<String>, suffix: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(DesignTokens.textSecondary)
                .frame(width: 70, alignment: .leading)
            TextField(label, text: value)
                .textFieldStyle(.plain)
                .keyboardType(.numberPad)
                .foregroundStyle(.white)
            Text(suffix)
                .foregroundStyle(DesignTokens.textSecondary)
        }
        .padding()
        .background(DesignTokens.card2)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func profileDecimalField(_ label: String, value: Binding<String>, suffix: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(DesignTokens.textSecondary)
                .frame(width: 70, alignment: .leading)
            TextField(label, text: value)
                .textFieldStyle(.plain)
                .keyboardType(.decimalPad)
                .foregroundStyle(.white)
            Text(suffix)
                .foregroundStyle(DesignTokens.textSecondary)
        }
        .padding()
        .background(DesignTokens.card2)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
