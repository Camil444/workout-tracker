import SwiftUI

struct RestTimerView: View {
    @Environment(ThemeManager.self) private var theme
    @Environment(WorkoutViewModel.self) private var viewModel

    let defaultSeconds: Int

    private let presets = [30, 60, 90, 120, 180]

    var body: some View {
        VStack(spacing: 12) {
            if viewModel.isRestTimerRunning {
                // Active timer
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .stroke(DesignTokens.card2, lineWidth: 6)
                            .frame(width: 80, height: 80)
                        Circle()
                            .trim(from: 0, to: viewModel.restTimerProgress)
                            .stroke(theme.accentColor, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                            .frame(width: 80, height: 80)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 1), value: viewModel.restTimerProgress)

                        VStack(spacing: 0) {
                            Text(timerString(viewModel.restTimerRemaining))
                                .font(.system(size: 22, weight: .heavy, design: .monospaced))
                                .foregroundStyle(viewModel.restTimerRemaining <= 5 ? DesignTokens.destructive : .primary)
                        }
                    }

                    Button {
                        viewModel.stopRestTimer()
                    } label: {
                        Text("Passer")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(DesignTokens.textSecondary)
                    }
                }
                .padding()
                .background(DesignTokens.card1)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                // Timer presets
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "timer")
                            .font(.caption)
                            .foregroundStyle(theme.accentColor)
                        Text("Repos")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                    }

                    HStack(spacing: 6) {
                        ForEach(presets, id: \.self) { seconds in
                            Button {
                                viewModel.startRestTimer(seconds: seconds)
                            } label: {
                                Text(timerLabel(seconds))
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 8)
                                    .background(seconds == defaultSeconds ? theme.accentColor : DesignTokens.card2)
                                    .foregroundStyle(seconds == defaultSeconds ? .black : .primary)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                }
                .padding(12)
                .background(DesignTokens.card1)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private func timerString(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }

    private func timerLabel(_ seconds: Int) -> String {
        if seconds < 60 {
            return "\(seconds)s"
        } else if seconds % 60 == 0 {
            return "\(seconds / 60)min"
        }
        return "\(seconds / 60)m\(seconds % 60)"
    }
}
