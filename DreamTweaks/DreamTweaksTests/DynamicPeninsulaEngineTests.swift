import XCTest
import Combine
@testable import DreamTweaks

final class DynamicPeninsulaEngineTests: XCTestCase {
    func testMusicEventUpdatesState() {
        let events = SimulatedSystemEventService()
        let engine = DefaultDynamicPeninsulaEngine(events: events)

        let expectation = expectation(description: "state updates")
        var cancellable: AnyCancellable?
        cancellable = engine.$state.dropFirst().sink { state in
            if case .music(let info) = state {
                XCTAssertEqual(info.title, "Test Song")
                expectation.fulfill()
            }
        }

        events.emit(.musicStarted(title: "Test Song", artist: "Test Artist"))
        wait(for: [expectation], timeout: 1.0)
        cancellable?.cancel()
    }

    func testToggleExpandsAndCollapses() {
        let engine = DefaultDynamicPeninsulaEngine(events: SimulatedSystemEventService())
        XCTAssertFalse(engine.isExpanded)
        engine.toggle()
        XCTAssertTrue(engine.isExpanded)
        engine.toggle()
        XCTAssertFalse(engine.isExpanded)
    }

    func testChargingEventUpdatesState() {
        let events = SimulatedSystemEventService()
        let engine = DefaultDynamicPeninsulaEngine(events: events)

        let expectation = expectation(description: "charging state")
        var cancellable: AnyCancellable?
        cancellable = engine.$state.dropFirst().sink { state in
            if case .charging(let info) = state {
                XCTAssertEqual(info.batteryPercent, 55)
                expectation.fulfill()
            }
        }

        events.emit(.chargingStarted(percent: 55))
        wait(for: [expectation], timeout: 1.0)
        cancellable?.cancel()
    }
}
