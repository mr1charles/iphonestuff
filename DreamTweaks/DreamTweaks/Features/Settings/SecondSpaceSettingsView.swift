import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct SecondSpaceSettingsView: View {
    @EnvironmentObject private var appState: AppState
    @State private var showingCreateSheet = false

    var body: some View {
        Form {
            Section {
                Toggle("Enable Second Space", isOn: $appState.preferences.secondSpaceEnabled)
            }

            if appState.preferences.secondSpaceEnabled {
                Section("Spaces") {
                    ForEach(appState.secondSpaceEngine.spaces) { space in
                        HStack {
                            Text(space.name)
                            Spacer()
                            if space.id == appState.secondSpaceEngine.activeSpaceID {
                                Text("Active").foregroundStyle(.secondary)
                            } else {
                                Button("Switch") {
                                    appState.secondSpaceEngine.switchToSpace(id: space.id)
                                }
                            }
                        }
                    }
                    .onDelete { offsets in
                        for index in offsets {
                            appState.secondSpaceEngine.deleteSpace(id: appState.secondSpaceEngine.spaces[index].id)
                        }
                    }

                    Button("Create Space") { showingCreateSheet = true }
                }

                Section("Active space appearance") {
                    ColorPicker("Space wallpaper", selection: Binding(
                        get: { Color(hex: appState.secondSpaceEngine.activeSpace.wallpaperColorHex) },
                        set: { newColor in
                            appState.secondSpaceEngine.updateActiveSpace { $0.wallpaperColorHex = newColor.hexString }
                        }
                    ))

                    TextField("Space name", text: Binding(
                        get: { appState.secondSpaceEngine.activeSpace.name },
                        set: { newName in
                            appState.secondSpaceEngine.updateActiveSpace { $0.name = newName }
                        }
                    ))

                    Picker("Transition animation", selection: Binding(
                        get: { appState.secondSpaceEngine.activeSpace.transitionAnimation },
                        set: { newValue in
                            appState.secondSpaceEngine.updateActiveSpace { $0.transitionAnimation = newValue }
                        }
                    )) {
                        ForEach(SpaceTransitionAnimation.allCases) { animation in
                            Text(animation.title).tag(animation)
                        }
                    }
                }
            }
        }
        .navigationTitle("Second Space")
        .sheet(isPresented: $showingCreateSheet) {
            CreateSpaceSheet { name in
                appState.secondSpaceEngine.createSpace(named: name)
            }
        }
    }
}

extension Color {
    var hexString: String {
        #if canImport(UIKit)
        let uiColor = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
        #else
        return "1C1C1E"
        #endif
    }
}
