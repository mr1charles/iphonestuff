import SwiftUI

struct SettingsRootView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationStack {
            List {
                Section("DreamTweaks") {
                    NavigationLink("About") { AboutSettingsView() }
                    HStack { Text("Version"); Spacer(); Text(appVersionString).foregroundStyle(.secondary) }
                    HStack { Text("Device"); Spacer(); Text("iPhone 12").foregroundStyle(.secondary) }
                    Button("Reset DreamTweaks", role: .destructive) { appState.resetAll() }
                }

                Section("Dynamic Peninsula") {
                    NavigationLink("Dynamic Peninsula") { DynamicPeninsulaSettingsView() }
                }

                Section("Second Space") {
                    NavigationLink("Second Space") { SecondSpaceSettingsView() }
                }

                Section("Appearance") {
                    NavigationLink("Appearance") { AppearanceSettingsView() }
                }

                Section("Animations") {
                    NavigationLink("Animations") { AnimationSettingsView() }
                }

                Section("Privacy") {
                    NavigationLink("Privacy") { PrivacySettingsView() }
                }

                Section("Developer") {
                    NavigationLink("DreamTweaks Test Lab") { TestLabView() }
                }
            }
            .navigationTitle("Settings")
        }
    }

    private var appVersionString: String {
        let short = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(short) (\(build))"
    }
}

struct AboutSettingsView: View {
    var body: some View {
        List {
            Text("DreamTweaks is a prototype iOS customization app targeting the iPhone 12. It demonstrates Dynamic Peninsula and Second Space concepts using only public, App Store-safe APIs, with a clearly isolated architecture for optional future jailbreak integration.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .navigationTitle("About")
    }
}
