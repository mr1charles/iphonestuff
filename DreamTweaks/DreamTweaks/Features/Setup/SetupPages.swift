import SwiftUI

struct WelcomeSetupPage: View {
    let onContinue: () -> Void
    @State private var animate = false

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            AnimatedPhoneGlyph(animate: animate)
                .frame(width: 150, height: 306)
                .onAppear {
                    withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.15)) {
                        animate = true
                    }
                }

            VStack(spacing: 10) {
                Text("Welcome to DreamTweaks")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                Text("Your iPhone. Your layout. Your experience.")
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32)

            Spacer()
            SetupContinueButton(title: "Continue", action: onContinue)
        }
    }
}

/// A simple animated glyph representing an iPhone 12 with a notch —
/// not a photo of a real device, just an illustrative shape.
struct AnimatedPhoneGlyph: View {
    let animate: Bool

    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(Color(white: 0.12))
                .overlay(
                    RoundedRectangle(cornerRadius: 34, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.15), lineWidth: 2)
                )

            Capsule()
                .fill(Color.black)
                .frame(width: animate ? 90 : 40, height: 24)
                .padding(.top, 14)
                .animation(.spring(response: 0.8, dampingFraction: 0.6), value: animate)
        }
        .scaleEffect(animate ? 1.0 : 0.85)
        .opacity(animate ? 1.0 : 0.0)
    }
}

struct AppearanceSetupPage: View {
    @Binding var mode: AppearanceMode
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Text("Appearance")
                .font(.system(size: 28, weight: .bold, design: .rounded))

            VStack(spacing: 12) {
                ForEach(AppearanceMode.allCases) { option in
                    SetupOptionRow(title: option.title, isSelected: mode == option) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { mode = option }
                    }
                }
            }
            .padding(.horizontal, 32)

            Spacer()
            SetupContinueButton(title: "Continue", action: onContinue)
        }
    }
}

struct DynamicPeninsulaSetupPage: View {
    @Binding var isEnabled: Bool
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Text("Enable Dynamic Peninsula?")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Text("Turns the iPhone 12's notch into an interactive area for status, music, timers, and notifications.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            HStack(spacing: 14) {
                SetupToggleChip(title: "On", isSelected: isEnabled) {
                    withAnimation { isEnabled = true }
                }
                SetupToggleChip(title: "Off", isSelected: !isEnabled) {
                    withAnimation { isEnabled = false }
                }
            }

            Spacer()
            SetupContinueButton(title: "Continue", action: onContinue)
        }
    }
}

struct SecondSpaceSetupPage: View {
    @Binding var isEnabled: Bool
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Text("Set up Second Space?")
                .font(.system(size: 26, weight: .bold, design: .rounded))

            Text("A simulated, sandboxed second environment inside DreamTweaks — its own notes, files, and layout. On a jailbroken device with the appropriate system-level implementation, this could later map to a real OS profile; without one, it stays a DreamTweaks-only prototype.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)

            HStack(spacing: 14) {
                SetupToggleChip(title: "On", isSelected: isEnabled) {
                    withAnimation { isEnabled = true }
                }
                SetupToggleChip(title: "Off", isSelected: !isEnabled) {
                    withAnimation { isEnabled = false }
                }
            }

            Spacer()
            SetupContinueButton(title: "Continue", action: onContinue)
        }
    }
}

struct FinishSetupPage: View {
    let onStart: () -> Void
    @State private var animate = false

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.green)
                .scaleEffect(animate ? 1 : 0.6)
                .opacity(animate ? 1 : 0)
                .onAppear {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) { animate = true }
                }

            Text("DreamTweaks is ready.")
                .font(.system(size: 26, weight: .bold, design: .rounded))

            Spacer()
            SetupContinueButton(title: "Start DreamTweaks", action: onStart)
        }
    }
}

struct SetupOptionRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                }
            }
            .padding(16)
            .background(isSelected ? Color.white.opacity(0.16) : Color.white.opacity(0.06),
                        in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

struct SetupToggleChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(width: 100, height: 48)
                .background(isSelected ? Color.white : Color.white.opacity(0.1),
                            in: Capsule())
                .foregroundStyle(isSelected ? .black : .white)
        }
        .buttonStyle(.plain)
    }
}
