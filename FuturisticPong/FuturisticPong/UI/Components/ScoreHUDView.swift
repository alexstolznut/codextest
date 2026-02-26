import SwiftUI

struct ScoreHUDView: View {
    let playerScore: Int
    let cpuScore: Int
    let streakCount: Int
    let speedBoostActive: Bool

    var body: some View {
        HStack(spacing: 12) {
            scoreCard(title: "AI", score: cpuScore, tone: UITheme.neonMagenta)
            VStack(spacing: 6) {
                Text("FUTURISTIC PONG")
                    .font(.caption.weight(.semibold))
                    .tracking(1.2)
                    .foregroundStyle(.white.opacity(0.88))

                if streakCount >= 2 {
                    Label("Streak x\(streakCount)", systemImage: "flame.fill")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(UITheme.neonMagenta)
                        .transition(.scale.combined(with: .opacity))
                }

                if speedBoostActive {
                    Text("SPEED UP")
                        .font(.caption2.weight(.black))
                        .foregroundStyle(UITheme.neonCyan)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(UITheme.neonCyan.opacity(0.16), in: Capsule())
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .frame(maxWidth: .infinity)
            .animation(.spring(response: 0.35, dampingFraction: 0.7), value: streakCount)
            .animation(.easeOut(duration: 0.2), value: speedBoostActive)

            scoreCard(title: "YOU", score: playerScore, tone: UITheme.neonCyan)
        }
    }

    private func scoreCard(title: String, score: Int, tone: Color) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.74))
            Text("\(score)")
                .font(.title2.weight(.heavy))
                .monospacedDigit()
                .contentTransition(.numericText())
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(minWidth: 76)
        .glassCardStyle()
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(tone.opacity(0.33), lineWidth: 1)
        )
        .shadow(color: tone.opacity(0.4), radius: 8)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: score)
    }
}
