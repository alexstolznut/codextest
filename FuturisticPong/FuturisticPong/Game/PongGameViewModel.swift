import SwiftUI

final class PongGameViewModel: ObservableObject {
    @Published var playerScore = 0
    @Published var cpuScore = 0

    @Published var ballPosition: CGPoint
    @Published var playerPaddleY: CGFloat
    @Published var cpuPaddleY: CGFloat
    @Published var matchState: MatchState = .ready

    private var gameLoop: Timer?
    private var engine = GameEngine()

    init() {
        ballPosition = CGPoint(x: GameConfig.boardSize.width / 2, y: GameConfig.boardSize.height / 2)
        playerPaddleY = GameConfig.boardSize.height / 2
        cpuPaddleY = GameConfig.boardSize.height / 2
        syncFromEngine()
        startGameLoop()
    }

    deinit {
        gameLoop?.invalidate()
    }

    func movePlayerPaddle(to yPosition: CGFloat) {
        engine.moveLeftPaddle(toward: yPosition, deltaTime: 1.0 / 60.0)
        syncFromEngine()
    }

    func startMatch() {
        engine.startMatchIfNeeded()
        syncFromEngine()
    }

    func togglePause() {
        engine.togglePause()
        syncFromEngine()
    }

    func restartMatch() {
        engine.restartMatch()
        syncFromEngine()
    }

    private func startGameLoop() {
        gameLoop = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            self?.updateGame()
        }
    }

    private func updateGame() {
        engine.update(deltaTime: 1.0 / 60.0)
        syncFromEngine()
    }

    private func syncFromEngine() {
        playerScore = engine.leftScore
        cpuScore = engine.rightScore
        ballPosition = engine.ballPosition
        playerPaddleY = engine.leftPaddleY
        cpuPaddleY = engine.rightPaddleY
        matchState = engine.matchState
    }
}
