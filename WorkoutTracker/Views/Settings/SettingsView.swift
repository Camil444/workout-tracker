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
    @State private var draggedWorkout: Workout?
    @State private var showResetConfirmation = false

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Parametres")
                    .font(.system(size: 30, weight: .heavy))
                    .foregroundStyle(.primary)
                    .padding(.horizontal)

                if let profile {
                    section("Profil") {
                        VStack(spacing: 12) {
                            profileField("Prenom", text: Binding(
                                get: { profile.firstName },
                                set: { profile.firstName = $0 }
                            ))
                            profileNumberField("Age", value: Binding(
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
                        VStack(alignment: .leading, spacing: 16) {
                            // Dark/Light mode toggle
                            HStack {
                                Image(systemName: profile.isDarkMode ? "moon.fill" : "sun.max.fill")
                                    .foregroundStyle(theme.accentColor)
                                Text("Mode sombre")
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.primary)
                                Spacer()
                                Toggle("", isOn: Binding(
                                    get: { profile.isDarkMode },
                                    set: {
                                        profile.isDarkMode = $0
                                        theme.isDarkMode = $0
                                    }
                                ))
                                .tint(theme.accentColor)
                            }

                            Divider().background(DesignTokens.border)

                            VStack(alignment: .leading, spacing: 12) {
                                Text("Couleur d'accent")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(DesignTokens.textSecondary)
                                AccentColorPicker(profile: profile)
                            }
                        }
                    }

                    section("Timer de repos") {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Duree par defaut : \(profile.restTimerSeconds)s")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)
                            Slider(
                                value: Binding(
                                    get: { Double(profile.restTimerSeconds) },
                                    set: { profile.restTimerSeconds = Int($0) }
                                ),
                                in: 15...300,
                                step: 15
                            )
                            .tint(theme.accentColor)
                            HStack {
                                Text("15s")
                                    .font(.caption2)
                                    .foregroundStyle(DesignTokens.textSecondary)
                                Spacer()
                                Text("5min")
                                    .font(.caption2)
                                    .foregroundStyle(DesignTokens.textSecondary)
                            }
                        }
                    }
                }

                section("Seances") {
                    if workouts.isEmpty {
                        Text("Aucune seance")
                            .font(.subheadline)
                            .foregroundStyle(DesignTokens.textSecondary)
                    } else {
                        VStack(spacing: 8) {
                            ForEach(workouts) { workout in
                                HStack {
                                    Image(systemName: "line.3.horizontal")
                                        .foregroundStyle(DesignTokens.textSecondary)
                                        .font(.caption)
                                    Image(systemName: workout.iconName)
                                        .foregroundStyle(.primary)
                                        .frame(width: 32)
                                    Text(workout.name)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.primary)
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
                                .opacity(draggedWorkout?.id == workout.id ? 0.5 : 1)
                                .draggable(workout.id.uuidString) {
                                    Text(workout.name)
                                        .padding(8)
                                        .background(DesignTokens.card2)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                                .dropDestination(for: String.self) { items, _ in
                                    guard let droppedIDString = items.first,
                                          let droppedID = UUID(uuidString: droppedIDString),
                                          let fromIndex = workouts.firstIndex(where: { $0.id == droppedID }),
                                          let toIndex = workouts.firstIndex(where: { $0.id == workout.id }),
                                          fromIndex != toIndex else { return false }
                                    var reordered = Array(workouts)
                                    let item = reordered.remove(at: fromIndex)
                                    reordered.insert(item, at: toIndex)
                                    for (i, w) in reordered.enumerated() { w.sortOrder = i }
                                    return true
                                }
                            }
                        }
                    }
                }

                section("Courses a pied") {
                    if runningSessions.isEmpty {
                        Text("Aucune course")
                            .font(.subheadline)
                            .foregroundStyle(DesignTokens.textSecondary)
                    } else {
                        VStack(spacing: 8) {
                            ForEach(runningSessions) { session in
                                HStack {
                                    Image(systemName: session.runningType == .footing ? "figure.run" : "bolt.horizontal.fill")
                                        .foregroundStyle(.primary)
                                        .frame(width: 32)
                                    Text(session.name)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.primary)
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

                section("Activites") {
                    if sportActivities.isEmpty {
                        Text("Aucune activite")
                            .font(.subheadline)
                            .foregroundStyle(DesignTokens.textSecondary)
                    } else {
                        VStack(spacing: 8) {
                            ForEach(sportActivities) { activity in
                                HStack {
                                    Image(systemName: activity.iconName)
                                        .foregroundStyle(.primary)
                                        .frame(width: 32)
                                    Text(activity.name)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.primary)
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

                section("A propos") {
                    VStack(spacing: 12) {
                        HStack {
                            Text("Version")
                                .foregroundStyle(.primary)
                            Spacer()
                            Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                                .foregroundStyle(DesignTokens.textSecondary)
                        }

                        Divider().background(DesignTokens.border)

                        Button {
                            showResetConfirmation = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.counterclockwise")
                                Text("Reinitialiser l'application")
                            }
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(DesignTokens.destructive)
                            .frame(maxWidth: .infinity)
                        }
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
            Text("Cette action est irreversible. Toutes les donnees de cette seance (exercices, historique) seront definitivement perdues.")
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
            Text("Cette action est irreversible. Toutes les sessions de course seront supprimees.")
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
            Text("Cette action est irreversible. Toutes les sessions de cette activite seront supprimees.")
        }
        .alert("Reinitialiser l'application ?", isPresented: $showResetConfirmation) {
            Button("Annuler", role: .cancel) { }
            Button("Reinitialiser", role: .destructive) {
                resetApp()
            }
        } message: {
            Text("Toutes les donnees seront supprimees et tu reviendras a l'onboarding.")
        }
    }

    private func resetApp() {
        for w in workouts { modelContext.delete(w) }
        for r in runningSessions { modelContext.delete(r) }
        for a in sportActivities { modelContext.delete(a) }
        if let profile {
            profile.hasCompletedOnboarding = false
            profile.firstName = ""
            profile.age = nil
            profile.weight = nil
            profile.height = nil
        }
    }

    @ViewBuilder
    private func section(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
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
                .foregroundStyle(.primary)
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
                .foregroundStyle(.primary)
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
                .foregroundStyle(.primary)
            Text(suffix)
                .foregroundStyle(DesignTokens.textSecondary)
        }
        .padding()
        .background(DesignTokens.card2)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
