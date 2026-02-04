import Foundation
import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @StateObject private var faceIDManager = FaceIDManager()
    
    @State private var isLocked = UserDefaults.standard.bool(forKey: "isAppLocked")

    var body: some View {
        TabView {
        
            
                ChatRoomListView()
                    .environmentObject(authManager)
                    .transition(.move(edge: .trailing))
//                    .navigationBarHidden(true)
//                    .toolbar(.hidden, for: .navigationBar)
//                    .ignoresSafeArea(.container, edges: .top)
                    .ignoresSafeArea()

           
            .tabItem {
                Label("Chat", systemImage: "message.fill")
            }
            
           
            GamesView()
                .tabItem {
                    Label("Games", systemImage: "gamecontroller.fill")
                }
            
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
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
