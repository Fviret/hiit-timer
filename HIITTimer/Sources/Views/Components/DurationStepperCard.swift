import SwiftUI
import UIKit

struct DurationStepperCard: View {
    let title: String
    let systemImage: String
    @Binding var seconds: Int
    var step: Int = 5
    var minimum: Int = 0
    var maximum: Int = 600
    var accent: Color = .orange

    var body: some View {
        VStack(spacing: 14) {
            HStack {
                Label(title, systemImage: systemImage)
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
                Text(formatted)
                    .font(.system(.title2, design: .rounded).monospacedDigit().weight(.bold))
                    .foregroundStyle(accent)
            }
            HStack(spacing: 16) {
                stepButton(symbol: "minus") {
                    seconds = max(minimum, seconds - step)
                }
                Slider(
                    value: Binding(
                        get: { Double(seconds) },
                        set: { seconds = Int($0) }
                    ),
                    in: Double(minimum)...Double(maximum),
                    step: Double(step)
                )
                .tint(accent)
                stepButton(symbol: "plus") {
                    seconds = min(maximum, seconds + step)
                }
            }
        }
        .padding(18)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 20))
    }

    private var formatted: String {
        String(format: "%d:%02d", seconds / 60, seconds % 60)
    }

    private func stepButton(symbol: String, action: @escaping () -> Void) -> some View {
        Button {
            action()
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } label: {
            Image(systemName: symbol)
                .font(.headline)
                .frame(width: 38, height: 38)
                .background(accent.opacity(0.25), in: Circle())
                .foregroundStyle(accent)
        }
    }
}
