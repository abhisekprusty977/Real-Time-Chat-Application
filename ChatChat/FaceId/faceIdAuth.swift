import Foundation
import LocalAuthentication
import Combine

class FaceIDManager: ObservableObject {
    @Published var isUnlocked = true  // Default to unlocked
    @Published var faceIDErrorMessage = ""

    func authenticate() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Unlock ChatChat with Face ID"

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self.isUnlocked = true
                        self.faceIDErrorMessage = ""
                    } else {
                        self.isUnlocked = false
                        self.faceIDErrorMessage = authenticationError?.localizedDescription ?? "Authentication failed"
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                self.isUnlocked = false
                self.faceIDErrorMessage = error?.localizedDescription ?? "Biometrics not available"
            }
        }
    }
}
