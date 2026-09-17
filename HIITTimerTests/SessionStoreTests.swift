import XCTest
@testable import HIITTimer

final class SessionStoreTests: XCTestCase {
    private let suiteName = "SessionStoreTests"
    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: suiteName)
        defaults.removePersistentDomain(forName: suiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        super.tearDown()
    }

    func testSaveAddsNewSession() {
        let store = SessionStore(defaults: defaults)
        let session = WorkoutSession.defaultSession()

        store.save(session)

        XCTAssertEqual(store.sessions.count, 1)
        XCTAssertEqual(store.sessions.first?.id, session.id)
    }

    func testSaveUpdatesExistingSessionInPlaceRatherThanDuplicating() {
        let store = SessionStore(defaults: defaults)
        var session = WorkoutSession.defaultSession()
        store.save(session)

        session.rounds = 12
        store.save(session)

        XCTAssertEqual(store.sessions.count, 1)
        XCTAssertEqual(store.sessions.first?.rounds, 12)
    }

    func testDeleteBySessionRemovesIt() {
        let store = SessionStore(defaults: defaults)
        let session = WorkoutSession.defaultSession()
        store.save(session)

        store.delete(session)

        XCTAssertTrue(store.sessions.isEmpty)
    }

    func testDeleteAtOffsets() {
        let store = SessionStore(defaults: defaults)
        let sessionA = WorkoutSession(name: "A", prepareDuration: 0, workDuration: 10, restDuration: 5, rounds: 3)
        let sessionB = WorkoutSession(name: "B", prepareDuration: 0, workDuration: 20, restDuration: 5, rounds: 4)
        store.save(sessionA)
        store.save(sessionB)

        store.delete(at: IndexSet(integer: 0))

        XCTAssertEqual(store.sessions.count, 1)
    }

    func testPersistenceAcrossInstances() {
        let session = WorkoutSession.defaultSession()
        let store1 = SessionStore(defaults: defaults)
        store1.save(session)

        let store2 = SessionStore(defaults: defaults)

        XCTAssertEqual(store2.sessions.count, 1)
        XCTAssertEqual(store2.sessions.first?.id, session.id)
    }
}
