import Foundation
import SwiftData

@Model
final class UserProfile {
    var firstName: String
    var age: Int?
    var weight: Double?
    var height: Double?
    var accentColor: String
    var hasCompletedOnboarding: Bool
    var isDarkMode: Bool
    var restTimerSeconds: Int

    init(
        firstName: String = "",
        age: Int? = nil,
        weight: Double? = nil,
        height: Double? = nil,
        accentColor: String = "#E8FF00",
        hasCompletedOnboarding: Bool = false,
        isDarkMode: Bool = true,
        restTimerSeconds: Int = 90
    ) {
        self.firstName = firstName
        self.age = age
        self.weight = weight
        self.height = height
        self.accentColor = accentColor
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.isDarkMode = isDarkMode
        self.restTimerSeconds = restTimerSeconds
    }
}
