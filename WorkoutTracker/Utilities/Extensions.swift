import SwiftUI

extension View {
    func cardStyle(cornerRadius: CGFloat = 20, backgroundColor: Color = DesignTokens.card1) -> some View {
        self
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }

    func dismissKeyboardOnTap() -> some View {
        self.onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

struct DesignTokens {
    static let bgPrimary = Color(.systemBackground)
    static let card1 = Color(.secondarySystemBackground)
    static let card2 = Color(.tertiarySystemBackground)
    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary
    static let border = Color(.separator)
    static let destructive = Color(hex: "#FF4444")
}
