import Foundation
import Combine

/// Drives the Dynamic Peninsula's state machine. The default
/// implementation reacts only to simulated/public-API-sourced events
/// (Test Lab buttons, MPNowPlayingInfoCenter-style mock data, a local
/// countdown, battery state). A future system-level engine could
/// conform to the same protocol.
protocol DynamicPeninsulaEngine: ObservableObject {
    var state: PeninsulaState { get }
    var isExpanded: Bool { get }

    func expand()
    func collapse()
    func toggle()
    func handleLongPress()
}

final class DefaultDynamicPeninsulaEngine: DynamicPeninsulaEngine {
    @Published private(set) var state: PeninsulaState = .compact
    @Published private(set) var isExpanded: Bool = false

    private var cancellables = Set<AnyCancellable>()
    private let events: SimulatedSystemEventService

    init(events: SimulatedSystemEventService = .shared) {
        self.events = events
        subscribe()
    }

    private func subscribe() {
        events.eventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                self?.handle(event)
            }
            .store(in: &cancellables)
    }

    private func handle(_ event: SimulatedSystemEvent) {
        switch event {
        case .musicStarted(let title, let artist):
            state = .music(MusicInfo(title: title, artist: artist, isPlaying: true))
        case .musicPaused:
            if case .music(var info) = state {
                info.isPlaying = false
                state = .music(info)
            }
        case .timerStarted(let seconds, let label):
            state = .timer(TimerInfo(remainingSeconds: seconds, label: label))
        case .timerFinished:
            state = .notification(NotificationInfo(appName: "Timer", message: "Time's up"))
        case .chargingStarted(let percent):
            state = .charging(ChargingInfo(isCharging: true, batteryPercent: percent))
        case .chargingStopped:
            state = .compact
        case .batteryChanged(let percent):
            if case .charging(var info) = state {
                info.batteryPercent = percent
                state = .charging(info)
            }
        case .notificationReceived(let appName, let message):
            state = .notification(NotificationInfo(appName: appName, message: message))
        case .secondSpaceSwitched(let name):
            state = .notification(NotificationInfo(appName: "Second Space", message: "Switched to \(name)"))
        }
    }

    func expand() {
        isExpanded = true
    }

    func collapse() {
        isExpanded = false
    }

    func toggle() {
        isExpanded.toggle()
    }

    func handleLongPress() {
        state = .faceID(.scanning)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) { [weak self] in
            self?.state = .faceID(.success)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self?.state = .compact
            }
        }
    }

    func resetToCompact() {
        state = .compact
        isExpanded = false
    }
}
