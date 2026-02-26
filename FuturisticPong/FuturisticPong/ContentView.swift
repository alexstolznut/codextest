import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = PongGameViewModel()

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                AnimatedBackdropView()

                VStack(spacing: 16) {
                    ScoreHeaderView(
                        playerScore: viewModel.playerScore,
                        cpuScore: viewModel.cpuScore,
                        streakCount: viewModel.playerStreak,
                        speedBoostActive: viewModel.speedBoostActive
                    )

                    GameBoardView(viewModel: viewModel, rematchAction: quickRematch)
                        .scaleEffect(boardScale(in: proxy.size), anchor: .top)

                    controls
                    ControlHintView()
                }
                .padding(.horizontal, 12)
                .padding(.top, proxy.safeAreaInsets.top + 6)
                .padding(.bottom, max(proxy.safeAreaInsets.bottom, 12))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
    }

    private var controls: some View {
        HStack(spacing: 14) {
            Button(action: primaryAction) {
                Text(primaryTitle)
                    .font(.subheadline.bold())
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .frame(minWidth: 90)
            }
            .buttonStyle(.borderedProminent)
            .tint(UITheme.neonBlue)

            Button("Reset") {
                viewModel.restartMatch()
            }
            .buttonStyle(.bordered)
            .tint(UITheme.neonCyan)
        }
    }

    private func boardScale(in size: CGSize) -> CGFloat {
        let widthScale = max(0.74, (size.width - 24) / GameConfig.boardSize.width)
        let heightScale = max(0.64, (size.height * 0.66) / GameConfig.boardSize.height)
        return min(widthScale, heightScale, 1)
    }

    private var primaryTitle: String {
        switch viewModel.matchState {
        case .playing:
            return "Pause"
        case .paused:
            return "Resume"
        case .gameOver:
            return "Play Again"
        default:
            return "Start"
        }
    }

    private func primaryAction() {
        switch viewModel.matchState {
        case .playing, .paused:
            viewModel.togglePause()
        case .gameOver:
            quickRematch()
        case .ready, .pointScored:
            viewModel.startMatch()
        }
    }

    private func quickRematch() {
        viewModel.restartMatch()
        viewModel.startMatch()
    }
}

#Preview {
    ContentView()
}
