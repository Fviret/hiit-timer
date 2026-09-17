import SwiftUI

struct SetupView: View {
    @Binding var session: WorkoutSession
    @ObservedObject var store: SessionStore
    @Binding var path: NavigationPath
    @State private var showSavedToast = false
    @State private var savedToastText = "Séance enregistrée"

    private var isEditingExistingSession: Bool {
        store.sessions.contains { $0.id == session.id }
    }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 22) {
                    header
                    nameField
                    DurationStepperCard(title: "Préparation", systemImage: "hourglass", seconds: $session.prepareDuration, step: 5, minimum: 0, maximum: 60, accent: .purple)
                    DurationStepperCard(title: "Action", systemImage: "flame.fill", seconds: $session.workDuration, step: 5, minimum: 5, maximum: 600, accent: .orange)
                    DurationStepperCard(title: "Repos", systemImage: "wind", seconds: $session.restDuration, step: 5, minimum: 0, maximum: 300, accent: .cyan)
                    RoundsStepperCard(rounds: $session.rounds)
                    summaryCard
                    actionButtons
                }
                .padding(20)
                .padding(.bottom, 40)
            }
        }
        .overlay(alignment: .top) {
            if showSavedToast {
                Text(savedToastText)
                    .font(.subheadline.bold())
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(.green.opacity(0.9), in: Capsule())
                    .foregroundStyle(.white)
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .navigationBarHidden(true)
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("HIIT Timer")
                    .font(.system(size: 30, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                Text("Configure ta séance fractionnée")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.65))
            }
            Spacer()
            if isEditingExistingSession {
                Button {
                    session = WorkoutSession.defaultSession()
                } label: {
                    VStack(spacing: 2) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                        Text("Nouvelle")
                            .font(.caption2.bold())
                    }
                    .foregroundStyle(.white)
                    .padding(12)
                    .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 16))
                }
            }
            Button {
                path.append(Route.sessionList)
            } label: {
                VStack(spacing: 2) {
                    Image(systemName: "list.bullet.rectangle.portrait.fill")
                        .font(.title2)
                    if !store.sessions.isEmpty {
                        Text("\(store.sessions.count)")
                            .font(.caption2.bold())
                    }
                }
                .foregroundStyle(.white)
                .padding(12)
                .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 16))
            }
        }
        .padding(.top, 8)
    }

    private var nameField: some View {
        HStack {
            Image(systemName: "pencil")
                .foregroundStyle(.white.opacity(0.6))
            TextField("Nom de la séance", text: $session.name)
                .foregroundStyle(.white)
                .tint(.white)
        }
        .padding(14)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))
    }

    private var summaryCard: some View {
        HStack {
            summaryItem(title: "Durée totale", value: durationString(session.totalDuration))
            Divider().overlay(.white.opacity(0.2))
            summaryItem(title: "Tours", value: "\(session.rounds)")
        }
        .padding(16)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 18))
    }

    private func summaryItem(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(.white)
            Text(title)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                path.append(Route.timer(session))
            } label: {
                Label("Démarrer", systemImage: "play.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Theme.workGradient, in: RoundedRectangle(cornerRadius: 18))
                    .foregroundStyle(.white)
            }

            Button {
                let wasEditing = isEditingExistingSession
                store.save(session)
                savedToastText = wasEditing ? "Séance mise à jour" : "Séance enregistrée"
                withAnimation { showSavedToast = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                    withAnimation { showSavedToast = false }
                }
            } label: {
                Label(
                    isEditingExistingSession ? "Mettre à jour la séance" : "Enregistrer la séance",
                    systemImage: isEditingExistingSession ? "arrow.triangle.2.circlepath" : "square.and.arrow.down"
                )
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 18))
                .foregroundStyle(.white)
            }

            if isEditingExistingSession {
                Button(role: .destructive) {
                    store.delete(session)
                    session = WorkoutSession.defaultSession()
                } label: {
                    Label("Supprimer la séance", systemImage: "trash")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.18), in: RoundedRectangle(cornerRadius: 18))
                        .foregroundStyle(.red)
                }
            }
        }
    }

    private func durationString(_ totalSeconds: Int) -> String {
        String(format: "%d:%02d", totalSeconds / 60, totalSeconds % 60)
    }
}
