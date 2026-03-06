import SwiftUI

struct AccentColorPicker: View {
    @Environment(ThemeManager.self) private var theme
    let profile: UserProfile

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 4)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(ThemeManager.availableColors, id: \.hex) { color in
                Button {
                    profile.accentColor = color.hex
                    theme.accentHex = color.hex
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color(hex: color.hex))
                            .frame(width: 44, height: 44)
                        if profile.accentColor == color.hex {
                            Image(systemName: "checkmark")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundStyle(color.hex == "#FFFFFF" ? .black : .black)
                        }
                    }
                }
            }
        }
    }
}
