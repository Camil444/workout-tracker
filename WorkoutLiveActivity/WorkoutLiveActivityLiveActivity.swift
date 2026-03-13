import ActivityKit
import WidgetKit
import SwiftUI

struct WorkoutLiveActivityLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WorkoutActivityAttributes.self) { context in
            // Lock screen / banner UI
            lockScreenView(context: context)
                .activityBackgroundTint(Color.black)
                .activitySystemActionForegroundColor(Color.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("SEANCE")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                        Text(context.attributes.sessionStartDate, style: .timer)
                            .font(.title3)
                            .fontWeight(.bold)
                            .monospacedDigit()
                            .foregroundStyle(.white)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 2) {
                        if context.state.isRestTimerRunning, let endDate = context.state.restTimerEndDate {
                            Text("REPOS")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundStyle(.secondary)
                            Text(timerInterval: Date.now...endDate, countsDown: true)
                                .font(.title3)
                                .fontWeight(.bold)
                                .monospacedDigit()
                                .foregroundStyle(Color(red: 0.91, green: 1.0, blue: 0.0))
                        } else {
                            Text("\(context.state.exerciseCount) exos")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    if !context.state.isRestTimerRunning {
                        HStack(spacing: 12) {
                            Link(destination: URL(string: "workouttracker://rest?seconds=60")!) {
                                Text("60s")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(Color.white.opacity(0.15))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            Link(destination: URL(string: "workouttracker://rest?seconds=90")!) {
                                Text("90s")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(Color(red: 0.91, green: 1.0, blue: 0.0).opacity(0.3))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            Link(destination: URL(string: "workouttracker://rest?seconds=120")!) {
                                Text("2min")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(Color.white.opacity(0.15))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                        .foregroundStyle(.white)
                    } else {
                        HStack {
                            Image(systemName: "timer")
                                .foregroundStyle(Color(red: 0.91, green: 1.0, blue: 0.0))
                            Text("Repos en cours...")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Link(destination: URL(string: "workouttracker://stoprest")!) {
                                Text("Stop")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.red.opacity(0.3))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                }
            } compactLeading: {
                Image(systemName: "dumbbell.fill")
                    .foregroundStyle(Color(red: 0.91, green: 1.0, blue: 0.0))
            } compactTrailing: {
                if context.state.isRestTimerRunning, let endDate = context.state.restTimerEndDate {
                    Text(timerInterval: Date.now...endDate, countsDown: true)
                        .monospacedDigit()
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(Color(red: 0.91, green: 1.0, blue: 0.0))
                        .frame(width: 40)
                } else {
                    Text(context.attributes.sessionStartDate, style: .timer)
                        .monospacedDigit()
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(width: 46)
                }
            } minimal: {
                Image(systemName: "dumbbell.fill")
                    .foregroundStyle(Color(red: 0.91, green: 1.0, blue: 0.0))
            }
            .widgetURL(URL(string: "workouttracker://open"))
        }
    }

    @ViewBuilder
    private func lockScreenView(context: ActivityViewContext<WorkoutActivityAttributes>) -> some View {
        HStack(spacing: 16) {
            // Session timer
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: "dumbbell.fill")
                        .font(.caption2)
                    Text("Seance")
                        .font(.caption2)
                        .fontWeight(.bold)
                }
                .foregroundStyle(.secondary)
                Text(context.attributes.sessionStartDate, style: .timer)
                    .font(.title2)
                    .fontWeight(.bold)
                    .monospacedDigit()
                    .foregroundStyle(.white)
            }

            Spacer()

            // Rest timer or exercise count
            if context.state.isRestTimerRunning, let endDate = context.state.restTimerEndDate {
                VStack(alignment: .trailing, spacing: 2) {
                    HStack(spacing: 4) {
                        Image(systemName: "timer")
                            .font(.caption2)
                        Text("Repos")
                            .font(.caption2)
                            .fontWeight(.bold)
                    }
                    .foregroundStyle(Color(red: 0.91, green: 1.0, blue: 0.0))
                    Text(timerInterval: Date.now...endDate, countsDown: true)
                        .font(.title2)
                        .fontWeight(.bold)
                        .monospacedDigit()
                        .foregroundStyle(Color(red: 0.91, green: 1.0, blue: 0.0))
                }
            } else {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(context.state.exerciseCount) exercices")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Link(destination: URL(string: "workouttracker://rest?seconds=90")!) {
                        HStack(spacing: 4) {
                            Image(systemName: "timer")
                            Text("Repos 90s")
                        }
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(red: 0.91, green: 1.0, blue: 0.0))
                        .foregroundStyle(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
        }
        .padding(16)
    }
}
