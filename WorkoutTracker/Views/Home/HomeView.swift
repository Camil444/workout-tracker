import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(ThemeManager.self) private var theme
    @Environment(WorkoutViewModel.self) private var viewModel
    @Query(sort: \Workout.sortOrder) private var workouts: [Workout]
    @Query(sort: \RunningSessionType.sortOrder) private var runningSessions: [RunningSessionType]
    @Query(sort: \SportActivity.sortOrder) private var sportActivities: [SportActivity]
    @Query private var profiles: [UserProfile]

    @State private var showCreateWorkout = false
    @State private var showCreateRunning = false
    @State private var showCreateActivity = false
    @State private var selectedRunning: RunningSessionType?
    @State private var selectedActivity: SportActivity?
    @State private var showProgramTemplates = false

    private var profile: UserProfile? { profiles.first }

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("Bonne séance")
                        .font(.subheadline)
                        .foregroundStyle(DesignTokens.textSecondary)
                    Text("Bonjour, \(profile?.firstName ?? "")")
                        .font(.system(size: 30, weight: .heavy))
                        .foregroundStyle(.primary)
                }
                .padding(.horizontal)

                Text("Quelle séance aujourd'hui ?")
                    .font(.subheadline)
                    .foregroundStyle(DesignTokens.textSecondary)
                    .padding(.horizontal)

                // SECTION: Musculation
                HStack {
                    sectionHeader("Musculation", icon: "dumbbell.fill")
                    Spacer()
                    Button {
                        showProgramTemplates = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "doc.text")
                            Text("Programmes")
                        }
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(theme.accentColor)
                    }
                    .padding(.trailing)
                }

                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(workouts) { workout in
                        Button {
                            viewModel.navigateToWorkout(workout)
                        } label: {
                            WorkoutCard(
                                workout: workout,
                                bestExercise: viewModel.bestExercise(in: workout)
                            )
                        }
                        .buttonStyle(.plain)
                    }

                    Button { showCreateWorkout = true } label: {
                        NewItemCard(label: "Nouvelle")
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)

                // SECTION: Course à pied
                sectionHeader("Course à pied", icon: "figure.run")

                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(runningSessions) { session in
                        Button {
                            selectedRunning = session
                        } label: {
                            RunningCard(session: session)
                        }
                        .buttonStyle(.plain)
                    }

                    Button { showCreateRunning = true } label: {
                        NewItemCard(label: "Nouvelle")
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)

                // SECTION: Activités
                sectionHeader("Activités", icon: "flame.fill")

                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(sportActivities) { activity in
                        Button {
                            selectedActivity = activity
                        } label: {
                            ActivityCard(activity: activity)
                        }
                        .buttonStyle(.plain)
                    }

                    Button { showCreateActivity = true } label: {
                        NewItemCard(label: "Nouvelle")
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
            }
            .padding(.top)
            .padding(.bottom, 20)
        }
        .background(DesignTokens.bgPrimary)
        .sheet(isPresented: $showProgramTemplates) { ProgramTemplateSheet() }
        .sheet(isPresented: $showCreateWorkout) { CreateWorkoutSheet() }
        .sheet(isPresented: $showCreateRunning) { CreateRunningTypeSheet() }
        .sheet(isPresented: $showCreateActivity) { CreateActivitySheet() }
        .sheet(item: $selectedRunning) { session in
            LogRunningSheet(sessionType: session)
        }
        .sheet(item: $selectedActivity) { activity in
            LogActivitySheet(activity: activity)
        }
    }

    @ViewBuilder
    private func sectionHeader(_ title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(theme.accentColor)
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
        }
        .padding(.horizontal)
        .padding(.top, 4)
    }
}

// MARK: - Running Card

struct RunningCard: View {
    @Environment(ThemeManager.self) private var theme
    let session: RunningSessionType

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Image(systemName: session.runningType == .footing ? "figure.run" : "bolt.horizontal.fill")
                    .font(.title2)
                    .foregroundStyle(.primary)
                    .frame(width: 44, height: 44)
                    .background(DesignTokens.card2)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                Spacer()

                if let lastLog = session.logs.sorted(by: { $0.date > $1.date }).first {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("DERNIER")
                            .font(.caption2)
                            .foregroundStyle(DesignTokens.textSecondary)
                        Text(lastLog.durationFormatted)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(theme.accentColor)
                    }
                }
            }

            Spacer()

            VStack(alignment: .leading, spacing: 4) {
                Text(session.name)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                Text("\(session.logs.count) sessions · \(session.runningType.rawValue)")
                    .font(.caption)
                    .foregroundStyle(DesignTokens.textSecondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 150, alignment: .topLeading)
        .background(DesignTokens.card1)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

// MARK: - Activity Card

struct ActivityCard: View {
    @Environment(ThemeManager.self) private var theme
    let activity: SportActivity

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Image(systemName: activity.iconName)
                    .font(.title2)
                    .foregroundStyle(.primary)
                    .frame(width: 44, height: 44)
                    .background(DesignTokens.card2)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                Spacer()

                if let lastLog = activity.logs.sorted(by: { $0.date > $1.date }).first {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("DERNIER")
                            .font(.caption2)
                            .foregroundStyle(DesignTokens.textSecondary)
                        Text(lastLog.durationFormatted)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(theme.accentColor)
                    }
                }
            }

            Spacer()

            VStack(alignment: .leading, spacing: 4) {
                Text(activity.name)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                Text("\(activity.logs.count) sessions")
                    .font(.caption)
                    .foregroundStyle(DesignTokens.textSecondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 150, alignment: .topLeading)
        .background(DesignTokens.card1)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

// MARK: - New Item Card (reusable)

struct NewItemCard: View {
    @Environment(ThemeManager.self) private var theme
    let label: String

    var body: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "plus")
                .font(.title)
                .foregroundStyle(theme.accentColor)
            Text(label)
                .font(.subheadline)
                .foregroundStyle(DesignTokens.textSecondary)
            Spacer()
        }
        .frame(maxWidth: .infinity, minHeight: 150)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [8]))
                .foregroundStyle(DesignTokens.border)
        )
    }
}
