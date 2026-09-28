import Foundation
import Combine

/// Drives the Mock Touch Fingerprint simulation end to end: contact →
/// reading → success/failure. This is a **visual simulation only** — it
/// never touches biometric hardware, never captures or stores an image,
/// and never claims the user has actually been authenticated. It exists
/// purely to demonstrate what an under-display sensor could feel like on
/// an iPhone 12, which has no such hardware.
final class MockFingerprintManager: ObservableObject {
    @Published private(set) var stage: FingerprintScanStage = .idle
    @Published private(set) var scanProgress: Double = 0
    @Published private(set) var scanResult: FingerprintScanStage?
    @Published private(set) var settings: FingerprintSimulationSettings

    var isEnabled: Bool { settings.isEnabled }
    var sensorPosition: SensorPosition { settings.position }
    var sensorSize: Double { settings.diameter }
    var isScanning: Bool { stage == .contact || stage == .reading }

    /// Called with `true` on a simulated success, so the Lock Screen Demo
    /// can transition into the configured space. This never bypasses any
    /// real iOS authentication — it only drives DreamTweaks' own UI.
    var onScanCompleted: ((Bool) -> Void)?

    private let events: SimulatedSystemEventService
    private var scanTask: Task<Void, Never>?

    init(settings: FingerprintSimulationSettings, events: SimulatedSystemEventService = .shared) {
        self.settings = settings
        self.events = events
    }

    func apply(_ settings: FingerprintSimulationSettings) {
        self.settings = settings
    }

    func touchDown() {
        guard settings.isEnabled, stage == .idle else { return }
        startScan()
    }

    func startScan(forcedResult: FingerprintScanStage? = nil) {
        scanTask?.cancel()
        stage = .contact
        scanProgress = 0
        scanResult = nil

        if settings.hapticFeedback { HapticsService.light() }

        scanTask = Task { [weak self] in
            guard let self else { return }
            try? await Task.sleep(nanoseconds: 150_000_000)
            guard !Task.isCancelled else { return }
            await MainActor.run { self.stage = .reading }

            let steps = 20
            let stepDuration = max(0.02, self.settings.scanDurationSeconds / Double(steps))
            for step in 1...steps {
                try? await Task.sleep(nanoseconds: UInt64(stepDuration * 1_000_000_000))
                guard !Task.isCancelled else { return }
                let progress = Double(step) / Double(steps)
                await MainActor.run {
                    self.scanProgress = progress
                    self.events.emit(.fingerprintScanProgress(progress))
                }
            }

            guard !Task.isCancelled else { return }
            let succeeded = forcedResult.map { $0 == .success } ?? self.resolveResult()
            await MainActor.run {
                self.finish(succeeded: succeeded)
            }
        }
    }

    func forceSuccess() { startScan(forcedResult: .success) }
    func forceFailure() { startScan(forcedResult: .failure) }

    private func resolveResult() -> Bool {
        switch settings.resultMode {
        case .alwaysSucceed: return true
        case .alwaysFail: return false
        case .random: return Bool.random()
        }
    }

    private func finish(succeeded: Bool) {
        stage = succeeded ? .success : .failure
        scanResult = stage

        if settings.hapticFeedback {
            succeeded ? HapticsService.success() : HapticsService.medium()
        }

        events.emit(succeeded ? .fingerprintScanSucceeded : .fingerprintScanFailed)
        onScanCompleted?(succeeded)

        let dismissDelay: Double = succeeded ? 1.1 : 1.4
        Task { [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(dismissDelay * 1_000_000_000))
            await MainActor.run { self?.reset() }
        }
    }

    func reset() {
        scanTask?.cancel()
        stage = .idle
        scanProgress = 0
        scanResult = nil
        events.emit(.fingerprintScanDismissed)
    }
}
