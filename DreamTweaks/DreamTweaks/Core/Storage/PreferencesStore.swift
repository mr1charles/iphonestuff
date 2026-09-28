import Foundation

/// Persists DreamTweaks preferences locally (UserDefaults + JSON).
/// All data stays on-device, matching the "Local-only data" privacy promise.
final class PreferencesStore {
    static let shared = PreferencesStore()

    private let defaults: UserDefaults
    private let preferencesKey = "com.dreamtweaks.preferences"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> DreamTweaksPreferences {
        guard let data = defaults.data(forKey: preferencesKey),
              let decoded = try? JSONDecoder().decode(DreamTweaksPreferences.self, from: data) else {
            return DreamTweaksPreferences()
        }
        return decoded
    }

    func save(_ preferences: DreamTweaksPreferences) {
        guard let data = try? JSONEncoder().encode(preferences) else { return }
        defaults.set(data, forKey: preferencesKey)
    }

    func reset() {
        defaults.removeObject(forKey: preferencesKey)
    }
}
