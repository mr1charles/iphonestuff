import Foundation
import Combine

/// Manages DreamTweaks' sandboxed "spaces". Everything here lives inside
/// DreamTweaks' own storage — it is the strongest sandboxed version of
/// Second Space an ordinary IPA can offer, not a true OS-level user
/// profile (see `SystemIntegrationEngine`).
protocol SecondSpaceEngine: ObservableObject {
    var spaces: [DreamSpace] { get }
    var activeSpaceID: UUID { get }
    var isTransitioning: Bool { get }

    func createSpace(named name: String)
    func deleteSpace(id: UUID)
    func switchToSpace(id: UUID)
    func updateActiveSpace(_ mutate: (inout DreamSpace) -> Void)
}

final class DefaultSecondSpaceEngine: SecondSpaceEngine {
    @Published private(set) var spaces: [DreamSpace]
    @Published private(set) var activeSpaceID: UUID
    @Published private(set) var isTransitioning: Bool = false

    private let store: SpaceStore
    private let events: SimulatedSystemEventService

    init(store: SpaceStore = .shared, events: SimulatedSystemEventService = .shared) {
        self.store = store
        self.events = events
        let loaded = store.load()
        self.spaces = loaded.spaces
        self.activeSpaceID = loaded.activeID ?? loaded.spaces.first?.id ?? UUID()
    }

    var activeSpace: DreamSpace {
        spaces.first(where: { $0.id == activeSpaceID }) ?? spaces[0]
    }

    func createSpace(named name: String) {
        let space = DreamSpace.makeSecondSpace(named: name)
        spaces.append(space)
        persist()
    }

    func deleteSpace(id: UUID) {
        guard spaces.count > 1 else { return }
        spaces.removeAll { $0.id == id }
        if activeSpaceID == id {
            activeSpaceID = spaces.first!.id
        }
        persist()
    }

    func switchToSpace(id: UUID) {
        guard id != activeSpaceID, spaces.contains(where: { $0.id == id }) else { return }
        isTransitioning = true
        let targetName = spaces.first(where: { $0.id == id })?.name ?? ""
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) { [weak self] in
            guard let self else { return }
            self.activeSpaceID = id
            self.persist()
            self.events.emit(.secondSpaceSwitched(spaceName: targetName))
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
                self.isTransitioning = false
            }
        }
    }

    func updateActiveSpace(_ mutate: (inout DreamSpace) -> Void) {
        guard let index = spaces.firstIndex(where: { $0.id == activeSpaceID }) else { return }
        mutate(&spaces[index])
        persist()
    }

    private func persist() {
        store.save(spaces: spaces, activeID: activeSpaceID)
    }
}

/// Persists the list of spaces and which one is active.
final class SpaceStore {
    static let shared = SpaceStore()

    private let defaults: UserDefaults
    private let spacesKey = "com.dreamtweaks.spaces"
    private let activeKey = "com.dreamtweaks.activeSpaceID"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> (spaces: [DreamSpace], activeID: UUID?) {
        guard let data = defaults.data(forKey: spacesKey),
              let decoded = try? JSONDecoder().decode([DreamSpace].self, from: data),
              !decoded.isEmpty else {
            let main = DreamSpace.makeDefaultMainSpace()
            save(spaces: [main], activeID: main.id)
            return ([main], main.id)
        }
        let activeIDString = defaults.string(forKey: activeKey)
        let activeID = activeIDString.flatMap { UUID(uuidString: $0) }
        return (decoded, activeID)
    }

    func save(spaces: [DreamSpace], activeID: UUID) {
        if let data = try? JSONEncoder().encode(spaces) {
            defaults.set(data, forKey: spacesKey)
        }
        defaults.set(activeID.uuidString, forKey: activeKey)
    }

    func reset() {
        defaults.removeObject(forKey: spacesKey)
        defaults.removeObject(forKey: activeKey)
    }
}
