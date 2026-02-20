import SwiftUI

struct ScoreHeaderView: View {
    let playerScore: Int
    let cpuScore: Int

    var body: some View {
        HStack {
            scoreColumn(title: "CPU", score: cpuScore)
            Spacer()
            Text("Futuristic Pong")
                .font(.headline)
                .foregroundStyle(Color.cyan.opacity(0.9))
            Spacer()
            scoreColumn(title: "YOU", score: playerScore)
        }
        .padding(.horizontal, 24)
    }

    private func scoreColumn(title: String, score: Int) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))
            Text("\(score)")
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)
        }
    }
}
