import SwiftUI

struct SplashScreenView: View {
    @State private var glowIntensity: Double = 0
    @State private var showWhiteOverlay = false
    
    var onAnimationComplete: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            Image("bgIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 250, height: 250)
                // White glow shadow modulated by glowIntensity state
                .shadow(color: Color.white.opacity(glowIntensity), radius: glowIntensity * 30, x: 0, y: 0)
                .scaleEffect(glowIntensity * 0.5 + 1)  // slight scale-up with glow
            
            if showWhiteOverlay {
                Color.black
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .onAppear {
            // Animate glowIntensity from 0 to 1 over 3 seconds
            withAnimation(.easeInOut(duration: 3)) {
                glowIntensity = 1
            }
            
            // Delay showing white overlay till glow nearly max
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation(.easeIn(duration: 1.5)) {
                    showWhiteOverlay = true
                }
            }
            
            // Complete splash after white overlay fade-in
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
                onAnimationComplete()
            }
        }
    }
}
