import Foundation

enum SpaceTransitionAnimation: String, CaseIterable, Identifiable, Codable {
    case blurZoom, slide, fade

    var id: String { rawValue }
    var title: String {
        switch self {
        case .blurZoom: return "Blur & Zoom"
        case .slide: return "Slide"
        case .fade: return "Fade"
        }
    }
}

struct SpaceApp: Codable, Equatable, Identifiable {
    var id = UUID()
    var name: String
    var systemImage: String
}

struct SpaceNote: Codable, Equatable, Identifiable {
    var id = UUID()
    var title: String
    var body: String
    var createdAt: Date = Date()
}

struct SpaceFile: Codable, Equatable, Identifiable {
    var id = UUID()
    var name: String
    var sizeDescription: String
}

struct SpaceNotificationRecord: Codable, Equatable, Identifiable {
    var id = UUID()
    var appName: String
    var message: String
    var date: Date = Date()
}

/// A sandboxed, in-app "space" — DreamTweaks' own simulated profile.
/// This never hides other installed apps or creates a real iOS user
/// profile; it is a self-contained environment stored entirely inside
/// DreamTweaks' own data, matching what an ordinary App Store app can do.
struct DreamSpace: Codable, Equatable, Identifiable {
    var id = UUID()
    var name: String
    var wallpaperColorHex: String
    var apps: [SpaceApp]
    var notes: [SpaceNote]
    var files: [SpaceFile]
    var notifications: [SpaceNotificationRecord]
    var preferences: SpacePreferences
    var transitionAnimation: SpaceTransitionAnimation = .blurZoom

    static func makeDefaultMainSpace() -> DreamSpace {
        DreamSpace(
            name: "Main Space",
            wallpaperColorHex: "1C1C1E",
            apps: [
                SpaceApp(name: "Notes", systemImage: "note.text"),
                SpaceApp(name: "Files", systemImage: "folder"),
                SpaceApp(name: "Photos", systemImage: "photo.on.rectangle"),
                SpaceApp(name: "DreamTweaks", systemImage: "sparkles")
            ],
            notes: [SpaceNote(title: "Welcome", body: "This is your Main Space.")],
            files: [],
            notifications: [],
            preferences: SpacePreferences()
        )
    }

    static func makeSecondSpace(named name: String = "Second Space") -> DreamSpace {
        DreamSpace(
            name: name,
            wallpaperColorHex: "0A84FF",
            apps: [
                SpaceApp(name: "Notes", systemImage: "note.text"),
                SpaceApp(name: "Files", systemImage: "folder"),
                SpaceApp(name: "DreamTweaks", systemImage: "sparkles")
            ],
            notes: [SpaceNote(title: "Second Space", body: "A separate, sandboxed environment inside DreamTweaks.")],
            files: [],
            notifications: [],
            preferences: SpacePreferences()
        )
    }
}

struct SpacePreferences: Codable, Equatable {
    var appearance: AppearanceMode = .automatic
    var appLockEnabled: Bool = false
}
