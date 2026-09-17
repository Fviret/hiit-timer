import Foundation
import Combine

final class SessionStore: ObservableObject {
    @Published private(set) var sessions: [WorkoutSession] = []

    private let defaultsKey = "com.floviret.hiittimer.sessions"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        load()
    }

    func load() {
        guard let data = defaults.data(forKey: defaultsKey) else { return }
        if let decoded = try? JSONDecoder().decode([WorkoutSession].self, from: data) {
            sessions = decoded.sorted { $0.createdAt > $1.createdAt }
        }
    }

    func save(_ session: WorkoutSession) {
        if let index = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[index] = session
        } else {
            sessions.insert(session, at: 0)
        }
        persist()
    }

    func delete(at offsets: IndexSet) {
        sessions.remove(atOffsets: offsets)
        persist()
    }

    func delete(_ session: WorkoutSession) {
        sessions.removeAll { $0.id == session.id }
        persist()
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(sessions) {
            defaults.set(data, forKey: defaultsKey)
        }
    }
}
