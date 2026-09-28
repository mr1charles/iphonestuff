import SwiftUI

/// Lets the user drag the simulated sensor to wherever they want it on an
/// iPhone 12-shaped preview, then persists the position as a fraction of
/// the screen so it stays correct at runtime.
struct SensorPositionEditorView: View {
    @EnvironmentObject private var appState: AppState
    @State private var draftPosition: SensorPosition
    @GestureState private var dragOffset: CGSize = .zero

    private let previewAspect: CGFloat = DeviceLayout.logicalSize.width / DeviceLayout.logicalSize.height

    init() {
        _draftPosition = State(initialValue: SensorPosition.defaultPosition)
    }

    var body: some View {
        VStack(spacing: 24) {
            Text("Drag the sensor to reposition it")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            GeometryReader { proxy in
                let previewSize = CGSize(width: proxy.size.width, height: proxy.size.width / previewAspect)
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: DeviceLayout.screenCornerRadius * 0.5, style: .continuous)
                        .fill(Color.black)
                        .overlay(
                            RoundedRectangle(cornerRadius: DeviceLayout.screenCornerRadius * 0.5, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.15), lineWidth: 2)
                        )

                    Capsule()
                        .fill(Color.black)
                        .frame(width: 70, height: 12)
                        .padding(.top, 12)
                        .frame(maxWidth: .infinity)

                    let point = draftPosition.point(in: previewSize)
                    Circle()
                        .fill(Color.accentColor.opacity(0.85))
                        .overlay(Image(systemName: "touchid").foregroundStyle(.white))
                        .frame(width: 44, height: 44)
                        .position(x: point.x + dragOffset.width, y: point.y + dragOffset.height)
                        .gesture(
                            DragGesture()
                                .updating($dragOffset) { value, state, _ in
                                    state = value.translation
                                }
                                .onEnded { value in
                                    let newPoint = CGPoint(x: point.x + value.translation.width,
                                                            y: point.y + value.translation.height)
                                    draftPosition = SensorPosition(
                                        xFraction: min(max(0.08, newPoint.x / previewSize.width), 0.92),
                                        yFraction: min(max(0.08, newPoint.y / previewSize.height), 0.95)
                                    )
                                }
                        )
                }
                .frame(width: previewSize.width, height: previewSize.height)
            }
            .frame(height: 420)
            .padding(.horizontal, 40)

            Button("Reset Position") {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    draftPosition = .defaultPosition
                }
            }
            .buttonStyle(.bordered)

            Spacer()
        }
        .padding(.top, 24)
        .navigationTitle("Sensor Position")
        .onAppear { draftPosition = appState.preferences.fingerprint.position }
        .onDisappear { appState.preferences.fingerprint.position = draftPosition }
    }
}
