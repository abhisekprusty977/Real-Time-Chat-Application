import SwiftUI

struct ContentView: View {
    @StateObject private var authManager = AuthenticationManager()
    @StateObject private var faceIDManager = FaceIDManager()
    
    // Persistent lock state
    @State private var isLocked = UserDefaults.standard.bool(forKey: "isAppLocked")
    var body: some View {
        ZStack {
                   if authManager.isLoading {
                       LoadingView()
                           .transition(.opacity)

                   } else if !authManager.isAuthenticated {
                       LoginView()
                           .environmentObject(authManager)
                           .transition(.move(edge: .leading))

                   } else {
                       if isLocked && !faceIDManager.isUnlocked {
                           // App is authenticated but locked → show Face ID screen
                           LockScreenView(faceIDManager: faceIDManager) {
                               faceIDManager.authenticate()
                           }
                           .transition(.opacity)
                       } else {
                           // Authenticated & unlocked → show chat rooms
                           ChatRoomListView()
                               .environmentObject(authManager)
                               .transition(.move(edge: .trailing))
                               .onAppear {
                                   // Optional: auto-lock on appear if saved locked state
                                   if UserDefaults.standard.bool(forKey: "isAppLocked") {
                                       isLocked = true
                                       faceIDManager.isUnlocked = false
                                   }
                               }
                       }
                   }
               }
               .animation(.easeInOut(duration: 0.5), value: authManager.isLoading)
               .animation(.easeInOut(duration: 0.5), value: authManager.isAuthenticated)
               .animation(.easeInOut(duration: 0.5), value: isLocked)
               // Listen for Face ID success → unlock & save
               .onReceive(faceIDManager.$isUnlocked) { unlocked in
                   if unlocked && isLocked {
                       isLocked = false
                       UserDefaults.standard.set(false, forKey: "isAppLocked")
                   }
               }
           }
    }



struct LoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "message.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("Chat Application")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                .scaleEffect(1.2)
            
            Text("Loading...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#if DEBUG
// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    
    class MockAuthManager: AuthenticationManager {
        override init() {
            super.init()
            // Set sample state for preview
            self.isLoading = false
            self.isAuthenticated = false // Change to true to preview ChatRoomListView
        }
    }
    
    static var previews: some View {
        Group {
            // Preview in loading state
            ContentView()
                .environmentObject(MockAuthManager())
                .previewDisplayName("Loading State")
            
            // Preview in authenticated state
            ContentView()
                .environmentObject({
                    let mock = MockAuthManager()
                    mock.isAuthenticated = true
                    return mock
                }())
                .previewDisplayName("Authenticated State")
            
            // Preview in login state
            ContentView()
                .environmentObject({
                    let mock = MockAuthManager()
                    mock.isAuthenticated = false
                    return mock
                }())
                .previewDisplayName("Login State")
        }
    }
}
#endif
