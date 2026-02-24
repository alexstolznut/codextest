import CoreGraphics

enum GameConfig {
    static let boardSize = CGSize(width: 340, height: 540)

    static let paddleSize = CGSize(width: 14, height: 96)
    static let paddleInset: CGFloat = 28
    static let playerMaxPaddleSpeed: CGFloat = 760

    static let ballSize: CGFloat = 16
    static let initialBallSpeed: CGFloat = 300
    static let maxBallSpeed: CGFloat = 620
    static let accelerationPerRally: CGFloat = 18
    static let paddleDeflectionFactor: CGFloat = 0.9

    static let aiMaxPaddleSpeed: CGFloat = 480
    static let aiReactionDelay: CGFloat = 0.06
    static let aiDifficultyScale: CGFloat = 0.12

    static let pointResetDelay: CGFloat = 0.85
    static let winningScore = 11
}
