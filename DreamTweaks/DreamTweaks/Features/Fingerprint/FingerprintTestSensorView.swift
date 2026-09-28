import SwiftUI

/// A plain screen for repeatedly testing the sensor without the Lock
/// Screen Demo framing (Settings → Mock Fingerprint → Test Sensor).
struct FingerprintTestSensorView: View {
    @EnvironmentObject private var appState: AppState
    @State var showBounds = false
    @State var showCoordinates = false
    @State private var lastTouchPoint: CGPoint?

    private var manager: MockFingerprintManager { appState.fingerprintManager }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                    .contentShape(Rectangle())
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                guard showCoordinates else { return }
                                lastTouchPoint = value.location
                            }
                    )

                VStack {
                    Text("Touch anywhere in the marked zone to test the sensor.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()

                    if showCoordinates, let point = lastTouchPoint {
                        Text("Touch: (\(Int(point.x)), \(Int(point.y)))")
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }

                MockFingerprintSensor(manager: manager, containerSize: proxy.size, showBoundsForDebug: showBounds)
                MockFingerprintView(manager: manager, containerSize: proxy.size)
            }
        }
        .navigationTitle("Test Sensor")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Toggle("Show Sensor Bounds", isOn: $showBounds)
                    Toggle("Show Touch Coordinates", isOn: $showCoordinates)
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .onDisappear { manager.reset() }
    }
}
