import SwiftUI

struct SessionListView: View {
    @ObservedObject var store: SessionStore
    @Binding var activeSession: WorkoutSession
    @Binding var path: NavigationPath

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            if store.sessions.isEmpty {
                emptyState
            } else {
                VStack(spacing: 0) {
                    Text("Glisser une séance pour la modifier ou la supprimer")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.55))
                        .padding(.top, 12)
                        .padding(.bottom, 4)
                    sessionList
                }
            }
        }
        .navigationTitle("Mes séances")
    }

    private var sessionList: some View {
        List {
            ForEach(store.sessions) { session in
                Button {
                    activeSession = session
                    path.append(Route.timer(session))
                } label: {
                    SessionRow(session: session)
                }
                .listRowBackground(Color.white.opacity(0.06))
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        store.delete(session)
                    } label: {
                        Label("Supprimer", systemImage: "trash")
                    }
                }
                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                    Button {
                        activeSession = session
                        path = NavigationPath()
                    } label: {
                        Label("Modifier", systemImage: "pencil")
                    }
                    .tint(.blue)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .listStyle(.plain)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 44))
                .foregroundStyle(.white.opacity(0.5))
            Text("Aucune séance enregistrée")
                .foregroundStyle(.white.opacity(0.7))
        }
    }
}

private struct SessionRow: View {
    let session: WorkoutSession

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(session.name)
                    .font(.headline)
                    .foregroundStyle(.white)
                Text("\(session.rounds) tours · \(session.workDuration)s action / \(session.restDuration)s repos")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
            }
            Spacer()
            Image(systemName: "play.circle.fill")
                .font(.title2)
                .foregroundStyle(.white.opacity(0.6))
        }
        .padding(.vertical, 6)
    }
}
