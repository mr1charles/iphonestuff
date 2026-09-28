import XCTest
@testable import DreamTweaks

final class PreferencesStoreTests: XCTestCase {
    private var defaults: UserDefaults!
    private var store: PreferencesStore!

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: #file)
        defaults.removePersistentDomain(forName: #file)
        store = PreferencesStore(defaults: defaults)
    }

    func testLoadReturnsDefaultsWhenEmpty() {
        let prefs = store.load()
        XCTAssertFalse(prefs.hasCompletedOnboarding)
        XCTAssertTrue(prefs.peninsula.isEnabled)
    }

    func testSaveThenLoadRoundTrips() {
        var prefs = store.load()
        prefs.hasCompletedOnboarding = true
        prefs.appearance.mode = .dark
        prefs.secondSpaceEnabled = true
        store.save(prefs)

        let reloaded = store.load()
        XCTAssertTrue(reloaded.hasCompletedOnboarding)
        XCTAssertEqual(reloaded.appearance.mode, .dark)
        XCTAssertTrue(reloaded.secondSpaceEnabled)
    }

    func testResetClearsPreferences() {
        var prefs = store.load()
        prefs.hasCompletedOnboarding = true
        store.save(prefs)
        store.reset()
        XCTAssertFalse(store.load().hasCompletedOnboarding)
    }
}
