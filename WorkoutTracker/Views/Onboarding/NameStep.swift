import SwiftUI

struct NameStep: View {
    @Environment(ThemeManager.self) private var theme
    @Binding var firstName: String
    let onNext: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer(minLength: 120)

                VStack(spacing: 8) {
                    Text("Comment tu t'appelles ?")
                        .font(.system(size: 28, weight: .heavy))
                        .foregroundStyle(.white)
                }

                TextField("Prénom", text: $firstName)
                    .textFieldStyle(.plain)
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(DesignTokens.card2)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 40)
                    .submitLabel(.done)

                Spacer(minLength: 120)

                Button {
                    onNext()
                } label: {
                    Text("Continuer")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(canContinue ? theme.accentColor : DesignTokens.card2)
                        .foregroundStyle(canContinue ? .black : DesignTokens.textSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .disabled(!canContinue)
            }
            .padding(24)
            .frame(minHeight: UIScreen.main.bounds.height)
        }
        .scrollDismissesKeyboard(.interactively)
        .dismissKeyboardOnTap()
        .background(DesignTokens.bgPrimary)
    }

    private var canContinue: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty
    }
}
