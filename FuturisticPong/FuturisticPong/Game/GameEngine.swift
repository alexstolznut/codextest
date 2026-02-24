import CoreGraphics

enum MatchState: Equatable {
    case ready
    case playing
    case paused
    case pointScored
    case gameOver(winner: PlayerSide)
}

enum PlayerSide {
    case left
    case right
}

struct GameEngine {
    private(set) var leftScore = 0
    private(set) var rightScore = 0

    private(set) var ballPosition: CGPoint
    private(set) var ballVelocity: CGVector = .zero
    private(set) var leftPaddleY: CGFloat
    private(set) var rightPaddleY: CGFloat
    private(set) var matchState: MatchState = .ready

    private var pointResetTimer: CGFloat = 0
    private var aiReactionTimer: CGFloat = 0
    private var rallyCount = 0

    init() {
        let centerY = GameConfig.boardSize.height / 2
        leftPaddleY = centerY
        rightPaddleY = centerY
        ballPosition = CGPoint(x: GameConfig.boardSize.width / 2, y: centerY)
    }

    mutating func startMatchIfNeeded() {
        guard matchState == .ready || matchState == .paused else { return }
        matchState = .playing
        if ballVelocity == .zero {
            serve(toward: Bool.random() ? .left : .right)
        }
    }

    mutating func togglePause() {
        switch matchState {
        case .playing:
            matchState = .paused
        case .paused:
            matchState = .playing
        default:
            break
        }
    }

    mutating func restartMatch() {
        leftScore = 0
        rightScore = 0
        resetForPoint()
        matchState = .ready
    }

    mutating func moveLeftPaddle(toward y: CGFloat, deltaTime: CGFloat) {
        let clamped = y.clamped(to: paddleYRange)
        let delta = clamped - leftPaddleY
        let maxStep = GameConfig.playerMaxPaddleSpeed * deltaTime
        leftPaddleY += delta.clamped(to: -maxStep...maxStep)
        leftPaddleY = leftPaddleY.clamped(to: paddleYRange)
    }

    mutating func update(deltaTime: CGFloat) {
        guard deltaTime > 0 else { return }

        if matchState == .pointScored {
            pointResetTimer -= deltaTime
            if pointResetTimer <= 0 {
                matchState = .playing
                serve(toward: Bool.random() ? .left : .right)
            }
            return
        }

        guard matchState == .playing else { return }

        updateAIPaddle(deltaTime: deltaTime)

        ballPosition.x += ballVelocity.dx * deltaTime
        ballPosition.y += ballVelocity.dy * deltaTime

        handleWallBounce()
        handlePaddleCollisions()
        handleScoringIfNeeded()
    }

    private mutating func serve(toward side: PlayerSide) {
        let direction: CGFloat = side == .right ? 1 : -1
        let randomY = CGFloat.random(in: -0.55...0.55)
        let raw = CGVector(dx: direction, dy: randomY)
        let normalized = normalize(raw)
        ballVelocity = CGVector(
            dx: normalized.dx * GameConfig.initialBallSpeed,
            dy: normalized.dy * GameConfig.initialBallSpeed
        )
    }

    private mutating func resetForPoint() {
        ballPosition = CGPoint(x: GameConfig.boardSize.width / 2, y: GameConfig.boardSize.height / 2)
        ballVelocity = .zero
        rallyCount = 0
        pointResetTimer = 0
    }

    private mutating func updateAIPaddle(deltaTime: CGFloat) {
        aiReactionTimer -= deltaTime
        guard aiReactionTimer <= 0 else { return }

        let predictedY = predictedBallYAtRightPaddle()
        let scoreFactor = max(0, CGFloat(leftScore - rightScore)) * GameConfig.aiDifficultyScale
        let rallyFactor = CGFloat(rallyCount) * (GameConfig.aiDifficultyScale * 0.35)

        let dynamicDelay = max(0.01, GameConfig.aiReactionDelay - scoreFactor * 0.01)
        aiReactionTimer = dynamicDelay

        let speedScale = 1 + scoreFactor + rallyFactor
        let maxStep = min(
            GameConfig.aiMaxPaddleSpeed * speedScale * deltaTime,
            GameConfig.aiMaxPaddleSpeed * 1.7 * deltaTime
        )

        let delta = (predictedY - rightPaddleY).clamped(to: -maxStep...maxStep)
        rightPaddleY = (rightPaddleY + delta).clamped(to: paddleYRange)
    }

    private mutating func handleWallBounce() {
        let radius = GameConfig.ballSize / 2
        if ballPosition.y <= radius {
            ballPosition.y = radius
            ballVelocity.dy = abs(ballVelocity.dy)
        } else if ballPosition.y >= GameConfig.boardSize.height - radius {
            ballPosition.y = GameConfig.boardSize.height - radius
            ballVelocity.dy = -abs(ballVelocity.dy)
        }
    }

    private mutating func handlePaddleCollisions() {
        let radius = GameConfig.ballSize / 2
        let halfPaddleHeight = GameConfig.paddleSize.height / 2
        let halfPaddleWidth = GameConfig.paddleSize.width / 2
        let leftPaddleX = GameConfig.paddleInset + halfPaddleWidth
        let rightPaddleX = GameConfig.boardSize.width - GameConfig.paddleInset - halfPaddleWidth

        if ballVelocity.dx < 0,
           ballPosition.x - radius <= leftPaddleX + halfPaddleWidth,
           abs(ballPosition.y - leftPaddleY) <= halfPaddleHeight + radius {
            ballPosition.x = leftPaddleX + halfPaddleWidth + radius
            reflectFromPaddle(paddleY: leftPaddleY, direction: 1)
        }

        if ballVelocity.dx > 0,
           ballPosition.x + radius >= rightPaddleX - halfPaddleWidth,
           abs(ballPosition.y - rightPaddleY) <= halfPaddleHeight + radius {
            ballPosition.x = rightPaddleX - halfPaddleWidth - radius
            reflectFromPaddle(paddleY: rightPaddleY, direction: -1)
        }
    }

    private mutating func reflectFromPaddle(paddleY: CGFloat, direction: CGFloat) {
        rallyCount += 1

        let relative = (ballPosition.y - paddleY) / (GameConfig.paddleSize.height / 2)
        let clamped = relative.clamped(to: -1...1)
        let speed = min(
            GameConfig.initialBallSpeed + CGFloat(rallyCount) * GameConfig.accelerationPerRally,
            GameConfig.maxBallSpeed
        )

        let vx = direction * speed
        let vy = clamped * speed * GameConfig.paddleDeflectionFactor
        ballVelocity = normalize(CGVector(dx: vx, dy: vy), magnitude: speed)
    }

    private mutating func handleScoringIfNeeded() {
        if ballPosition.x < 0 {
            rightScore += 1
            onPointScored()
        } else if ballPosition.x > GameConfig.boardSize.width {
            leftScore += 1
            onPointScored()
        }
    }

    private mutating func onPointScored() {
        if leftScore >= GameConfig.winningScore {
            matchState = .gameOver(winner: .left)
            resetForPoint()
        } else if rightScore >= GameConfig.winningScore {
            matchState = .gameOver(winner: .right)
            resetForPoint()
        } else {
            matchState = .pointScored
            pointResetTimer = GameConfig.pointResetDelay
            resetForPoint()
        }
    }

    private func predictedBallYAtRightPaddle() -> CGFloat {
        guard ballVelocity.dx > 0 else { return GameConfig.boardSize.height / 2 }

        let rightPaddleX = GameConfig.boardSize.width - GameConfig.paddleInset - GameConfig.paddleSize.width / 2
        let distanceX = rightPaddleX - ballPosition.x
        guard distanceX > 0 else { return ballPosition.y }

        let time = distanceX / max(ballVelocity.dx, 1)
        let projected = ballPosition.y + ballVelocity.dy * time

        let minY = GameConfig.ballSize / 2
        let maxY = GameConfig.boardSize.height - GameConfig.ballSize / 2
        let range = maxY - minY
        guard range > 0 else { return ballPosition.y }

        let shifted = (projected - minY).truncatingRemainder(dividingBy: range * 2)
        let wrapped = shifted < 0 ? shifted + range * 2 : shifted
        let reflected = wrapped > range ? (range * 2 - wrapped) : wrapped
        return (minY + reflected).clamped(to: paddleYRange)
    }

    private func normalize(_ vector: CGVector, magnitude: CGFloat = 1) -> CGVector {
        let length = sqrt(vector.dx * vector.dx + vector.dy * vector.dy)
        guard length > 0 else {
            return CGVector(dx: magnitude, dy: 0)
        }

        return CGVector(dx: vector.dx / length * magnitude, dy: vector.dy / length * magnitude)
    }

    private var paddleYRange: ClosedRange<CGFloat> {
        let halfHeight = GameConfig.paddleSize.height / 2
        return halfHeight...(GameConfig.boardSize.height - halfHeight)
    }
}

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
