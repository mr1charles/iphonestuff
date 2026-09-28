import SwiftUI
import Combine

/// Single source of truth for DreamTweaks preferences, wired to
/// persistent storage. Views read/write through this object so every
/// screen (Setup, Home, Settings, Test Lab) stays in sync.
final class AppState: ObservableObject {
    @Published var preferences: DreamTweaksPreferences {
        didSet { store.save(preferences) }
    }

    let peninsulaEngine: DefaultDynamicPeninsulaEngine
    let secondSpaceEngine: DefaultSecondSpaceEngine
    let eventService: SimulatedSystemEventService

    private let store: PreferencesStore

    init(store: PreferencesStore = .shared,
         eventService: SimulatedSystemEventService = .shared) {
        self.store = store
        self.preferences = store.load()
        self.eventService = eventService
        self.peninsulaEngine = DefaultDynamicPeninsulaEngine(events: eventService)
        self.secondSpaceEngine = DefaultSecondSpaceEngine(events: eventService)
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
