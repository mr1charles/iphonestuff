import XCTest
@testable import DreamTweaks

final class SecondSpaceEngineTests: XCTestCase {
    private func makeStore() -> SpaceStore {
        let defaults = UserDefaults(suiteName: #file)!
        defaults.removePersistentDomain(forName: #file)
        return SpaceStore(defaults: defaults)
    }

    func testStartsWithMainSpace() {
        let engine = DefaultSecondSpaceEngine(store: makeStore())
        XCTAssertEqual(engine.spaces.count, 1)
        XCTAssertEqual(engine.spaces.first?.name, "Main Space")
    }

    func testCreateSpaceAddsSpace() {
        let engine = DefaultSecondSpaceEngine(store: makeStore())
        engine.createSpace(named: "Work")
        XCTAssertEqual(engine.spaces.count, 2)
        XCTAssertTrue(engine.spaces.contains { $0.name == "Work" })
    }

    func testCannotDeleteLastRemainingSpace() {
        let engine = DefaultSecondSpaceEngine(store: makeStore())
        let onlySpaceID = engine.spaces[0].id
        engine.deleteSpace(id: onlySpaceID)
        XCTAssertEqual(engine.spaces.count, 1)
    }

    func testSwitchToSpaceEventuallyUpdatesActiveID() {
        let engine = DefaultSecondSpaceEngine(store: makeStore())
        engine.createSpace(named: "Work")
        let targetID = engine.spaces[1].id

        let expectation = expectation(description: "switched")
        engine.switchToSpace(id: targetID)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            XCTAssertEqual(engine.activeSpaceID, targetID)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
}
