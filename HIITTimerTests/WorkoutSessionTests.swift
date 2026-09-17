import XCTest
@testable import HIITTimer

final class WorkoutSessionTests: XCTestCase {
    func testTotalDurationComputation() {
        let session = WorkoutSession(name: "Test", prepareDuration: 10, workDuration: 30, restDuration: 15, rounds: 8)
        // 10s prep + 8 rounds * 30s work + 7 rests * 15s (no rest after the last round)
        XCTAssertEqual(session.totalDuration, 355)
    }

    func testTotalDurationWithSingleRoundHasNoRest() {
        let session = WorkoutSession(name: "Test", prepareDuration: 0, workDuration: 20, restDuration: 10, rounds: 1)
        XCTAssertEqual(session.totalDuration, 20)
    }

    func testDefaultSessionValues() {
        let session = WorkoutSession.defaultSession()
        XCTAssertEqual(session.prepareDuration, 10)
        XCTAssertEqual(session.workDuration, 30)
        XCTAssertEqual(session.restDuration, 15)
        XCTAssertEqual(session.rounds, 8)
    }

    func testCodableRoundTrip() throws {
        let session = WorkoutSession(name: "Codable", prepareDuration: 5, workDuration: 40, restDuration: 20, rounds: 6)
        let data = try JSONEncoder().encode(session)
        let decoded = try JSONDecoder().decode(WorkoutSession.self, from: data)
        XCTAssertEqual(decoded, session)
    }
}
