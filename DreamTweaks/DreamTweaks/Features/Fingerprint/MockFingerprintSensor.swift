import SwiftUI

/// The invisible touch zone that behaves like a physical sensor: no
/// visible button, just a hit-testable region the rest of the screen
/// keeps working around. Overlay this on top of any screen that should
/// host the Mock Touch Fingerprint simulation.
struct MockFingerprintSensor: View {
    @ObservedObject var manager: MockFingerprintManager
    let containerSize: CGSize
    var showBoundsForDebug: Bool = false

    var body: some View {
        let point = manager.sensorPosition.point(in: containerSize)
        let diameter = manager.sensorSize

        Circle()
            .fill(showBoundsForDebug ? Color.yellow.opacity(0.25) : Color.clear)
            .overlay(
                Circle().strokeBorder(Color.yellow, lineWidth: showBoundsForDebug ? 1.5 : 0)
            )
            .contentShape(Circle())
            .frame(width: diameter, height: diameter)
            .position(point)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in manager.touchDown() }
            )
            .accessibilityLabel("Mock fingerprint sensor")
            .accessibilityHint("This is a simulation. Touching this area demonstrates a fingerprint scan; it does not read a real fingerprint.")
            .accessibilityAddTraits(.isButton)
    }
}
