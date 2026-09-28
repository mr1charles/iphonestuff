import Foundation
import Combine

/// The fake system events the spec asks for (music, timer, charging,
/// notifications, space switches). These feed the Dynamic Peninsula and
/// Test Lab so the concept can be demonstrated without real system hooks.
enum SimulatedSystemEvent {
    case musicStarted(title: String, artist: String)
    case musicPaused
    case timerStarted(seconds: Int, label: String)
    case timerFinished
    case chargingStarted(percent: Int)
    case chargingStopped
    case batteryChanged(percent: Int)
    case notificationReceived(appName: String, message: String)
    case secondSpaceSwitched(spaceName: String)
    case fingerprintScanProgress(Double)
    case fingerprintScanSucceeded
    case fingerprintScanFailed
    case fingerprintScanDismissed
}

final class SimulatedSystemEventService: ObservableObject {
    static let shared = SimulatedSystemEventService()

    let eventPublisher = PassthroughSubject<SimulatedSystemEvent, Never>()

    private var timerCancellable: AnyCancellable?
    private var countdown: Int = 0
    private var timerLabel: String = "Timer"

    func emit(_ event: SimulatedSystemEvent) {
        eventPublisher.send(event)
    }

    func startDemoTimer(seconds: Int, label: String = "Timer") {
        countdown = seconds
        timerLabel = label
        emit(.timerStarted(seconds: seconds, label: label))
        timerCancellable?.cancel()
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                self.countdown -= 1
                if self.countdown <= 0 {
                    self.timerCancellable?.cancel()
                    self.emit(.timerFinished)
                } else {
                    self.emit(.timerStarted(seconds: self.countdown, label: self.timerLabel))
                }
            }
    }

    func stopDemoTimer() {
        timerCancellable?.cancel()
    }
}
