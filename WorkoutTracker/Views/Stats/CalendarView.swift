import SwiftUI
import SwiftData

struct ActivityCalendarView: View {
    @Environment(ThemeManager.self) private var theme
    @Query private var exerciseLogs: [ExerciseLog]
    @Query private var runningLogs: [RunningLog]
    @Query private var sportLogs: [SportActivityLog]
    @Query private var profiles: [UserProfile]

    @State private var displayedMonth = Date()
    @State private var selectedDate: Date?
    @State private var showDayDetail = false

    private var calendar: Calendar { Calendar.current }
    private var userWeight: Double { profiles.first?.weight ?? 70 }

    private var activityByDay: [String: [DayActivity]] {
        var result: [String: [DayActivity]] = [:]

        for log in exerciseLogs {
            let key = dayKey(log.date)
            let name = log.exercise?.workout?.name ?? "Musculation"
            let icon = log.exercise?.workout?.iconName ?? "dumbbell.fill"
            result[key, default: []].append(DayActivity(type: .musculation, name: name, icon: icon, date: log.date))
        }

        for log in runningLogs {
            let key = dayKey(log.date)
            let name = log.sessionType?.name ?? "Course"
            let calories = log.sessionType?.runningType == .interval
                ? CalorieData.intervalCalories(durationMinutes: log.durationMinutes, weightKg: userWeight)
                : CalorieData.runningCalories(durationMinutes: log.durationMinutes, distanceKm: log.distanceKm, weightKg: userWeight)
            result[key, default: []].append(DayActivity(
                type: .running, name: name, icon: "figure.run", date: log.date,
                detail: "\(log.durationFormatted) · \(String(format: "%.1f", log.distanceKm))km",
                calories: calories
            ))
        }

        for log in sportLogs {
            let key = dayKey(log.date)
            let name = log.activity?.name ?? "Activite"
            let icon = log.activity?.iconName ?? "figure.mixed.cardio"
            let calories = CalorieData.sportCalories(activityName: name, durationMinutes: log.durationMinutes, weightKg: userWeight)
            result[key, default: []].append(DayActivity(
                type: .sport, name: name, icon: icon, date: log.date,
                detail: log.durationFormatted,
                calories: calories
            ))
        }

        // Deduplicate musculation entries per workout per day & estimate calories
        for (key, activities) in result {
            var seen = Set<String>()
            var deduped: [DayActivity] = []
            for a in activities {
                if a.type == .musculation {
                    let id = "\(a.type)-\(a.name)"
                    if seen.contains(id) { continue }
                    seen.insert(id)
                    // Estimate ~60min session for musculation
                    let cal = CalorieData.musculationCalories(workoutName: a.name, durationMinutes: 60, weightKg: userWeight)
                    var modified = a
                    modified.calories = cal
                    deduped.append(modified)
                } else {
                    deduped.append(a)
                }
            }
            result[key] = deduped
        }

        return result
    }

    var body: some View {
        VStack(spacing: 16) {
            // Month navigation
            HStack {
                Button {
                    withAnimation { changeMonth(by: -1) }
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.primary)
                }
                Spacer()
                Text(monthYearString)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                Spacer()
                Button {
                    withAnimation { changeMonth(by: 1) }
                } label: {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.primary)
                }
            }
            .padding(.horizontal)

            // Day of week headers
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(["L", "M", "M", "J", "V", "S", "D"], id: \.self) { day in
                    Text(day)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(DesignTokens.textSecondary)
                }
            }
            .padding(.horizontal)

            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 6) {
                ForEach(daysInMonth, id: \.self) { date in
                    if let date {
                        let key = dayKey(date)
                        let count = activityByDay[key]?.count ?? 0
                        let isToday = calendar.isDateInToday(date)
                        let isSelected = selectedDate.map { calendar.isDate($0, inSameDayAs: date) } ?? false

                        Button {
                            if count > 0 {
                                selectedDate = date
                                showDayDetail = true
                            }
                        } label: {
                            VStack(spacing: 2) {
                                Text("\(calendar.component(.day, from: date))")
                                    .font(.subheadline)
                                    .fontWeight(isToday ? .bold : .regular)
                                    .foregroundStyle(
                                        isSelected ? .black :
                                        count > 0 ? .white :
                                        DesignTokens.textSecondary
                                    )

                                if count > 1 {
                                    Text("x\(count)")
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundStyle(isSelected ? .black : theme.accentColor)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 42)
                            .background(
                                count > 0
                                    ? (isSelected ? theme.accentColor : theme.accentColor.opacity(intensityForCount(count)))
                                    : (isToday ? DesignTokens.card2 : Color.clear)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(.plain)
                    } else {
                        Color.clear
                            .frame(height: 42)
                    }
                }
            }
            .padding(.horizontal)

            // Day detail with calories
            if showDayDetail, let selectedDate,
               let activities = activityByDay[dayKey(selectedDate)], !activities.isEmpty {
                let totalCal = activities.compactMap(\.calories).reduce(0, +)
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(dayDetailTitle(selectedDate))
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                        Spacer()
                        if totalCal > 0 {
                            HStack(spacing: 4) {
                                Image(systemName: "flame.fill")
                                    .font(.caption2)
                                    .foregroundStyle(.orange)
                                Text("~\(CalorieData.formatCalories(totalCal)) kcal")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.orange)
                            }
                        }
                        Button {
                            self.showDayDetail = false
                            self.selectedDate = nil
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(DesignTokens.textSecondary)
                        }
                    }

                    ForEach(activities) { activity in
                        HStack(spacing: 10) {
                            Image(systemName: activity.icon)
                                .font(.caption)
                                .foregroundStyle(theme.accentColor)
                                .frame(width: 24)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(activity.name)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.primary)
                                HStack(spacing: 8) {
                                    if let detail = activity.detail {
                                        Text(detail)
                                            .font(.caption)
                                            .foregroundStyle(DesignTokens.textSecondary)
                                    }
                                    if let cal = activity.calories, cal > 0 {
                                        Text("~\(Int(cal)) kcal")
                                            .font(.caption)
                                            .foregroundStyle(.orange)
                                    }
                                }
                            }
                            Spacer()
                            Text(activity.type.label)
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(DesignTokens.card2)
                                .foregroundStyle(DesignTokens.textSecondary)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                        .padding(10)
                        .background(DesignTokens.card1)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding()
                .background(DesignTokens.card1)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
    }

    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: displayedMonth).capitalized
    }

    private func dayDetailTitle(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = "EEEE d MMMM"
        return formatter.string(from: date).capitalized
    }

    private func changeMonth(by value: Int) {
        displayedMonth = calendar.date(byAdding: .month, value: value, to: displayedMonth) ?? displayedMonth
        selectedDate = nil
        showDayDetail = false
    }

    private var daysInMonth: [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: displayedMonth),
              let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth)) else {
            return []
        }

        var weekday = calendar.component(.weekday, from: firstDay)
        weekday = (weekday + 5) % 7

        var days: [Date?] = Array(repeating: nil, count: weekday)
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                days.append(date)
            }
        }
        return days
    }

    private func dayKey(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    private func intensityForCount(_ count: Int) -> Double {
        switch count {
        case 0: return 0
        case 1: return 0.25
        case 2: return 0.45
        case 3: return 0.65
        default: return 0.85
        }
    }
}

struct DayActivity: Identifiable {
    let id = UUID()
    let type: ActivityType
    let name: String
    let icon: String
    let date: Date
    var detail: String?
    var calories: Double?

    enum ActivityType {
        case musculation, running, sport

        var label: String {
            switch self {
            case .musculation: return "Muscu"
            case .running: return "Course"
            case .sport: return "Sport"
            }
        }
    }
}
