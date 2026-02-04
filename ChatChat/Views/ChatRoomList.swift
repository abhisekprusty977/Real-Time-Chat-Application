import SwiftUI
import FirebaseAuth

struct ChatRoomListView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @StateObject private var faceIDManager = FaceIDManager()

    @State private var availableRooms = [
        ChatRoom(id: "general", name: "General", description: "General discussion", icon: "message.circle"),
        ChatRoom(id: "tech", name: "Tech Talk", description: "Technology discussions", icon: "laptopcomputer"),
        ChatRoom(id: "random", name: "Random", description: "Random conversations", icon: "shuffle"),
        ChatRoom(id: "gaming", name: "Gaming", description: "Gaming discussions", icon: "gamecontroller"),
        ChatRoom(id: "sports", name: "Sports", description: "Sports discussions", icon: "sportscourt"),
        ChatRoom(id: "music", name: "Music", description: "Music and entertainment", icon: "music.note")
    ]

    @State private var showSignOutAlert = false
    @State private var isLocked = UserDefaults.standard.bool(forKey: "isAppLocked") // persistent lock state

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if isLocked && !faceIDManager.isUnlocked {
                    LockScreenView(faceIDManager: faceIDManager) {
                        faceIDManager.authenticate()
                    }
                } else {
                    chatListView
                }
            }
            .navigationTitle("Chat Rooms")
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        // Listen to Face ID unlock event to update lock state
        .onReceive(faceIDManager.$isUnlocked) { unlocked in
            if unlocked && isLocked {
                // Face ID passed → unlock and save
                isLocked = false
                UserDefaults.standard.set(false, forKey: "isAppLocked")
            }
        }

    }

    private var chatListView: some View {
        VStack(spacing: 0) {
            userProfileHeader
            Divider()
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(availableRooms) { room in
                        NavigationLink(destination: ChatRoomView(room: room)) {
                            ChatRoomCard(room: room)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
                .padding(.top)
            }
            .background(Color(.systemGroupedBackground))
        }
    }

    private var userProfileHeader: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                AsyncImage(url: URL(string: authManager.currentUser?.photoURL?.absoluteString ?? "")) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Image(systemName: "person.circle.fill").foregroundColor(.gray)
                }
                .frame(width: 60, height: 60)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.blue, lineWidth: 3))

                VStack(alignment: .leading, spacing: 6) {
                    Text("Welcome back!").font(.caption).foregroundColor(.secondary)
                    Text(authManager.currentUser?.displayName ?? "User")
                        .font(.title2)
                        .fontWeight(.semibold)
                    HStack(spacing: 6) {
                        Circle().fill(Color.green).frame(width: 8, height: 8)
                        Text("Online").font(.caption).foregroundColor(.secondary)
                    }
                }
                Spacer()

                // Lock Button
                Button(action: toggleLock) {
                    Image(systemName: isLocked ? "lock.fill" : "lock.open.fill")
                        .font(.body)
                        .foregroundColor(isLocked ? .red : .green)
                        .padding(8)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(Circle())
                }

                // Sign Out Button
                Button(action: { showSignOutAlert = true }) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.body)
                        .foregroundColor(.red)
                        .padding(8)
                        .background(Color.red.opacity(0.1))
                        .clipShape(Circle())
                }
                .alert("Are you sure you want to sign out?", isPresented: $showSignOutAlert) {
                    Button("Yes", role: .destructive) { authManager.signOutImmediately() }
                    Button("No", role: .cancel) { }
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)

            HStack {
                Text("Available Chat Rooms").font(.headline)
                Spacer()
                Text("\(availableRooms.count) rooms")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .background(Color(.systemBackground))
    }

    private func toggleLock() {
        if isLocked {
            // Try to unlock
            faceIDManager.authenticate()
        } else {
            // Lock immediately and persist
                       isLocked = true
                       faceIDManager.isUnlocked = false
                       UserDefaults.standard.set(true, forKey: "isAppLocked")
        }
    }
}




struct LockScreenView: View {
    @ObservedObject var faceIDManager: FaceIDManager
    var onAuthenticate: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "faceid")
                .font(.system(size: 100))
                .foregroundColor(.blue)
            Text("App Locked")
                .font(.title)
                .bold()
            if !faceIDManager.faceIDErrorMessage.isEmpty {
                Text(faceIDManager.faceIDErrorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            Button("Unlock with Face ID") {
                onAuthenticate()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .edgesIgnoringSafeArea(.all)
    }
}


struct ChatRoomListView_Previews: PreviewProvider {
    static var previews: some View {
        ChatRoomListView()
            .environmentObject(AuthenticationManager())
    }
}
