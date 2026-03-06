import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) private var theme

    @State private var step = 0
    @State private var firstName = ""
    @State private var age = ""
    @State private var weight = ""
    @State private var height = ""

    let profile: UserProfile

    var body: some View {
        TabView(selection: $step) {
            WelcomeStep { withAnimation { step = 1 } }
                .tag(0)

            NameStep(firstName: $firstName) { withAnimation { step = 2 } }
                .tag(1)

            InfoStep(age: $age, weight: $weight, height: $height,
                     onNext: { withAnimation { step = 3 } },
                     onSkip: { withAnimation { step = 3 } })
                .tag(2)

            FirstWorkoutStep { _ in completeOnboarding() }
                .tag(3)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .animation(.easeInOut, value: step)
        .ignoresSafeArea()
    }

    private func completeOnboarding() {
        profile.firstName = firstName.trimmingCharacters(in: .whitespaces)
        if let ageVal = Int(age) { profile.age = ageVal }
        if let weightVal = Double(weight) { profile.weight = weightVal }
        if let heightVal = Double(height) { profile.height = heightVal }
        profile.hasCompletedOnboarding = true
    }
}
