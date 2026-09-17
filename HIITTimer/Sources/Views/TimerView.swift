import SwiftUI
import UIKit

struct TimerView: View {
    @StateObject private var engine: WorkoutTimerEngine
    @Environment(\.dismiss) private var dismiss

    init(session: WorkoutSession) {
        _engine = StateObject(wrappedValue: WorkoutTimerEngine(session: session))
    }

    var body: some View {
        ZStack {
            Theme.gradient(for: engine.phase)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.4), value: engine.phase)

            VStack(spacing: 32) {
                topBar
                Spacer()
                phaseLabel
                timerRing
                roundIndicator
                Spacer()
                controls
            }
            .padding(24)
        }
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
            engine.start()
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
            engine.cancel()
        }
        .navigationBarBackButtonHidden(true)
    }

    private var topBar: some View {
        HStack {
            Text(engine.session.name)
                .font(.headline)
                .foregroundStyle(.white.opacity(0.85))
            Spacer()
            Button {
                engine.cancel()
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.white.opacity(0.85))
            }
        }
    }

    private var phaseLabel: some View {
        Text(engine.phase.label.uppercased())
            .font(.system(size: 22, weight: .heavy, design: .rounded))
            .kerning(2)
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(.white.opacity(0.15), in: Capsule())
    }

    private var timerRing: some View {
        ZStack {
            ProgressRingView(progress: engine.progress, color: .white)
                .frame(width: 260, height: 260)
            VStack(spacing: 4) {
                Text(timeString(engine.remainingSeconds))
                    .font(.system(size: 64, weight: .bold, design: .rounded).monospacedDigit())
                    .foregroundStyle(.white)
                if engine.phase == .finished {
                    Text("Bravo 💪")
                        .font(.title3.bold())
                        .foregroundStyle(.white.opacity(0.9))
                }
            }
        }
    }

    private var roundIndicator: some View {
        Group {
            if engine.phase == .work || engine.phase == .rest {
                Text("Tour \(engine.currentRound) / \(engine.session.rounds)")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.9))
            }
        }
    }

    private var controls: some View {
        Group {
            if engine.phase == .finished {
                Button {
                    dismiss()
                } label: {
                    Text("Terminer")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.white, in: RoundedRectangle(cornerRadius: 18))
                        .foregroundStyle(.black)
                }
            } else {
                HStack(spacing: 20) {
                    controlButton(icon: engine.isPaused ? "play.fill" : "pause.fill") {
                        engine.isPaused ? engine.resume() : engine.pause()
                    }
                    controlButton(icon: "forward.end.fill") {
                        engine.skipPhase()
                    }
                    controlButton(icon: "stop.fill") {
                        engine.cancel()
                        dismiss()
                    }
                }
            }
        }
    }

    private func controlButton(icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title2)
                .frame(width: 64, height: 64)
                .background(.white.opacity(0.2), in: Circle())
                .foregroundStyle(.white)
        }
    }

    private func timeString(_ seconds: Int) -> String {
        String(format: "%d:%02d", seconds / 60, seconds % 60)
    }
}
