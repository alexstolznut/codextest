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
                ControlHintView()
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
