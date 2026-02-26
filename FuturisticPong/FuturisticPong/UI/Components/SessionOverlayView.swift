import SwiftUI

struct SessionOverlayView: View {
    let state: MatchState
    let rematchAction: () -> Void

    var body: some View {
        Group {
            switch state {
            case .ready:
                label("Tap Start")
            case .paused:
                label("Paused")
            case .pointScored:
                label("Point")
            case .gameOver(let winner):
                VStack(spacing: 10) {
                    label(winner == .left ? "You Win" : "AI Wins")
                    Button("Quick Rematch", action: rematchAction)
                        .font(.subheadline.bold())
                        .buttonStyle(.borderedProminent)
                        .tint(UITheme.neonBlue)
                }
            case .playing:
                EmptyView()
            }
        }
    }

    private func label(_ text: String) -> some View {
        Text(text)
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .glassCardStyle()
    }
}
