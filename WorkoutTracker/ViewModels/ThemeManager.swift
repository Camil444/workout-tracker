import SwiftUI
import SwiftData

@Observable
final class ThemeManager {
    var accentHex: String = "#E8FF00"

    var accentColor: Color {
        Color(hex: accentHex)
    }

    static let availableColors: [(name: String, hex: String)] = [
        ("Fluo", "#E8FF00"),
        ("Bleu", "#007AFF"),
        ("Rouge", "#FF3B30"),
        ("Orange", "#FF9500"),
        ("Violet", "#AF52DE"),
        ("Rose", "#FF2D55"),
        ("Vert", "#34C759"),
        ("Blanc", "#FFFFFF"),
    ]
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)

        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}
