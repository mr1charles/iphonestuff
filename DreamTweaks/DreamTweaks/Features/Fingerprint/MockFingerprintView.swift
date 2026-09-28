import SwiftUI

/// The visual half of the Mock Touch Fingerprint simulation: an
/// under-display-sensor-style icon, scanning rings, and a success/failure
/// readout. Purely decorative — driven entirely by `MockFingerprintManager`
/// state, never by any real biometric signal.
struct MockFingerprintView: View {
    @ObservedObject var manager: MockFingerprintManager
    let containerSize: CGSize

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var rippleTrigger = 0
    @State private var shake = false

    private var point: CGPoint { manager.sensorPosition.point(in: containerSize) }
    private var diameter: CGFloat {
        CGFloat(manager.settings.accessibilityLargeSensor ? manager.sensorSize * 1.35 : manager.sensorSize)
    }

    var body: some View {
        ZStack {
            if manager.settings.showSensorWhenIdle || manager.stage != .idle {
                sensorBody
                    .position(point)
            }

            statusLabel
                .position(x: point.x, y: point.y - diameter / 2 - 28)
        }
        .allowsHitTesting(false)
        .onChange(of: manager.stage) { newStage in
            if newStage == .reading { rippleTrigger += 1 }
            if newStage == .failure && !reduceMotion {
                withAnimation(.default.repeatCount(3, autoreverses: true).speed(3)) {
                    shake = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { shake = false }
            }
        }
    }

    @ViewBuilder
    private var sensorBody: some View {
        ZStack {
            outline

            if manager.stage == .reading && !reduceMotion {
                scanningRings
            }

            Image(systemName: iconName)
                .font(.system(size: diameter * 0.42, weight: .medium))
                .foregroundStyle(iconColor)
                .scaleEffect(manager.stage == .contact ? 1.08 : 1.0)
        }
        .frame(width: diameter, height: diameter)
        .offset(x: shake ? -6 : 0)
        .animation(reduceMotion ? .easeInOut(duration: 0.15) : .spring(response: 0.4, dampingFraction: 0.7), value: manager.stage)
        .accessibilityHidden(true)
    }

    private var outline: some View {
        Circle()
            .strokeBorder(iconColor.opacity(manager.stage == .idle ? 0.35 : 0.9), lineWidth: 2)
            .background(Circle().fill(Color.black.opacity(manager.stage == .idle ? 0.12 : 0.35)))
            .shadow(color: iconColor.opacity(manager.stage == .idle ? 0 : 0.6), radius: manager.stage == .idle ? 0 : 14)
    }

    @ViewBuilder
    private var scanningRings: some View {
        switch manager.settings.animationStyle {
        case .ripple:
            RippleRingsView(trigger: rippleTrigger, color: iconColor)
        case .pulse:
            PulseRingView(color: iconColor)
        case .contour:
            ContourRingsView(progress: manager.scanProgress, color: iconColor)
        }
    }

    private var statusLabel: some View {
        Group {
            switch manager.stage {
            case .idle:
                EmptyView()
            case .contact:
                Text("Place finger")
            case .reading:
                VStack(spacing: 4) {
                    Text("Reading…")
                    Text("\(Int(manager.scanProgress * 100))%")
                        .font(.caption2.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
            case .success:
                Text("Fingerprint recognized")
            case .failure:
                Text("Try Again")
            }
        }
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(.primary)
        .multilineTextAlignment(.center)
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.2), value: manager.stage)
        .accessibilityLabel(accessibilityStatus)
    }

    private var accessibilityStatus: String {
        switch manager.stage {
        case .idle: return "Fingerprint simulation idle"
        case .contact: return "Place finger, simulation starting"
        case .reading: return "Reading fingerprint simulation, \(Int(manager.scanProgress * 100)) percent"
        case .success: return "Fingerprint simulation recognized"
        case .failure: return "Fingerprint simulation failed, try again"
        }
    }

    private var iconName: String {
        switch manager.stage {
        case .success: return "checkmark"
        case .failure: return "xmark"
        default: return "touchid"
        }
    }

    private var iconColor: Color {
        switch manager.stage {
        case .success: return .green
        case .failure: return .red
        case .idle: return .primary
        default: return .accentColor
        }
    }
}

private struct RippleRingsView: View {
    let trigger: Int
    let color: Color

    var body: some View {
        TimelineView(.animation) { context in
            let t = context.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 1.2) / 1.2
            ZStack {
                ring(scale: 1 + t * 0.6, opacity: 1 - t)
                ring(scale: 1 + ((t + 0.4).truncatingRemainder(dividingBy: 1.0)) * 0.6,
                     opacity: 1 - (t + 0.4).truncatingRemainder(dividingBy: 1.0))
            }
        }
    }

    private func ring(scale: CGFloat, opacity: Double) -> some View {
        Circle()
            .strokeBorder(color.opacity(opacity * 0.7), lineWidth: 2)
            .scaleEffect(scale)
    }
}

private struct PulseRingView: View {
    let color: Color
    @State private var animate = false

    var body: some View {
        Circle()
            .strokeBorder(color.opacity(0.5), lineWidth: 2)
            .scaleEffect(animate ? 1.3 : 0.9)
            .opacity(animate ? 0 : 0.8)
            .animation(.easeOut(duration: 0.9).repeatForever(autoreverses: false), value: animate)
            .onAppear { animate = true }
    }
}

private struct ContourRingsView: View {
    let progress: Double
    let color: Color

    var body: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .trim(from: 0, to: min(1, progress))
                    .stroke(color.opacity(0.8 - Double(index) * 0.2), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                    .scaleEffect(1 - CGFloat(index) * 0.12)
                    .rotationEffect(.degrees(-90))
            }
        }
    }
}
