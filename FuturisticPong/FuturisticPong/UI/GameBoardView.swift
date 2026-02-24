import SwiftUI

struct GameBoardView: View {
    @ObservedObject var viewModel: PongGameViewModel

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.cyan.opacity(0.45), lineWidth: 1)
                )

            Rectangle()
                .fill(Color.cyan.opacity(0.25))
                .frame(height: 2)
                .padding(.horizontal, 20)

            paddle(x: GameConfig.paddleInset + GameConfig.paddleSize.width / 2, y: viewModel.playerPaddleY)
            paddle(x: GameConfig.boardSize.width - GameConfig.paddleInset - GameConfig.paddleSize.width / 2, y: viewModel.cpuPaddleY)

            Circle()
                .fill(
                    RadialGradient(colors: [Color.white, Color.cyan], center: .center, startRadius: 0, endRadius: GameConfig.ballSize)
                )
                .frame(width: GameConfig.ballSize, height: GameConfig.ballSize)
                .position(viewModel.ballPosition)
                .shadow(color: .cyan, radius: 8)

            stateOverlay
        }
        .frame(width: GameConfig.boardSize.width, height: GameConfig.boardSize.height)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { gesture in
                    viewModel.movePlayerPaddle(to: gesture.location.y)
                }
        )
    }

    private var stateOverlay: some View {
        Group {
            switch viewModel.matchState {
            case .ready:
                overlayLabel("Tap Start")
            case .paused:
                overlayLabel("Paused")
            case .pointScored:
                overlayLabel("Point")
            case .gameOver(let winner):
                overlayLabel(winner == .left ? "You Win" : "AI Wins")
            case .playing:
                EmptyView()
            }
        }
    }

    private func overlayLabel(_ text: String) -> some View {
        Text(text)
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial, in: Capsule())
    }

    private func paddle(x: CGFloat, y: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(
                LinearGradient(
                    colors: [Color(red: 0.48, green: 0.9, blue: 1), Color(red: 0.2, green: 0.44, blue: 0.95)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: GameConfig.paddleSize.width, height: GameConfig.paddleSize.height)
            .position(x: x, y: y)
            .shadow(color: .blue.opacity(0.6), radius: 6)
    }
}
