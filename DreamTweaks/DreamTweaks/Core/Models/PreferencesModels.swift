import Foundation

struct AppearanceSettings: Codable, Equatable {
    var mode: AppearanceMode = .automatic
    var blurIntensity: Double = 0.6
    var transparency: Double = 0.8
    var roundedCorners: Double = 22
    var animationIntensity: Double = 1.0
}

struct AnimationSettings: Codable, Equatable {
    var reduceAnimations: Bool = false
    var peninsulaAnimation: PeninsulaAnimationStyle = .spring
    var spaceSwitchAnimation: SpaceTransitionAnimation = .blurZoom
    var setupAnimation: Bool = true
    var springIntensity: Double = 0.7
}

struct PrivacySettings: Codable, Equatable {
    var faceIDUnlockSimulationEnabled: Bool = false
    var appLockEnabled: Bool = false
    var localOnlyData: Bool = true
}

/// Root, persisted DreamTweaks configuration created during onboarding
/// and editable afterward from Settings.
struct DreamTweaksPreferences: Codable, Equatable {
    var hasCompletedOnboarding: Bool = false
    var appearance: AppearanceSettings = AppearanceSettings()
    var peninsula: PeninsulaSettings = PeninsulaSettings()
    var privacy: PrivacySettings = PrivacySettings()
    var animations: AnimationSettings = AnimationSettings()
    var secondSpaceEnabled: Bool = false
    var activeSpaceID: UUID?
    var fingerprint: FingerprintSimulationSettings = FingerprintSimulationSettings()
}
