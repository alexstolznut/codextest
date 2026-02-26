import SwiftUI

struct NeonPaddleView: View {
    let isPlayer: Bool

    var body: some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(
                LinearGradient(colors: [UITheme.neonCyan, UITheme.neonBlue], startPoint: .top, endPoint: .bottom)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(.white.opacity(0.45), lineWidth: 1)
            )
            .shadow(color: UITheme.neonCyan.opacity(0.9), radius: 10)
            .overlay(alignment: isPlayer ? .trailing : .leading) {
                Capsule()
                    .fill(UITheme.neonMagenta.opacity(0.28))
                    .frame(width: 6)
                    .blur(radius: 2)
                    .padding(.vertical, 10)
            }
    }
}
