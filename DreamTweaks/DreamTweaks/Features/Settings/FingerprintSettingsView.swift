import SwiftUI

struct FingerprintSettingsView: View {
    @EnvironmentObject private var appState: AppState

    private var binding: Binding<FingerprintSimulationSettings> {
        $appState.preferences.fingerprint
    }

    var body: some View {
        Form {
            Section {
                Toggle("Enable Mock Fingerprint", isOn: binding.isEnabled)
                Toggle("Show Sensor", isOn: binding.showSensorWhenIdle)
            } footer: {
                Text("Mock Fingerprint Sensor — a touch-triggered visual simulation. It does not read, store, or authenticate a real fingerprint.")
            }

            Section("Sensor") {
                NavigationLink("Sensor Position") { SensorPositionEditorView() }
                VStack(alignment: .leading) {
                    Text("Sensor Size")
                    Slider(value: binding.diameter, in: 56...140, step: 2)
                }
                Toggle("Larger sensor (Accessibility)", isOn: binding.accessibilityLargeSensor)
            }

            Section("Scan") {
                Picker("Scan Animation", selection: binding.animationStyle) {
                    ForEach(FingerprintAnimationStyle.allCases) { style in
                        Text(style.title).tag(style)
                    }
                }
                VStack(alignment: .leading) {
                    Text("Scan Duration")
                    Slider(value: binding.scanDurationSeconds, in: 0.6...3.0, step: 0.1)
                }
                Toggle("Haptic Feedback", isOn: binding.hapticFeedback)
                Toggle("Success Animation", isOn: binding.showSuccessAnimation)
            }

            Section("Failure Simulation") {
                Picker("Result", selection: binding.resultMode) {
                    ForEach(FingerprintResultMode.allCases) { mode in
                        Text(mode.title).tag(mode)
                    }
                }
                .pickerStyle(.inline)
            }

            Section("Second Space") {
                Picker("Unlock target", selection: Binding(
                    get: { appState.preferences.fingerprint.unlockTargetSpaceID },
                    set: { appState.preferences.fingerprint.unlockTargetSpaceID = $0 }
                )) {
                    Text("Stay on current space").tag(UUID?.none)
                    ForEach(appState.secondSpaceEngine.spaces) { space in
                        Text(space.name).tag(Optional(space.id))
                    }
                }
            } footer: {
                Text("If set, a successful simulated scan in the Lock Screen Demo switches DreamTweaks to this space. This never affects the real iOS Lock Screen.")
            }

            Section {
                NavigationLink("Test Sensor") { FingerprintTestSensorView() }
                NavigationLink("Lock Screen Demo") { LockScreenDemoView() }
            }
        }
        .navigationTitle("Mock Fingerprint")
    }
}
