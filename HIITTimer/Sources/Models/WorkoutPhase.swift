import Foundation

enum WorkoutPhase: Equatable {
    case ready
    case prepare
    case work
    case rest
    case finished

    var label: String {
        switch self {
        case .ready: return "Prêt"
        case .prepare: return "Préparation"
        case .work: return "Action"
        case .rest: return "Repos"
        case .finished: return "Terminé"
        }
    }
}
