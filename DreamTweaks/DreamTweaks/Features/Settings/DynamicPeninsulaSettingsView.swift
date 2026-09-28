import SwiftUI

struct DynamicPeninsulaSettingsView: View {
    @EnvironmentObject private var appState: AppState

    private var binding: Binding<PeninsulaSettings> {
        $appState.preferences.peninsula
    }

    var body: some View {
        Form {
            Section {
                Toggle("Enable Dynamic Peninsula", isOn: binding.isEnabled)
            }

            Section("Style") {
                Picker("Animation style", selection: binding.animationStyle) {
                    ForEach(PeninsulaAnimationStyle.allCases) { style in
                        Text(style.title).tag(style)
                    }
                }
                VStack(alignment: .leading) {
                    Text("Expansion speed")
                    Slider(value: binding.expansionSpeed, in: 0.2...0.9)
                }
            }

            Section("Content") {
                Toggle("Music controls", isOn: binding.showMusicControls)
                Toggle("Timer", isOn: binding.showTimer)
                Toggle("Charging indicator", isOn: binding.showChargingIndicator)
                Toggle("Activity indicator", isOn: binding.showActivityIndicator)
            }

            Section("Feel") {
                Toggle("Haptic feedback", isOn: binding.hapticFeedback)
                Toggle("Always show", isOn: binding.alwaysShow)
            }
        }
        .navigationTitle("Dynamic Peninsula")
    }
}
