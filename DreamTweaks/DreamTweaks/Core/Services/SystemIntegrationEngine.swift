import Foundation

/// Describes what a given feature needs from the operating system, and
/// whether that need is met by public App Store APIs or would require a
/// jailbreak/private-API backend.
enum IntegrationCapability {
    case supportedByPublicAPI
    case requiresJailbreak(reason: String)
}

/// Abstraction over "how DreamTweaks talks to the system". The default,
/// shippable implementation (`PublicAPIIntegration`) only uses public,
/// App Store-safe APIs and simulates anything iOS does not expose. A
/// `JailbreakIntegration` stub documents where real system-level hooks
/// would plug in on a jailbroken device; it performs no exploitation and
/// invents no private APIs.
protocol SystemIntegrationEngine {
    var name: String { get }

    func capability(for feature: DreamTweaksFeature) -> IntegrationCapability
}

enum DreamTweaksFeature: String, CaseIterable {
    case dynamicPeninsulaOverlay
    case systemWideNotch
    case secondSpaceOSProfile
    case faceIDHardwareUnlock
    case musicNowPlaying
    case batteryStatus
    case hapticFeedback
    case localNotifications
}

/// The real, App Store-compatible implementation. Every DreamTweaks build
/// runs on this. It never claims access it doesn't have.
struct PublicAPIIntegration: SystemIntegrationEngine {
    let name = "Public API Integration"

    func capability(for feature: DreamTweaksFeature) -> IntegrationCapability {
        switch feature {
        case .dynamicPeninsulaOverlay:
            // Public API apps cannot draw outside their own window/app UI,
            // so the "peninsula" is an in-app view anchored to the notch's
            // safe area, not a system-wide overlay.
            return .requiresJailbreak(reason: "System-wide overlays above other apps require a SpringBoard-level tweak.")
        case .systemWideNotch:
            return .requiresJailbreak(reason: "Reshaping system chrome around the notch requires SpringBoard access.")
        case .secondSpaceOSProfile:
            return .requiresJailbreak(reason: "A true OS-level user profile that hides other apps requires MobileInstallation/SpringBoard access.")
        case .faceIDHardwareUnlock:
            return .requiresJailbreak(reason: "Apple does not expose raw Face ID enrollment/match APIs to third-party apps.")
        case .musicNowPlaying:
            return .supportedByPublicAPI
        case .batteryStatus:
            return .supportedByPublicAPI
        case .hapticFeedback:
            return .supportedByPublicAPI
        case .localNotifications:
            return .supportedByPublicAPI
        }
    }
}

/// Placeholder for a future, opt-in jailbreak backend. It intentionally
/// contains no exploit code and no private API calls — only the seam
/// where a real implementation could later be substituted in on a
/// jailbroken device. Every method here simply reports "not available".
struct JailbreakIntegration: SystemIntegrationEngine {
    let name = "Jailbreak Integration (not implemented)"

    func capability(for feature: DreamTweaksFeature) -> IntegrationCapability {
        // This scaffold never claims support it hasn't verified/implemented.
        .requiresJailbreak(reason: "Jailbreak backend is not implemented in this build.")
    }
}

enum SystemIntegration {
    /// The engine every DreamTweaks build actually ships with.
    static let active: SystemIntegrationEngine = PublicAPIIntegration()
}
