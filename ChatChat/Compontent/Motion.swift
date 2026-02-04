import SwiftUI

struct CredShimmerLoadingView: View {
    @State private var shimmerPhase: CGFloat = -1
    @State private var scale: CGFloat = 1.0

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            Circle()
                .fill(Color(white: 0.15))
                .frame(width: 200, height: 200)
                .scaleEffect(scale) // pulse scale effect
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        .blur(radius: 2)
                        .offset(x: 4, y: 4)
                        .mask(
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.black, .clear]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                )
                .overlay(
                    GeometryReader { geo in
                        let width = geo.size.width
                        let gradient = LinearGradient(
                            colors: [
                                Color.white.opacity(0.3),
                                Color.white.opacity(0.9),
                                Color.white.opacity(0.3)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        
                        Circle()
                            .fill(gradient)
                            .frame(width: width / 4)
                            .rotationEffect(.degrees(25))
                            .offset(x: shimmerPhase * width, y: 0)
                            .blur(radius: 25)
                    }
                    .mask(Circle())
                )
                .shadow(color: Color.white.opacity(0.15), radius: 20, x: 0, y: 0)
                .scaleEffect(1.02) // subtle overall scale for glow
                .animation(
                    Animation.linear(duration: 1.8)
                        .repeatForever(autoreverses: false),
                    value: shimmerPhase
                )
                .onAppear {
                    shimmerPhase = 1
                    animatePulse()
                }
        }
    }
    
    private func animatePulse() {
        // Animate scale between 1.0 and 1.05 to simulate inhale-exhale
        withAnimation(Animation.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
            scale = 1.05
        }
    }
}

struct CredShimmerLoadingView_Previews: PreviewProvider {
    static var previews: some View {
        CredShimmerLoadingView()
    }
}
