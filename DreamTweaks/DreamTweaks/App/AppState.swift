import SwiftUI
import Combine

/// Single source of truth for DreamTweaks preferences, wired to
/// persistent storage. Views read/write through this object so every
/// screen (Setup, Home, Settings, Test Lab) stays in sync.
final class AppState: ObservableObject {
    @Published var preferences: DreamTweaksPreferences {
        didSet {
            store.save(preferences)
            fingerprintManager.apply(preferences.fingerprint)
        }
    }

    let peninsulaEngine: DefaultDynamicPeninsulaEngine
    let secondSpaceEngine: DefaultSecondSpaceEngine
    let eventService: SimulatedSystemEventService
    let fingerprintManager: MockFingerprintManager

    private let store: PreferencesStore

    init(store: PreferencesStore = .shared,
         eventService: SimulatedSystemEventService = .shared) {
        self.store = store
        let loaded = store.load()
        self.preferences = loaded
        self.eventService = eventService
        self.peninsulaEngine = DefaultDynamicPeninsulaEngine(events: eventService)
        self.secondSpaceEngine = DefaultSecondSpaceEngine(events: eventService)
        self.fingerprintManager = MockFingerprintManager(settings: loaded.fingerprint, events: eventService)

        fingerprintManager.onScanCompleted = { [weak self] succeeded in
            guard succeeded, let self else { return }
            if let targetID = self.preferences.fingerprint.unlockTargetSpaceID {
                self.secondSpaceEngine.switchToSpace(id: targetID)
            }
        }
    }

    var resolvedColorScheme: ColorScheme? {
        preferences.appearance.mode.colorScheme
    }

    func completeOnboarding() {
        preferences.hasCompletedOnboarding = true
    }

    func resetAll() {
        store.reset()
        SpaceStore.shared.reset()
        preferences = DreamTweaksPreferences()
    }
}
