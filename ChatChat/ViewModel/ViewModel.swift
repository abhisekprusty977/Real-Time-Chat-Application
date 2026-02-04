import SwiftUI
import FirebaseDatabase
import FirebaseAuth
import Combine

class MultiUserChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var onlineUsers: [ChatUser] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var isAuthorized: Bool = true
    
    private var cancellables = Set<AnyCancellable>()
    
    private var messagesRef: DatabaseReference
    private var usersRef: DatabaseReference
    private let chatRoomId: String
    
    init(chatRoomId: String) {
        self.chatRoomId = chatRoomId
        self.messagesRef = Database.database().reference().child("chat-rooms").child(chatRoomId).child("messages")
        self.usersRef = Database.database().reference().child("chat-rooms").child(chatRoomId).child("users")
        
        verifyReadPermission()
        
        startListeningForMessages()
        startListeningForUsers()
        updateUserPresence()
    }
    
    private func verifyReadPermission() {
        messagesRef.observeSingleEvent(of: .value) { [weak self] _ in
            DispatchQueue.main.async {
                self?.isAuthorized = true
                self?.errorMessage = nil
            }
        } withCancel: { [weak self] error in
            DispatchQueue.main.async {
                self?.isAuthorized = false
                self?.errorMessage = error.localizedDescription
            }
        }
    }
    
    private func startListeningForMessages() {
        isLoading = true
        
        messagesRef.observe(.value, with: { [weak self] snapshot in
            guard let self = self else { return }
            
            var newMessages: [Message] = []
            
            for child in snapshot.children {
                if let snap = child as? DataSnapshot,
                   let dict = snap.value as? [String: Any],
                   let text = dict["text"] as? String,
                   let senderId = dict["senderId"] as? String,
                   let senderName = dict["senderName"] as? String,
                   let timestamp = dict["timestamp"] as? TimeInterval {
                    
                    let message = Message(
                        id: snap.key,
                        text: text,
                        senderId: senderId,
                        senderName: senderName,
                        senderPhotoURL: dict["senderPhotoURL"] as? String,
                        chatRoomId: self.chatRoomId,
                        timestamp: timestamp
                    )
                    newMessages.append(message)
                }
            }
            
            newMessages.sort { $0.timestamp < $1.timestamp }
            
            DispatchQueue.main.async {
                self.messages = newMessages
                self.isLoading = false
                self.isAuthorized = true
                self.errorMessage = nil
            }
        }, withCancel: { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.isAuthorized = false
                self?.errorMessage = error.localizedDescription
            }
        })
    }
    
    private func startListeningForUsers() {
        usersRef.observe(.value, with: { [weak self] snapshot in
            guard let self = self else { return }
            
            var users: [ChatUser] = []
            
            for child in snapshot.children {
                if let snap = child as? DataSnapshot,
                   let dict = snap.value as? [String: Any],
                   let name = dict["name"] as? String,
                   let email = dict["email"] as? String {
                    
                    let user = ChatUser(
                        id: snap.key,
                        name: name,
                        email: email,
                        photoURL: dict["photoURL"] as? String,
                        isOnline: dict["isOnline"] as? Bool ?? false,
                        lastSeen: dict["lastSeen"] as? TimeInterval ?? Date().timeIntervalSince1970
                    )
                    users.append(user)
                }
            }
            
            DispatchQueue.main.async {
                self.onlineUsers = users
            }
        }, withCancel: { [weak self] error in
            DispatchQueue.main.async {
                self?.errorMessage = error.localizedDescription
            }
        })
    }
    
    private func updateUserPresence() {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        let userData: [String: Any] = [
            "name": currentUser.displayName ?? "Unknown User",
            "email": currentUser.email ?? "",
            "photoURL": currentUser.photoURL?.absoluteString ?? "",
            "isOnline": true,
            "lastSeen": Date().timeIntervalSince1970
        ]
        
        let userRef = usersRef.child(currentUser.uid)
        userRef.setValue(userData) { [weak self] error, _ in
            if let error = error {
                DispatchQueue.main.async {
                    self?.isAuthorized = false
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
        
        // Set user offline when app is closed
        userRef.onDisconnectUpdateChildValues(["isOnline": false, "lastSeen": ServerValue.timestamp()]) { error, _ in
            if let error = error {
                // Optionally track error; avoid crashing
                print("onDisconnect error: \(error.localizedDescription)")
            }
        }
    }
    
    func sendMessage(text: String) {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        let messageData: [String: Any] = [
            "text": text,
            "senderId": currentUser.uid,
            "senderName": currentUser.displayName ?? "Unknown User",
            "senderPhotoURL": currentUser.photoURL?.absoluteString ?? "",
            "timestamp": Date().timeIntervalSince1970
        ]
        
        messagesRef.childByAutoId().setValue(messageData) { [weak self] error, _ in
            if let error = error {
                DispatchQueue.main.async {
                    self?.isAuthorized = false
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func refreshAuthorization() {
        verifyReadPermission()
        updateUserPresence()
    }
    
    deinit {
        // Mark user as offline when leaving chat
        if let currentUser = Auth.auth().currentUser {
            usersRef.child(currentUser.uid).updateChildValues([
                "isOnline": false,
                "lastSeen": Date().timeIntervalSince1970
            ])
        }
        
        messagesRef.removeAllObservers()
        usersRef.removeAllObservers()
    }
}
