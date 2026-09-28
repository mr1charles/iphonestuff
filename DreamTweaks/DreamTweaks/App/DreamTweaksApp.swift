import SwiftUI

@main
struct DreamTweaksApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .preferredColorScheme(appState.resolvedColorScheme)
        }
    }
}

struct RootView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        Group {
            if appState.preferences.hasCompletedOnboarding {
                MainTabView()
            } else {
                SetupFlowView()
            }
        }
        .animation(.easeInOut(duration: 0.35), value: appState.preferences.hasCompletedOnboarding)
    }
}
