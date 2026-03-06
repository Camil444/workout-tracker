import SwiftUI

struct MainTabView: View {
    @Environment(ThemeManager.self) private var theme
    @Environment(WorkoutViewModel.self) private var viewModel

    var body: some View {
        @Bindable var vm = viewModel
        TabView(selection: $vm.selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Accueil")
                }
                .tag(0)

            LoggerView()
                .tabItem {
                    Image(systemName: "pencil.line")
                    Text("Logger")
                }
                .tag(1)

            StatsView()
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Stats")
                }
                .tag(2)

            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Paramètres")
                }
                .tag(3)
        }
        .tint(theme.accentColor)
    }
}
