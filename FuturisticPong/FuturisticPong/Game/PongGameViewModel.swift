import SwiftUI

final class PongGameViewModel: ObservableObject {
    @Published var playerScore = 0
    @Published var cpuScore = 0

    @Published var ballPosition: CGPoint
    @Published var ballTrail: [CGPoint] = []
    @Published var playerPaddleY: CGFloat
    @Published var cpuPaddleY: CGFloat
    @Published var matchState: MatchState = .ready
    @Published var playerStreak = 0
    @Published var speedBoostActive = false

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
        playerStreak = 0
        ballTrail.removeAll()
        speedBoostActive = false
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
        handle(events: engine.consumeEvents())
        syncFromEngine()
    }

    private func handle(events: [GameEvent]) {
        guard !events.isEmpty else { return }
        for event in events {
            switch event {
            case .paddleHit(let side):
                AudioManager.shared.playPaddleHit()
                if side == .left {
                    playerStreak += 1
                } else {
                    playerStreak = 0
                }
            case .wallHit:
                AudioManager.shared.playWallHit()
            case .score:
                AudioManager.shared.playScore()
                playerStreak = 0
            case .speedUp:
                AudioManager.shared.playSpeedUpAccent()
                speedBoostActive = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
                    self?.speedBoostActive = false
                }
            }
        }
    }

    private func syncFromEngine() {
        playerScore = engine.leftScore
        cpuScore = engine.rightScore

        if ballPosition != engine.ballPosition {
            ballTrail.append(ballPosition)
            if ballTrail.count > 8 {
                ballTrail.removeFirst(ballTrail.count - 8)
            }
        }

        ballPosition = engine.ballPosition
        playerPaddleY = engine.leftPaddleY
        cpuPaddleY = engine.rightPaddleY
        matchState = engine.matchState
    }
}
