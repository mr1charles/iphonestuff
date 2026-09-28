import SwiftUI

struct AppearanceSettingsView: View {
    @EnvironmentObject private var appState: AppState

    private var binding: Binding<AppearanceSettings> {
        $appState.preferences.appearance
    }

    var body: some View {
        Form {
            Section {
                Picker("Appearance", selection: binding.mode) {
                    ForEach(AppearanceMode.allCases) { mode in
                        Text(mode.title).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section("Materials") {
                VStack(alignment: .leading) {
                    Text("Blur intensity")
                    Slider(value: binding.blurIntensity, in: 0...1)
                }
                VStack(alignment: .leading) {
                    Text("Transparency")
                    Slider(value: binding.transparency, in: 0...1)
                }
                VStack(alignment: .leading) {
                    Text("Rounded corners")
                    Slider(value: binding.roundedCorners, in: 8...36)
                }
                VStack(alignment: .leading) {
                    Text("Animation intensity")
                    Slider(value: binding.animationIntensity, in: 0...1)
                }
            }
        }
        .navigationTitle("Appearance")
    }
}
