import SwiftUI

extension View {
    func cardStyle(cornerRadius: CGFloat = 20, backgroundColor: Color = Color(hex: "#1A1A1A")) -> some View {
        self
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

struct DesignTokens {
    static let bgPrimary = Color.black
    static let card1 = Color(hex: "#1A1A1A")
    static let card2 = Color(hex: "#2A2A2A")
    static let textPrimary = Color.white
    static let textSecondary = Color(hex: "#888888")
    static let border = Color(hex: "#333333")
    static let destructive = Color(hex: "#FF4444")
}
