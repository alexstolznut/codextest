import SwiftUI

struct NeonBallView: View {
    let ballPosition: CGPoint
    let trail: [CGPoint]

    var body: some View {
        ZStack {
            ForEach(Array(trail.enumerated()), id: \.offset) { index, point in
                Circle()
                    .fill(UITheme.neonCyan.opacity(Double(index + 1) / Double(max(trail.count, 1)) * 0.22))
                    .frame(width: GameConfig.ballSize * 0.8, height: GameConfig.ballSize * 0.8)
                    .position(point)
                    .blur(radius: 1.5)
            }

            Circle()
                .fill(
                    RadialGradient(colors: [.white, UITheme.neonCyan, UITheme.neonBlue], center: .center, startRadius: 1, endRadius: GameConfig.ballSize)
                )
                .frame(width: GameConfig.ballSize, height: GameConfig.ballSize)
                .position(ballPosition)
                .shadow(color: UITheme.neonCyan.opacity(0.95), radius: 12)
        }
        .allowsHitTesting(false)
    }
}
