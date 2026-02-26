import SwiftUI

enum UITheme {
    static let backgroundTop = Color(red: 0.05, green: 0.05, blue: 0.16)
    static let backgroundBottom = Color(red: 0.01, green: 0.01, blue: 0.08)
    static let neonCyan = Color(red: 0.38, green: 0.96, blue: 1.0)
    static let neonBlue = Color(red: 0.33, green: 0.53, blue: 1.0)
    static let neonMagenta = Color(red: 0.95, green: 0.45, blue: 1.0)
}

struct AnimatedBackdropView: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            LinearGradient(colors: [UITheme.backgroundTop, UITheme.backgroundBottom], startPoint: .topLeading, endPoint: .bottomTrailing)

            RadialGradient(colors: [UITheme.neonBlue.opacity(0.32), .clear], center: animate ? .topLeading : .center, startRadius: 40, endRadius: 360)
                .blendMode(.screen)

            RadialGradient(colors: [UITheme.neonMagenta.opacity(0.2), .clear], center: animate ? .bottomTrailing : .trailing, startRadius: 40, endRadius: 340)
                .blendMode(.screen)

            NoiseOverlay()
                .opacity(0.09)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 4.2).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
        .ignoresSafeArea()
    }
}

private struct NoiseOverlay: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: false)) { context in
            Canvas { canvas, size in
                let t = context.date.timeIntervalSinceReferenceDate
                for i in 0..<130 {
                    let x = CGFloat((sin(t * 2.4 + Double(i) * 0.91) + 1) * 0.5) * size.width
                    let y = CGFloat((cos(t * 1.9 + Double(i) * 1.13) + 1) * 0.5) * size.height
                    let alpha = 0.03 + CGFloat((sin(t + Double(i)) + 1) * 0.5) * 0.04
                    canvas.fill(Path(CGRect(x: x, y: y, width: 2, height: 2)), with: .color(.white.opacity(alpha)))
                }
            }
        }
        .allowsHitTesting(false)
    }
}

struct GlassCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(UITheme.neonCyan.opacity(0.35), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.25), radius: 14, y: 8)
    }
}

extension View {
    func glassCardStyle() -> some View {
        modifier(GlassCard())
    }
}
