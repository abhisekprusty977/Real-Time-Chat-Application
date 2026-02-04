import SwiftUI

struct LoginView: View {
    @StateObject private var authManager = AuthenticationManager()
    
    var body: some View {
        VStack(spacing: 30) {
            // App Logo/Title
            VStack(spacing: 10) {
                Image(systemName: "message.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("Chat Application")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Connect with friends in real-time")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Google Sign-In Button
            Button(action: {
                authManager.signInWithGoogle()
            }) {
                HStack {
                    Image(systemName: "globe")
                        .font(.title2)
                    
                    Text("Continue with Google")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(authManager.isLoading)
            
            if authManager.isLoading {
                ProgressView("Signing in...")
                    .padding()
            }
            
            if !authManager.errorMessage.isEmpty {
                Text(authManager.errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            
            Spacer()
            
            Text("By signing in, you agree to our Terms of Service and Privacy Policy")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

