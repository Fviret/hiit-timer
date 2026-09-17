import SwiftUI
import UIKit

struct RoundsStepperCard: View {
    @Binding var rounds: Int

    var body: some View {
        VStack(spacing: 14) {
            HStack {
                Label("Tours", systemImage: "repeat")
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
                Text("\(rounds)")
                    .font(.system(.title2, design: .rounded).monospacedDigit().weight(.bold))
                    .foregroundStyle(.pink)
            }
            HStack(spacing: 16) {
                stepButton(symbol: "minus") { rounds = max(1, rounds - 1) }
                Slider(
                    value: Binding(
                        get: { Double(rounds) },
                        set: { rounds = Int($0) }
                    ),
                    in: 1...40,
                    step: 1
                )
                .tint(.pink)
                stepButton(symbol: "plus") { rounds = min(40, rounds + 1) }
            }
        }
        .padding(18)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 20))
    }

    private func stepButton(symbol: String, action: @escaping () -> Void) -> some View {
        Button {
            action()
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } label: {
            Image(systemName: symbol)
                .font(.headline)
                .frame(width: 38, height: 38)
                .background(Color.pink.opacity(0.25), in: Circle())
                .foregroundStyle(.pink)
        }
    }
}
