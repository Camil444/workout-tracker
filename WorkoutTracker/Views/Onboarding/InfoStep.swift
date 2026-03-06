import SwiftUI

struct InfoStep: View {
    @Environment(ThemeManager.self) private var theme

    @Binding var age: String
    @Binding var weight: String
    @Binding var height: String

    let onNext: () -> Void
    let onSkip: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer(minLength: 100)

                VStack(spacing: 8) {
                    Text("Quelques infos sur toi")
                        .font(.system(size: 28, weight: .heavy))
                        .foregroundStyle(.primary)
                    Text("Ces informations sont optionnelles")
                        .font(.subheadline)
                        .foregroundStyle(DesignTokens.textSecondary)
                }

                VStack(spacing: 16) {
                    InfoField(label: "Âge", placeholder: "25", text: $age, suffix: "ans")
                    InfoField(label: "Poids", placeholder: "75", text: $weight, suffix: "kg")
                    InfoField(label: "Taille", placeholder: "178", text: $height, suffix: "cm")
                }
                .padding(.horizontal, 20)

                Spacer(minLength: 100)

                VStack(spacing: 12) {
                    Button {
                        onNext()
                    } label: {
                        Text("Continuer")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(theme.accentColor)
                            .foregroundStyle(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }

                    Button {
                        onSkip()
                    } label: {
                        Text("Passer")
                            .foregroundStyle(DesignTokens.textSecondary)
                    }
                }
            }
            .padding(24)
            .frame(minHeight: UIScreen.main.bounds.height)
        }
        .scrollDismissesKeyboard(.interactively)
        .dismissKeyboardOnTap()
        .background(DesignTokens.bgPrimary)
    }
}

private struct InfoField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    let suffix: String

    var body: some View {
        HStack {
            Text(label)
                .fontWeight(.semibold)
                .foregroundStyle(DesignTokens.textSecondary)
                .frame(width: 60, alignment: .leading)
            TextField(placeholder, text: $text)
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
}
