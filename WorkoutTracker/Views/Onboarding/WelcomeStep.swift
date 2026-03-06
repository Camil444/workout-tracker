import SwiftUI

struct WelcomeStep: View {
    @Environment(ThemeManager.self) private var theme
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 80))
                .foregroundStyle(theme.accentColor)

            VStack(spacing: 8) {
                Text("Bienvenue")
                    .font(.system(size: 36, weight: .heavy))
                    .foregroundStyle(.primary)
                Text("Ton coach de progression")
                    .font(.title3)
                    .foregroundStyle(DesignTokens.textSecondary)
            }

            Spacer()

            Button {
                onNext()
            } label: {
                Text("C'est parti")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(theme.accentColor)
                    .foregroundStyle(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .padding(24)
        .background(DesignTokens.bgPrimary)
    }
}
