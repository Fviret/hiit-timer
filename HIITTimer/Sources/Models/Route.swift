import Foundation

enum Route: Hashable {
    case sessionList
    case timer(WorkoutSession)
}
