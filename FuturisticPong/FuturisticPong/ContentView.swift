import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = PongGameViewModel()

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.04, green: 0.02, blue: 0.18), Color(red: 0.01, green: 0.01, blue: 0.08)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                ScoreHeaderView(playerScore: viewModel.playerScore, cpuScore: viewModel.cpuScore)
                GameBoardView(viewModel: viewModel)
                controls
                ControlHintView()
            }
            .padding()
        }
    }

    private var controls: some View {
        HStack(spacing: 14) {
            Button(action: primaryAction) {
                Text(primaryTitle)
                    .font(.subheadline.bold())
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .frame(minWidth: 90)
            }
            .buttonStyle(.borderedProminent)

            Button("Reset") {
                viewModel.restartMatch()
            }
            .buttonStyle(.bordered)
        }
    }

    private var primaryTitle: String {
        switch viewModel.matchState {
        case .playing:
            return "Pause"
        case .paused:
            return "Resume"
        case .gameOver:
            return "Play Again"
        default:
            return "Start"
        }
    }

    private func primaryAction() {
        switch viewModel.matchState {
        case .playing, .paused:
            viewModel.togglePause()
        case .gameOver:
            viewModel.restartMatch()
            viewModel.startMatch()
        case .ready, .pointScored:
            viewModel.startMatch()
        }
    }
}

#Preview {
    ContentView()
}
