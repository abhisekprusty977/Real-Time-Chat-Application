import UIKit
import FirebaseCore
import GoogleSignIn

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        // Optional: Configure Google Sign-In here if not configured elsewhere
        return true
    }
    
    // For Google Sign-In
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        // Handle URL for Google Sign-In
        return GIDSignIn.sharedInstance.handle(url)
    }
}
