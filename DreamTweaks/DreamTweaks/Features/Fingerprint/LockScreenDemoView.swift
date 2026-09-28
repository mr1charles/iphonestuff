import SwiftUI

/// An in-app, DreamTweaks-only demonstration of what an under-display
/// fingerprint sensor could feel like. This is **not** a replacement for,
/// or a way to bypass, the real iOS Lock Screen, Face ID, or the device
/// passcode — it only controls DreamTweaks' own simulated UI and, if
/// configured, which DreamTweaks Second Space is shown afterward.
struct LockScreenDemoView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var unlocked = false
    @State private var now = Date()

    private let clock = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var manager: MockFingerprintManager { appState.fingerprintManager }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                LinearGradient(colors: [Color.black, Color(white: 0.06)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                VStack(spacing: 10) {
                    Spacer().frame(height: proxy.size.height * 0.14)

                    Text(now, style: .time)
                        .font(.system(size: 76, weight: .thin, design: .rounded))
                        .foregroundStyle(.white)
                        .monospacedDigit()

                    Text(now, style: .date)
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.7))

                    Spacer()

                    Text("DreamTweaks Lock Screen Demo")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.5))
                    Text("In-app simulation only — does not replace or bypass Face ID, your passcode, or the real iOS Lock Screen.")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.4))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 8)

                    Text(unlocked ? "Unlocked" : "Touch the sensor below to unlock (simulation)")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white.opacity(0.85))
                        .padding(.bottom, manager.sensorSize + 70)
                }
                .frame(maxWidth: .infinity)

                MockFingerprintSensor(manager: manager, containerSize: proxy.size)
                MockFingerprintView(manager: manager, containerSize: proxy.size)

                if unlocked {
                    UnlockSuccessOverlay()
                        .transition(.opacity)
                }

                VStack {
                    HStack {
                        Spacer()
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.white.opacity(0.6))
                        }
                        .padding()
                    }
                    Spacer()
                }
            }
        }
        .onReceive(clock) { now = $0 }
        .onReceive(manager.$stage) { stage in
            if stage == .success {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    unlocked = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    dismiss()
                }
            }
        }
        .statusBarHidden(true)
        .onDisappear { manager.reset() }
    }
}

struct UnlockSuccessOverlay: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "lock.open.fill")
                .font(.system(size: 40))
                .foregroundStyle(.green)
            Text("Unlock animation (simulation)")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))
        }
    }
}
