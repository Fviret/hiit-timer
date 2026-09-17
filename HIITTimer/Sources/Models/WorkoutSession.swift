import Foundation

struct WorkoutSession: Identifiable, Codable, Equatable, Hashable {
    var id: UUID = UUID()
    var name: String
    var prepareDuration: Int
    var workDuration: Int
    var restDuration: Int
    var rounds: Int
    var createdAt: Date = Date()

    static func defaultSession() -> WorkoutSession {
        WorkoutSession(
            name: "Nouvelle séance",
            prepareDuration: 10,
            workDuration: 30,
            restDuration: 15,
            rounds: 8
        )
    }

    var totalDuration: Int {
        prepareDuration + rounds * workDuration + max(0, rounds - 1) * restDuration
    }
}
