import SwiftUI

/// Developer preview mode: exercises the whole prototype without needing
/// real system integrations, exactly as the spec's "Test Mode" asks for.
struct TestLabView: View {
    @EnvironmentObject private var appState: AppState

    private var events: SimulatedSystemEventService { appState.eventService }
    private var peninsula: DefaultDynamicPeninsulaEngine { appState.peninsulaEngine }
    private var spaces: DefaultSecondSpaceEngine { appState.secondSpaceEngine }

    var body: some View {
        List {
            Section("Dynamic Peninsula") {
                Button("Test compact state") { peninsula.resetToCompact() }
                Button("Test expanded state") {
                    withAnimation { peninsula.expand() }
                }
                Button("Test collapsed state") {
                    withAnimation { peninsula.collapse() }
                }
                Button("Test music state") {
                    withAnimation { peninsula.expand() }
                    events.emit(.musicStarted(title: "Midnight Drive", artist: "DreamTweaks Radio"))
                }
                Button("Test timer") {
                    withAnimation { peninsula.expand() }
                    events.startDemoTimer(seconds: 12 * 60 + 42, label: "Focus")
                }
                Button("Test charging") {
                    withAnimation { peninsula.expand() }
                    events.emit(.chargingStarted(percent: 62))
                }
                Button("Test notification") {
                    withAnimation { peninsula.expand() }
                    events.emit(.notificationReceived(appName: "DreamTweaks", message: "This is a test notification"))
                }
                Button("Test Face ID animation") {
                    peninsula.handleLongPress()
                }
            }

            Section("Fingerprint Sensor") {
                Button("Test Touch Detection") { appState.fingerprintManager.touchDown() }
                Button("Start Scan") { appState.fingerprintManager.startScan() }
                Button("Force Success") { appState.fingerprintManager.forceSuccess() }
                Button("Force Failure") { appState.fingerprintManager.forceFailure() }
                Button("Test Haptic") { HapticsService.success() }
                NavigationLink("Show Touch Coordinates") {
                    FingerprintTestSensorView(showCoordinates: true)
                }
                NavigationLink("Show Sensor Bounds") {
                    FingerprintTestSensorView(showBounds: true)
                }
                Button("Reset Sensor", role: .destructive) { appState.fingerprintManager.reset() }
            }

            Section("Second Space") {
                Button("Test Second Space") {
                    if spaces.spaces.count < 2 {
                        spaces.createSpace(named: "Test Space")
                    }
                }
                Button("Test Space transition") {
                    if let target = spaces.spaces.first(where: { $0.id != spaces.activeSpaceID }) {
                        spaces.switchToSpace(id: target.id)
                    }
                }
            }

            Section("Reset") {
                Button("Reset demo state", role: .destructive) {
                    peninsula.resetToCompact()
                    events.stopDemoTimer()
                }
            }
        }
        .navigationTitle("DreamTweaks Test Lab")
    }
}
