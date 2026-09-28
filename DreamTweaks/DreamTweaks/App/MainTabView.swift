import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        ZStack(alignment: .top) {
            TabView {
                HomeView()
                    .tabItem { Label("Home", systemImage: "house.fill") }

                SecondSpaceView()
                    .tabItem { Label("Second Space", systemImage: "square.stack.3d.up.fill") }

                SettingsRootView()
                    .tabItem { Label("Settings", systemImage: "gearshape.fill") }
            }

            if appState.preferences.peninsula.isEnabled {
                DynamicPeninsulaOverlay()
                    .environmentObject(appState.peninsulaEngine)
            }
        }
    }
}
