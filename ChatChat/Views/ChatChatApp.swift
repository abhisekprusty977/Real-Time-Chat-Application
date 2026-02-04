import SwiftUI
import FirebaseCore
import GoogleSignIn

@main
struct ChatChatApp: App {
    @StateObject private var authManager = AuthenticationManager()
    @StateObject private var faceIDManager = FaceIDManager()
    @State private var circleScale: CGFloat = 1
    @State private var circleOpacity: Double = 1
    
    @State private var isLocked = UserDefaults.standard.bool(forKey: "isAppLocked")
    @State private var showSplash = true // New state for splash screen control
    
    @State private var splashOpacity: Double = 0      // For fade‑in
    @State private var splashScale: CGFloat = 0.9
    
    init() {
        FirebaseApp.configure()
        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
           let plist = NSDictionary(contentsOfFile: path),
           let clientId = plist["CLIENT_ID"] as? String {
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientId)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
                    SplashScreenView {
                        // Splash animation complete
                        
                        withAnimation {
                            showSplash = false
                            
                        }
                    }
                    .transition(.opacity)
                }else {
                    if authManager.isAuthenticated {
                        if isLocked && !faceIDManager.isUnlocked {
                            LockScreenView(faceIDManager: faceIDManager) {
                                faceIDManager.authenticate()
                            }
                            .transition(.opacity)
                        } else {
                            AnyView(
                                MainTabView()
                                    .environmentObject(authManager)
                            )
                        }
                    } else {
                        LoginView()
                            .environmentObject(authManager)
                    }
                }
            }
           
            .onReceive(faceIDManager.$isUnlocked) { unlocked in
                if unlocked && isLocked {
                    isLocked = false
                    UserDefaults.standard.set(false, forKey: "isAppLocked")
                }
            }
        }
    }
}
