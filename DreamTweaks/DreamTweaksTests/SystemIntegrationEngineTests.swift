import XCTest
@testable import DreamTweaks

final class SystemIntegrationEngineTests: XCTestCase {
    func testPublicAPIIntegrationNeverClaimsJailbreakOnlyFeaturesWork() {
        let engine = PublicAPIIntegration()

        for feature in [DreamTweaksFeature.dynamicPeninsulaOverlay, .systemWideNotch, .secondSpaceOSProfile, .faceIDHardwareUnlock] {
            guard case .requiresJailbreak = engine.capability(for: feature) else {
                XCTFail("\(feature) should be reported as requiring jailbreak, not claimed as supported")
                return
            }
        }
    }

    func testPublicAPIIntegrationSupportsRealPublicFeatures() {
        let engine = PublicAPIIntegration()

        for feature in [DreamTweaksFeature.musicNowPlaying, .batteryStatus, .hapticFeedback, .localNotifications] {
            guard case .supportedByPublicAPI = engine.capability(for: feature) else {
                XCTFail("\(feature) should be supported by public APIs")
                return
            }
        }
    }
}
