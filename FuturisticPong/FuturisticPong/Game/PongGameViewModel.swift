import SwiftUI

final class PongGameViewModel: ObservableObject {
    @Published var playerScore = 0
    @Published var cpuScore = 0

    @Published var ballPosition: CGPoint
    @Published var ballVelocity: CGVector
    @Published var playerPaddleX: CGFloat = GameConstants.boardSize.width / 2
    @Published var cpuPaddleX: CGFloat = GameConstants.boardSize.width / 2

    private var gameLoop: Timer?

    init() {
        ballPosition = CGPoint(x: GameConstants.boardSize.width / 2, y: GameConstants.boardSize.height / 2)
        ballVelocity = CGVector(dx: GameConstants.initialBallSpeed, dy: GameConstants.initialBallSpeed)
        startGameLoop()
    }

    deinit {
        gameLoop?.invalidate()
    }

    func movePlayerPaddle(to xPosition: CGFloat) {
        playerPaddleX = max(GameConstants.paddleWidth / 2,
                            min(GameConstants.boardSize.width - GameConstants.paddleWidth / 2, xPosition))
    }

    private func startGameLoop() {
        gameLoop = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            self?.updateGame()
        }
    }

    private func updateGame() {
        ballPosition.x += ballVelocity.dx
        ballPosition.y += ballVelocity.dy

        if ballPosition.x <= GameConstants.ballSize / 2 || ballPosition.x >= GameConstants.boardSize.width - GameConstants.ballSize / 2 {
            ballVelocity.dx *= -1
        }

        let cpuTarget = ballPosition.x
        cpuPaddleX += (cpuTarget - cpuPaddleX) * GameConstants.cpuTrackingFactor
        cpuPaddleX = max(GameConstants.paddleWidth / 2,
                         min(GameConstants.boardSize.width - GameConstants.paddleWidth / 2, cpuPaddleX))

        checkPaddleCollision()
        checkScore()
    }

    private func checkPaddleCollision() {
        let cpuPaddleY = GameConstants.paddleInset + GameConstants.paddleHeight / 2
        let playerPaddleY = GameConstants.boardSize.height - GameConstants.paddleInset - GameConstants.paddleHeight / 2

        if ballVelocity.dy < 0,
           abs(ballPosition.y - cpuPaddleY) < GameConstants.paddleHeight,
           abs(ballPosition.x - cpuPaddleX) < (GameConstants.paddleWidth / 2 + GameConstants.ballSize / 2) {
            ballVelocity.dy = abs(ballVelocity.dy)
            addEnglish(from: cpuPaddleX)
        }

        if ballVelocity.dy > 0,
           abs(ballPosition.y - playerPaddleY) < GameConstants.paddleHeight,
           abs(ballPosition.x - playerPaddleX) < (GameConstants.paddleWidth / 2 + GameConstants.ballSize / 2) {
            ballVelocity.dy = -abs(ballVelocity.dy)
            addEnglish(from: playerPaddleX)
            AudioManager.shared.playPaddleHit()
        }
    }

    private func addEnglish(from paddleX: CGFloat) {
        let delta = (ballPosition.x - paddleX) / (GameConstants.paddleWidth / 2)
        ballVelocity.dx += delta * GameConstants.spinFactor
        ballVelocity.dx = max(-GameConstants.maxBallSpeed, min(GameConstants.maxBallSpeed, ballVelocity.dx))
    }

    private func checkScore() {
        if ballPosition.y < 0 {
            playerScore += 1
            AudioManager.shared.playScore()
            resetBall(direction: 1)
        } else if ballPosition.y > GameConstants.boardSize.height {
            cpuScore += 1
            resetBall(direction: -1)
        }
    }

    private func resetBall(direction: CGFloat) {
        ballPosition = CGPoint(x: GameConstants.boardSize.width / 2, y: GameConstants.boardSize.height / 2)
        ballVelocity = CGVector(dx: CGFloat.random(in: -GameConstants.initialBallSpeed...GameConstants.initialBallSpeed),
                                dy: direction * GameConstants.initialBallSpeed)
    }
}
