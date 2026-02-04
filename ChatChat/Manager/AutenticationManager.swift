import SwiftUI
import FirebaseAuth
import GoogleSignIn
import FirebaseCore

class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = true  // Start with loading = true
    @Published var errorMessage = ""
    
    init() {
        // Listen for authentication state changes
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.currentUser = user
                self?.isAuthenticated = (user != nil)
                self?.isLoading = false
                
                if let user = user {
                    print("User is authenticated: \(user.displayName ?? "Unknown")")
                    print("User ID: \(user.uid)")
                    print("Email: \(user.email ?? "No email")")
                } else {
                    print(" No authenticated user")
                }
            }
        }
    }
    
    func signInWithGoogle() {
        isLoading = true
        errorMessage = ""
        
        guard let presentingViewController = getRootViewController() else {
            errorMessage = "Could not get root view controller"
            isLoading = false
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    self?.isLoading = false
                    print(" Google Sign-In error: \(error.localizedDescription)")
                    return
                }
                
                guard let user = result?.user,
                      let idToken = user.idToken?.tokenString else {
                    self?.errorMessage = "Failed to get user information"
                    self?.isLoading = false
                    print("Failed to get user token")
                    return
                }
                
                let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                             accessToken: user.accessToken.tokenString)
                
                Auth.auth().signIn(with: credential) { authResult, error in
                    if let error = error {
                        DispatchQueue.main.async {
                            self?.errorMessage = error.localizedDescription
                            self?.isLoading = false
                        }
                        print(" Firebase auth error: \(error.localizedDescription)")
                    } else {
                        print(" Firebase authentication successful!")
                        // The auth state listener will automatically navigate to ChatRoomListView
                    }
                }
            }
        }
    }
    
    // Regular sign out (with loading state)
    func signOut() {
        isLoading = true
        
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
            print(" User signed out successfully")
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
                print(" Sign out error: \(error.localizedDescription)")
            }
        }
    }
    
    // Immediate sign out (no loading state, instant navigation)
    func signOutImmediately() {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
            
            // Immediately update state for instant navigation
            DispatchQueue.main.async {
                self.currentUser = nil
                self.isAuthenticated = false
                self.isLoading = false
                self.errorMessage = ""
                print("✅ User signed out immediately")
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                print(" Sign out error: \(error.localizedDescription)")
            }
        }
    }
    
    private func getRootViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return nil
        }
        return window.rootViewController
    }
}
