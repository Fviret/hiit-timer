import SwiftUI

enum Theme {
    static let workGradient = LinearGradient(
        colors: [Color(hex: "FF5F6D"), Color(hex: "FFC371")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let restGradient = LinearGradient(
        colors: [Color(hex: "36D1DC"), Color(hex: "5B86E5")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let prepareGradient = LinearGradient(
        colors: [Color(hex: "8E2DE2"), Color(hex: "4A00E0")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let finishedGradient = LinearGradient(
        colors: [Color(hex: "11998E"), Color(hex: "38EF7D")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let background = LinearGradient(
        colors: [Color(hex: "0F0C29"), Color(hex: "302B63"), Color(hex: "24243E")],
        startPoint: .top, endPoint: .bottom
    )

    static func gradient(for phase: WorkoutPhase) -> LinearGradient {
        switch phase {
        case .ready, .prepare: return prepareGradient
        case .work: return workGradient
        case .rest: return restGradient
        case .finished: return finishedGradient
        }
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb & 0xFF0000) >> 16) / 255
        let g = Double((rgb & 0x00FF00) >> 8) / 255
        let b = Double(rgb & 0x0000FF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
