import SwiftUI

struct GameBoardView: View {
    @ObservedObject var viewModel: PongGameViewModel
    let rematchAction: () -> Void

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(UITheme.neonCyan.opacity(0.45), lineWidth: 1)
                )

            Rectangle()
                .fill(UITheme.neonCyan.opacity(0.22))
                .frame(height: 2)
                .padding(.horizontal, 20)

            paddle(x: GameConfig.paddleInset + GameConfig.paddleSize.width / 2, y: viewModel.playerPaddleY, isPlayer: true)
            paddle(x: GameConfig.boardSize.width - GameConfig.paddleInset - GameConfig.paddleSize.width / 2, y: viewModel.cpuPaddleY, isPlayer: false)

            NeonBallView(ballPosition: viewModel.ballPosition, trail: viewModel.ballTrail)

            SessionOverlayView(state: viewModel.matchState, rematchAction: rematchAction)
        }
        .frame(width: GameConfig.boardSize.width, height: GameConfig.boardSize.height)
        .glassCardStyle()
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { gesture in
                    viewModel.movePlayerPaddle(to: gesture.location.y)
                }
        )
    }

    private func paddle(x: CGFloat, y: CGFloat, isPlayer: Bool) -> some View {
        NeonPaddleView(isPlayer: isPlayer)
            .frame(width: GameConfig.paddleSize.width, height: GameConfig.paddleSize.height)
            .position(x: x, y: y)
    }
}
