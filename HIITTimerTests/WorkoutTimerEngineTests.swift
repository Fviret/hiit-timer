import XCTest
import Combine
@testable import HIITTimer

final class WorkoutTimerEngineTests: XCTestCase {
    private var cancellables: Set<AnyCancellable> = []

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    private func makeSession(prepare: Int = 0, work: Int = 60, rest: Int = 60, rounds: Int = 2) -> WorkoutSession {
        WorkoutSession(name: "Test", prepareDuration: prepare, workDuration: work, restDuration: rest, rounds: rounds)
    }

    func testStartWithoutPrepareGoesStraightToWork() {
        let engine = WorkoutTimerEngine(session: makeSession(prepare: 0))

        engine.start()

        XCTAssertEqual(engine.phase, .work)
        XCTAssertEqual(engine.currentRound, 1)
        XCTAssertTrue(engine.isRunning)
    }

    func testStartWithPrepareBeginsInPreparePhase() {
        let engine = WorkoutTimerEngine(session: makeSession(prepare: 5))

        engine.start()

        XCTAssertEqual(engine.phase, .prepare)
        XCTAssertEqual(engine.currentRound, 0)
        XCTAssertEqual(engine.remainingSeconds, 5)
    }

    func testPrepareTransitionsToWorkAfterItsDuration() {
        let engine = WorkoutTimerEngine(session: makeSession(prepare: 1, work: 30, rest: 30, rounds: 3))
        let reachedWork = expectation(description: "reaches work phase")
        engine.$phase
            .sink { phase in
                if phase == .work { reachedWork.fulfill() }
            }
            .store(in: &cancellables)

        engine.start()

        wait(for: [reachedWork], timeout: 3)
        XCTAssertEqual(engine.currentRound, 1)
    }

    func testSkipPhaseAdvancesFromWorkToRest() {
        let engine = WorkoutTimerEngine(session: makeSession(prepare: 0, rounds: 2))
        engine.start()

        engine.skipPhase()

        XCTAssertEqual(engine.phase, .rest)
        XCTAssertEqual(engine.currentRound, 1)
    }

    func testSkipPhaseAdvancesFromRestToNextRound() {
        let engine = WorkoutTimerEngine(session: makeSession(prepare: 0, rounds: 3))
        engine.start()
        engine.skipPhase() // work -> rest

        engine.skipPhase() // rest -> work, round 2

        XCTAssertEqual(engine.phase, .work)
        XCTAssertEqual(engine.currentRound, 2)
    }

    func testZeroRestDurationSkipsRestPhaseEntirely() {
        let engine = WorkoutTimerEngine(session: makeSession(prepare: 0, rest: 0, rounds: 3))
        engine.start()

        engine.skipPhase() // should go straight to round 2's work, no rest

        XCTAssertEqual(engine.phase, .work)
        XCTAssertEqual(engine.currentRound, 2)
    }

    func testFinishingLastRoundSkipsRestAndEndsSession() {
        let engine = WorkoutTimerEngine(session: makeSession(prepare: 0, rounds: 1))
        engine.start()

        engine.skipPhase()

        XCTAssertEqual(engine.phase, .finished)
        XCTAssertFalse(engine.isRunning)
    }

    func testPauseFreezesRemainingSeconds() {
        let engine = WorkoutTimerEngine(session: makeSession(prepare: 0, work: 5))
        engine.start()

        engine.pause()
        let remainingAtPause = engine.remainingSeconds
        Thread.sleep(forTimeInterval: 0.5)

        XCTAssertTrue(engine.isPaused)
        XCTAssertEqual(engine.remainingSeconds, remainingAtPause)
    }

    func testResumeContinuesFromPausedRemainder() {
        let engine = WorkoutTimerEngine(session: makeSession(prepare: 0, work: 5))
        engine.start()
        engine.pause()

        engine.resume()

        XCTAssertFalse(engine.isPaused)
    }

    func testCancelStopsWithoutMarkingFinished() {
        let engine = WorkoutTimerEngine(session: makeSession(prepare: 0, rounds: 2))
        engine.start()

        engine.cancel()

        XCTAssertFalse(engine.isRunning)
        XCTAssertNotEqual(engine.phase, .finished)
    }

    func testSkipPhaseDoesNothingBeforeStart() {
        let engine = WorkoutTimerEngine(session: makeSession())

        engine.skipPhase()

        XCTAssertEqual(engine.phase, .ready)
    }
}
