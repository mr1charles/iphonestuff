import SwiftUI

struct PrivacySettingsView: View {
    @EnvironmentObject private var appState: AppState

    private var binding: Binding<PrivacySettings> {
        $appState.preferences.privacy
    }

    var body: some View {
        Form {
            Section {
                Toggle("Face ID-style unlock simulation", isOn: binding.faceIDUnlockSimulationEnabled)
                Toggle("App lock inside DreamTweaks", isOn: binding.appLockEnabled)
            } footer: {
                Text("This simulates a Face ID-style unlock animation for the prototype. It does not use, replace, or grant access to Apple's actual Face ID security.")
            }

            Section {
                Toggle("Local-only data", isOn: binding.localOnlyData)
            } footer: {
                Text("DreamTweaks stores all preferences, spaces, and notes on-device only.")
            }

            Section {
                Button("Clear DreamTweaks data", role: .destructive) {
                    appState.resetAll()
                }
            }
        }
        .navigationTitle("Privacy")
    }
}
