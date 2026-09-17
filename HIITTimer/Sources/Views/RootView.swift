import SwiftUI

struct RootView: View {
    @StateObject private var store = SessionStore()
    @State private var activeSession = WorkoutSession.defaultSession()
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            SetupView(session: $activeSession, store: store, path: $path)
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .sessionList:
                        SessionListView(store: store, activeSession: $activeSession, path: $path)
                    case .timer(let session):
                        TimerView(session: session)
                    }
                }
        }
        .preferredColorScheme(.dark)
        .tint(.white)
    }
}
