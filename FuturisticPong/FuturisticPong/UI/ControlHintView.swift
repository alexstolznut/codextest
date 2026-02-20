import SwiftUI

struct ControlHintView: View {
    var body: some View {
        Text("Drag anywhere on the board to move your paddle")
            .font(.footnote)
            .foregroundStyle(.white.opacity(0.7))
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(.ultraThinMaterial, in: Capsule())
    }
}
