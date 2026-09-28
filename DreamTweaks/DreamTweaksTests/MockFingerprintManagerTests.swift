import XCTest
import Combine
@testable import DreamTweaks

final class MockFingerprintManagerTests: XCTestCase {
    func testForceSuccessReachesSuccessStage() {
        let manager = MockFingerprintManager(
            settings: FingerprintSimulationSettings(scanDurationSeconds: 0.1),
            events: SimulatedSystemEventService()
        )

        let expectation = expectation(description: "success")
        var cancellable: AnyCancellable?
        cancellable = manager.$stage.dropFirst().sink { stage in
            if stage == .success {
                expectation.fulfill()
            }
        }

        manager.forceSuccess()
        wait(for: [expectation], timeout: 2.0)
        cancellable?.cancel()
    }

    func testForceFailureReachesFailureStage() {
        let manager = MockFingerprintManager(
            settings: FingerprintSimulationSettings(scanDurationSeconds: 0.1),
            events: SimulatedSystemEventService()
        )

        let expectation = expectation(description: "failure")
        var cancellable: AnyCancellable?
        cancellable = manager.$stage.dropFirst().sink { stage in
            if stage == .failure {
                expectation.fulfill()
            }
        }

        manager.forceFailure()
        wait(for: [expectation], timeout: 2.0)
        cancellable?.cancel()
    }

    func testDisabledSensorIgnoresTouch() {
        let manager = MockFingerprintManager(
            settings: FingerprintSimulationSettings(isEnabled: false),
            events: SimulatedSystemEventService()
        )
        manager.touchDown()
        XCTAssertEqual(manager.stage, .idle)
    }

    func testResetReturnsToIdle() {
        let manager = MockFingerprintManager(
            settings: FingerprintSimulationSettings(scanDurationSeconds: 0.1),
            events: SimulatedSystemEventService()
        )
        manager.touchDown()
        manager.reset()
        XCTAssertEqual(manager.stage, .idle)
        XCTAssertEqual(manager.scanProgress, 0)
    }

    func testSensorPositionDefaultsToBottomCenter() {
        let position = SensorPosition.defaultPosition
        XCTAssertEqual(position.xFraction, 0.5, accuracy: 0.001)
        XCTAssertGreaterThan(position.yFraction, 0.7)
    }
}
