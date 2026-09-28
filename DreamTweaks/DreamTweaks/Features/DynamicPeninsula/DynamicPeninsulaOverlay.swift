import SwiftUI

/// Anchors the Dynamic Peninsula to the notch's safe area. This is an
/// in-app view, not a system-wide overlay above other apps — see
/// `SystemIntegrationEngine.capability(for: .dynamicPeninsulaOverlay)`.
struct DynamicPeninsulaOverlay: View {
    @EnvironmentObject private var engine: DefaultDynamicPeninsulaEngine

    var body: some View {
        VStack {
            PeninsulaShapeView(state: engine.state, isExpanded: engine.isExpanded)
                .onTapGesture {
                    HapticsService.light()
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.78)) {
                        engine.toggle()
                    }
                }
                .onLongPressGesture(minimumDuration: 0.4) {
                    HapticsService.medium()
                    engine.handleLongPress()
                }
                .padding(.top, 11)
            Spacer()
        }
        .ignoresSafeArea(edges: .top)
        .allowsHitTesting(true)
    }
}

struct PeninsulaShapeView: View {
    let state: PeninsulaState
    let isExpanded: Bool

    private var height: CGFloat {
        isExpanded ? 132 : DeviceLayout.notchSize.height
    }

    private var width: CGFloat {
        isExpanded ? 340 : DeviceLayout.notchSize.width
    }

    var body: some View {
        RoundedRectangle(cornerRadius: isExpanded ? 32 : 18, style: .continuous)
            .fill(Color.black)
            .frame(width: width, height: height)
            .overlay(content)
            .animation(.spring(response: 0.45, dampingFraction: 0.78), value: isExpanded)
            .animation(.spring(response: 0.45, dampingFraction: 0.78), value: state)
            .shadow(color: .black.opacity(0.4), radius: 12, y: 4)
    }

    @ViewBuilder
    private var content: some View {
        if isExpanded {
            PeninsulaExpandedContent(state: state)
                .padding(.horizontal, 18)
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
        } else {
            PeninsulaCompactContent(state: state)
        }
    }
}

struct PeninsulaCompactContent: View {
    let state: PeninsulaState

    var body: some View {
        HStack(spacing: 6) {
            switch state {
            case .music(let info):
                Image(systemName: info.isPlaying ? "waveform" : "pause.fill")
                    .foregroundStyle(.white)
                    .font(.caption2)
            case .timer(let info):
                Text(info.formatted)
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(.white)
            case .charging:
                Image(systemName: "bolt.fill")
                    .foregroundStyle(.green)
                    .font(.caption2)
            case .notification:
                Circle().fill(Color.blue).frame(width: 6, height: 6)
            default:
                EmptyView()
            }
        }
    }
}

struct PeninsulaExpandedContent: View {
    let state: PeninsulaState

    var body: some View {
        Group {
            switch state {
            case .music(let info):
                MusicPeninsulaView(info: info)
            case .timer(let info):
                TimerPeninsulaView(info: info)
            case .charging(let info):
                ChargingPeninsulaView(info: info)
            case .faceID(let phase):
                FaceIDPeninsulaView(phase: phase)
            case .notification(let info):
                NotificationPeninsulaView(info: info)
            case .compact, .expanded:
                StatusPeninsulaView()
            }
        }
        .foregroundStyle(.white)
    }
}

struct StatusPeninsulaView: View {
    var body: some View {
        HStack {
            Image(systemName: "sparkles")
            Text("DreamTweaks")
                .font(.subheadline.weight(.semibold))
            Spacer()
        }
    }
}

struct MusicPeninsulaView: View {
    let info: MusicInfo

    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.2)).frame(width: 44, height: 44)
                .overlay(Image(systemName: "music.note"))
            VStack(alignment: .leading, spacing: 2) {
                Text(info.title).font(.subheadline.weight(.semibold)).lineLimit(1)
                Text(info.artist).font(.caption).foregroundStyle(.white.opacity(0.7)).lineLimit(1)
            }
            Spacer()
            HStack(spacing: 18) {
                Image(systemName: "backward.fill")
                Image(systemName: info.isPlaying ? "pause.fill" : "play.fill")
                Image(systemName: "forward.fill")
            }
            .font(.subheadline)
        }
    }
}

struct TimerPeninsulaView: View {
    let info: TimerInfo

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "timer")
                .font(.title3)
            VStack(alignment: .leading, spacing: 2) {
                Text(info.label).font(.caption).foregroundStyle(.white.opacity(0.7))
                Text(info.formatted).font(.title2.monospacedDigit().weight(.semibold))
            }
            Spacer()
        }
    }
}

struct ChargingPeninsulaView: View {
    let info: ChargingInfo

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "bolt.fill")
                .foregroundStyle(.green)
                .font(.title3)
            VStack(alignment: .leading, spacing: 2) {
                Text("Charging").font(.subheadline.weight(.semibold))
                Text("\(info.batteryPercent)%").font(.caption).foregroundStyle(.white.opacity(0.7))
            }
            Spacer()
        }
    }
}

struct NotificationPeninsulaView: View {
    let info: NotificationInfo

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "bell.fill")
            VStack(alignment: .leading, spacing: 2) {
                Text(info.appName).font(.caption.weight(.semibold))
                Text(info.message).font(.caption).foregroundStyle(.white.opacity(0.7)).lineLimit(1)
            }
            Spacer()
        }
    }
}

struct FaceIDPeninsulaView: View {
    let phase: FaceIDPhase
    @State private var pulse = false

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: iconName)
                .font(.title2)
                .foregroundStyle(iconColor)
                .scaleEffect(pulse ? 1.08 : 1.0)
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                        pulse = true
                    }
                }
            Text(label)
                .font(.subheadline.weight(.semibold))
            Spacer()
        }
    }

    private var iconName: String {
        switch phase {
        case .scanning: return "faceid"
        case .success: return "checkmark.circle.fill"
        case .failure: return "xmark.circle.fill"
        }
    }

    private var iconColor: Color {
        switch phase {
        case .scanning: return .white
        case .success: return .green
        case .failure: return .red
        }
    }

    private var label: String {
        switch phase {
        case .scanning: return "Scanning (simulation)"
        case .success: return "Recognized (simulation)"
        case .failure: return "Not recognized"
        }
    }
}
