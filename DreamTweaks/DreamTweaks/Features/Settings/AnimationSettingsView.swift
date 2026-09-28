import SwiftUI

struct AnimationSettingsView: View {
    @EnvironmentObject private var appState: AppState

    private var binding: Binding<AnimationSettings> {
        $appState.preferences.animations
    }

    var body: some View {
        Form {
            Toggle("Reduce animations", isOn: binding.reduceAnimations)

            Picker("Peninsula animation", selection: binding.peninsulaAnimation) {
                ForEach(PeninsulaAnimationStyle.allCases) { style in
                    Text(style.title).tag(style)
                }
            }

            Picker("Space-switch animation", selection: binding.spaceSwitchAnimation) {
                ForEach(SpaceTransitionAnimation.allCases) { style in
                    Text(style.title).tag(style)
                }
            }

            Toggle("Setup animation", isOn: binding.setupAnimation)

            VStack(alignment: .leading) {
                Text("Spring intensity")
                Slider(value: binding.springIntensity, in: 0...1)
            }
        }
        .navigationTitle("Animations")
    }
}
