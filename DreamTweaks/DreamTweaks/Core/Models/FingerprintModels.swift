import Foundation
import CoreGraphics

/// Everything here is a **visual/interaction simulation**. Nothing in this
/// file (or anywhere in the Mock Touch Fingerprint feature) reads, stores,
/// or evaluates a real fingerprint, and none of it touches Face ID, Touch
/// ID, or the iOS passcode. See `SystemIntegrationEngine` for the same
/// honesty pattern used elsewhere in DreamTweaks.

enum FingerprintScanStage: Equatable {
    case idle
    case contact          // "Place finger"
    case reading          // "Reading..."
    case success          // "Fingerprint recognized"
    case failure          // "Try Again"
}

enum FingerprintResultMode: String, CaseIterable, Identifiable, Codable {
    case alwaysSucceed, random, alwaysFail

    var id: String { rawValue }

    var title: String {
        switch self {
        case .alwaysSucceed: return "Always Succeed"
        case .random: return "Random Result"
        case .alwaysFail: return "Always Fail"
        }
    }
}

enum FingerprintAnimationStyle: String, CaseIterable, Identifiable, Codable {
    case ripple, pulse, contour

    var id: String { rawValue }

    var title: String {
        switch self {
        case .ripple: return "Ripple"
        case .pulse: return "Pulse"
        case .contour: return "Contour"
        }
    }
}

/// A relative position for the sensor, stored as a 0...1 fraction of the
/// screen so it stays correct across orientations/device sizes.
struct SensorPosition: Codable, Equatable {
    var xFraction: Double = 0.5
    var yFraction: Double = 0.88 // bottom-center, iPhone 12-appropriate default

    static let defaultPosition = SensorPosition()

    func point(in size: CGSize) -> CGPoint {
        CGPoint(x: size.width * xFraction, y: size.height * yFraction)
    }
}

struct FingerprintSimulationSettings: Codable, Equatable {
    var isEnabled: Bool = true
    var showSensorWhenIdle: Bool = true
    var position: SensorPosition = .defaultPosition
    var diameter: Double = 84
    var animationStyle: FingerprintAnimationStyle = .ripple
    var scanDurationSeconds: Double = 1.6
    var hapticFeedback: Bool = true
    var showSuccessAnimation: Bool = true
    var resultMode: FingerprintResultMode = .alwaysSucceed
    var accessibilityLargeSensor: Bool = false

    /// Which space touching the sensor unlocks into, from the Lock Screen
    /// Demo. `nil` means "stay on the currently active space".
    var unlockTargetSpaceID: UUID?
}
