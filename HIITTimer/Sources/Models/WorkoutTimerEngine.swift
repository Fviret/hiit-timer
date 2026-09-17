import Foundation
import Combine
import UIKit

final class WorkoutTimerEngine: ObservableObject {
    @Published private(set) var phase: WorkoutPhase = .ready
    @Published private(set) var currentRound: Int = 0
    @Published private(set) var remainingSeconds: Int = 0
    @Published private(set) var progress: Double = 0
    @Published private(set) var isRunning: Bool = false
    @Published private(set) var isPaused: Bool = false

    let session: WorkoutSession

    private var phaseDuration: Int = 0
    private var phaseEndDate: Date?
    private var pausedRemainder: TimeInterval?
    private var timerCancellable: AnyCancellable?
    private var announcedCountdown: Set<Int> = []

    init(session: WorkoutSession) {
        self.session = session
    }

    func start() {
        guard phase == .ready else { return }
        SoundManager.shared.playSessionStart()
        if session.prepareDuration > 0 {
            beginPhase(.prepare, duration: session.prepareDuration)
        } else {
            currentRound = 1
            beginPhase(.work, duration: session.workDuration)
        }
        isRunning = true
        isPaused = false
        startTicking()
    }

    func pause() {
        guard isRunning, !isPaused, let endDate = phaseEndDate else { return }
        pausedRemainder = endDate.timeIntervalSinceNow
        isPaused = true
        timerCancellable?.cancel()
    }

    func resume() {
        guard isPaused, let remainder = pausedRemainder else { return }
        phaseEndDate = Date().addingTimeInterval(remainder)
        isPaused = false
        startTicking()
    }

    func skipPhase() {
        guard isRunning else { return }
        advancePhase()
    }

    /// Stops the workout immediately without playing the completion sound,
    /// used when the user cancels manually (as opposed to reaching the end).
    func cancel() {
        timerCancellable?.cancel()
        isRunning = false
        isPaused = false
    }

    private func beginPhase(_ newPhase: WorkoutPhase, duration: Int) {
        phase = newPhase
        phaseDuration = duration
        remainingSeconds = duration
        progress = 0
        phaseEndDate = Date().addingTimeInterval(TimeInterval(duration))
        announcedCountdown.removeAll()

        switch newPhase {
        case .work:
            SoundManager.shared.playWorkStart()
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        case .rest:
            SoundManager.shared.playRestStart()
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        default:
            break
        }
    }

    private func startTicking() {
        timerCancellable = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    private func tick() {
        guard let endDate = phaseEndDate, !isPaused else { return }
        let remaining = max(0, endDate.timeIntervalSinceNow)
        let roundedRemaining = Int(remaining.rounded(.up))

        if roundedRemaining != remainingSeconds {
            remainingSeconds = roundedRemaining
            if roundedRemaining > 0, roundedRemaining <= 3, !announcedCountdown.contains(roundedRemaining) {
                announcedCountdown.insert(roundedRemaining)
                SoundManager.shared.playCountdownTick()
            }
        }

        progress = phaseDuration > 0 ? min(1, max(0, 1 - remaining / Double(phaseDuration))) : 0

        if remaining <= 0.05 {
            advancePhase()
        }
    }

    private func advancePhase() {
        switch phase {
        case .prepare:
            currentRound = 1
            beginPhase(.work, duration: session.workDuration)
        case .work:
            if currentRound >= session.rounds {
                finish()
            } else if session.restDuration > 0 {
                beginPhase(.rest, duration: session.restDuration)
            } else {
                currentRound += 1
                beginPhase(.work, duration: session.workDuration)
            }
        case .rest:
            currentRound += 1
            beginPhase(.work, duration: session.workDuration)
        case .ready, .finished:
            break
        }
    }

    private func finish() {
        timerCancellable?.cancel()
        phase = .finished
        progress = 1
        isRunning = false
        SoundManager.shared.playSessionEnd()
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
