import Foundation

/// The visual/interaction state of the Dynamic Peninsula.
enum PeninsulaState: Equatable {
    case compact
    case expanded
    case music(MusicInfo)
    case timer(TimerInfo)
    case charging(ChargingInfo)
    case faceID(FaceIDPhase)
    case notification(NotificationInfo)
    case fingerprint(FingerprintPeninsulaInfo)
}

struct FingerprintPeninsulaInfo: Equatable {
    enum Phase: Equatable {
        case reading
        case success
        case failure
    }

    var phase: Phase
    var progress: Double // 0...1, only meaningful while .reading
}

struct MusicInfo: Equatable {
    var title: String
    var artist: String
    var isPlaying: Bool
}

struct TimerInfo: Equatable {
    var remainingSeconds: Int
    var label: String

    var formatted: String {
        let m = remainingSeconds / 60
        let s = remainingSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}

struct ChargingInfo: Equatable {
    var isCharging: Bool
    var batteryPercent: Int
}

enum FaceIDPhase: Equatable {
    case scanning
    case success
    case failure
}

struct NotificationInfo: Equatable, Identifiable {
    var id = UUID()
    var appName: String
    var message: String
}

enum PeninsulaAnimationStyle: String, CaseIterable, Identifiable, Codable {
    case spring, smooth, snappy

    var id: String { rawValue }
    var title: String {
        switch self {
        case .spring: return "Spring"
        case .smooth: return "Smooth"
        case .snappy: return "Snappy"
        }
    }
}

struct PeninsulaSettings: Codable, Equatable {
    var isEnabled: Bool = true
    var animationStyle: PeninsulaAnimationStyle = .spring
    var expansionSpeed: Double = 0.45 // seconds
    var showMusicControls: Bool = true
    var showTimer: Bool = true
    var showChargingIndicator: Bool = true
    var showActivityIndicator: Bool = true
    var hapticFeedback: Bool = true
    var alwaysShow: Bool = true
}
