import SwiftUI

struct ScoreHeaderView: View {
    let playerScore: Int
    let cpuScore: Int
    let streakCount: Int
    let speedBoostActive: Bool

    var body: some View {
        ScoreHUDView(
            playerScore: playerScore,
            cpuScore: cpuScore,
            streakCount: streakCount,
            speedBoostActive: speedBoostActive
        )
        .padding(.horizontal, 4)
    }
}
