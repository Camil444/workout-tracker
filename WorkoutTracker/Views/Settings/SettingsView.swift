import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) private var theme
    @Query private var profiles: [UserProfile]
    @Query(sort: \Workout.sortOrder) private var workouts: [Workout]
    @Query(sort: \RunningSessionType.sortOrder) private var runningSessions: [RunningSessionType]
    @Query(sort: \SportActivity.sortOrder) private var sportActivities: [SportActivity]

    @State private var workoutToDelete: Workout?
    @State private var runningToDelete: RunningSessionType?
    @State private var activityToDelete: SportActivity?
    @State private var showLocationSettings = false

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

                section("Lieux d'entraînement") {
                    Button {
                        showLocationSettings = true
                    } label: {
                        HStack {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundStyle(theme.accentColor)
                            Text("Gérer mes lieux")
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(DesignTokens.textSecondary)
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

                section("Courses à pied") {
                    if runningSessions.isEmpty {
                        Text("Aucune course")
                            .font(.subheadline)
                            .foregroundStyle(DesignTokens.textSecondary)
                    } else {
                        VStack(spacing: 8) {
                            ForEach(runningSessions) { session in
                                HStack {
                                    Image(systemName: session.runningType == .footing ? "figure.run" : "bolt.horizontal.fill")
                                        .foregroundStyle(.white)
                                        .frame(width: 32)
                                    Text(session.name)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.white)
                                    Spacer()
                                    Text("\(session.logs.count) sessions")
                                        .font(.caption)
                                        .foregroundStyle(DesignTokens.textSecondary)
                                    Button {
                                        runningToDelete = session
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

                section("Activités") {
                    if sportActivities.isEmpty {
                        Text("Aucune activité")
                            .font(.subheadline)
                            .foregroundStyle(DesignTokens.textSecondary)
                    } else {
                        VStack(spacing: 8) {
                            ForEach(sportActivities) { activity in
                                HStack {
                                    Image(systemName: activity.iconName)
                                        .foregroundStyle(.white)
                                        .frame(width: 32)
                                    Text(activity.name)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.white)
                                    Spacer()
                                    Text("\(activity.logs.count) sessions")
                                        .font(.caption)
                                        .foregroundStyle(DesignTokens.textSecondary)
                                    Button {
                                        activityToDelete = activity
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
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                            .foregroundStyle(DesignTokens.textSecondary)
                    }
                }
            }
            .padding(.top)
        }
        .background(DesignTokens.bgPrimary)
        .sheet(isPresented: $showLocationSettings) {
            LocationSettingsView()
        }
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
        .alert(
            "Supprimer \(runningToDelete?.name ?? "") ?",
            isPresented: Binding(
                get: { runningToDelete != nil },
                set: { if !$0 { runningToDelete = nil } }
            )
        ) {
            Button("Annuler", role: .cancel) { runningToDelete = nil }
            Button("Supprimer", role: .destructive) {
                if let session = runningToDelete {
                    modelContext.delete(session)
                    runningToDelete = nil
                }
            }
        } message: {
            Text("Cette action est irréversible. Toutes les sessions de course seront supprimées.")
        }
        .alert(
            "Supprimer \(activityToDelete?.name ?? "") ?",
            isPresented: Binding(
                get: { activityToDelete != nil },
                set: { if !$0 { activityToDelete = nil } }
            )
        ) {
            Button("Annuler", role: .cancel) { activityToDelete = nil }
            Button("Supprimer", role: .destructive) {
                if let activity = activityToDelete {
                    modelContext.delete(activity)
                    activityToDelete = nil
                }
            }
        } message: {
            Text("Cette action est irréversible. Toutes les sessions de cette activité seront supprimées.")
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
