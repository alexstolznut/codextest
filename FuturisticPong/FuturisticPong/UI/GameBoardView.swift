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
                .frame(width: 2)
                .padding(.vertical, 20)

            paddle(atX: viewModel.cpuPaddleX, y: GameConstants.paddleInset + GameConstants.paddleHeight / 2)
            paddle(atX: viewModel.playerPaddleX, y: GameConstants.boardSize.height - GameConstants.paddleInset - GameConstants.paddleHeight / 2)

            Circle()
                .fill(
                    RadialGradient(colors: [Color.white, Color.cyan], center: .center, startRadius: 0, endRadius: GameConstants.ballSize)
                )
                .frame(width: GameConstants.ballSize, height: GameConstants.ballSize)
                .position(viewModel.ballPosition)
                .shadow(color: .cyan, radius: 8)
        }
        .frame(width: GameConstants.boardSize.width, height: GameConstants.boardSize.height)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { gesture in
                    viewModel.movePlayerPaddle(to: gesture.location.x)
                }
        )
    }

    private func paddle(atX x: CGFloat, y: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(
                LinearGradient(
                    colors: [Color(red: 0.48, green: 0.9, blue: 1), Color(red: 0.2, green: 0.44, blue: 0.95)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: GameConstants.paddleWidth, height: GameConstants.paddleHeight)
            .position(x: x, y: y)
            .shadow(color: .blue.opacity(0.6), radius: 6)
    }
}
