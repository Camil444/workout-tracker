import SwiftUI

struct ConfettiPiece: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    let size: CGFloat
    let color: Color
    let rotation: Double
    let speed: Double
    let wobble: Double
}

struct ConfettiView: View {
    let isActive: Bool
    @State private var pieces: [ConfettiPiece] = []
    @State private var animating = false

    private let colors: [Color] = [
        .yellow, .green, .blue, .red, .orange, .pink, .purple, .cyan
    ]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(pieces) { piece in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(piece.color)
                        .frame(width: piece.size, height: piece.size * 0.6)
                        .rotationEffect(.degrees(animating ? piece.rotation + 360 : piece.rotation))
                        .position(
                            x: piece.x + (animating ? CGFloat(piece.wobble) * 30 : 0),
                            y: animating ? geo.size.height + 50 : piece.y
                        )
                        .opacity(animating ? 0 : 1)
                }
            }
            .onChange(of: isActive) { _, active in
                if active {
                    spawnConfetti(in: geo.size)
                }
            }
        }
        .allowsHitTesting(false)
    }

    private func spawnConfetti(in size: CGSize) {
        pieces = (0..<60).map { _ in
            ConfettiPiece(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: -100...(-20)),
                size: CGFloat.random(in: 6...12),
                color: colors.randomElement() ?? .yellow,
                rotation: Double.random(in: 0...360),
                speed: Double.random(in: 1.5...3.0),
                wobble: Double.random(in: -1...1)
            )
        }
        animating = false

        withAnimation(.easeIn(duration: 2.5)) {
            animating = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            pieces = []
            animating = false
        }
    }
}

struct PRCelebrationOverlay: View {
    @Environment(ThemeManager.self) private var theme
    let exerciseName: String
    let value: String
    let isShowing: Bool
    let onDismiss: () -> Void

    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0

    var body: some View {
        if isShowing {
            ZStack {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .onTapGesture { onDismiss() }

                ConfettiView(isActive: isShowing)

                VStack(spacing: 16) {
                    Text("NOUVEAU RECORD")
                        .font(.caption)
                        .fontWeight(.heavy)
                        .tracking(3)
                        .foregroundStyle(theme.accentColor)

                    Text("PR")
                        .font(.system(size: 60, weight: .black))
                        .foregroundStyle(theme.accentColor)

                    Text(exerciseName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)

                    Text(value)
                        .font(.system(size: 44, weight: .black))
                        .foregroundStyle(theme.accentColor)

                    Button {
                        onDismiss()
                    } label: {
                        Text("OK")
                            .fontWeight(.bold)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 12)
                            .background(theme.accentColor)
                            .foregroundStyle(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.top, 8)
                }
                .scaleEffect(scale)
                .opacity(opacity)
            }
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    scale = 1
                    opacity = 1
                }
            }
        }
    }
}
