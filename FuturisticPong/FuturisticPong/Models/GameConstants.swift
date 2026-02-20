import CoreGraphics

enum GameConstants {
    static let boardSize = CGSize(width: 340, height: 540)

    static let paddleWidth: CGFloat = 96
    static let paddleHeight: CGFloat = 14
    static let paddleInset: CGFloat = 28

    static let ballSize: CGFloat = 16
    static let initialBallSpeed: CGFloat = 4.5
    static let maxBallSpeed: CGFloat = 8
    static let spinFactor: CGFloat = 0.35
    static let cpuTrackingFactor: CGFloat = 0.075
}
