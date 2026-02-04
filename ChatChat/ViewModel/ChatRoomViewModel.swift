import SwiftUI
import FirebaseDatabase
import FirebaseAuth
import Combine

class ChatRoomViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    
    private var messagesRef: DatabaseReference
    private let roomId: String
    
    init(roomId: String) {
        self.roomId = roomId
        self.messagesRef = Database.database().reference().child("chat-rooms").child(roomId).child("messages")
        startListeningForMessages()
    }
    
    private func startListeningForMessages() {
        messagesRef.observe(.value) { [weak self] snapshot in
            var newMessages: [ChatMessage] = []
            
            for child in snapshot.children {
                if let snap = child as? DataSnapshot,
                   let dict = snap.value as? [String: Any],
                   let text = dict["text"] as? String,
                   let senderId = dict["senderId"] as? String,
                   let senderName = dict["senderName"] as? String,
                   let timestamp = dict["timestamp"] as? TimeInterval {
                    
                    let message = ChatMessage(
                        id: snap.key,
                        text: text,
                        senderId: senderId,
                        senderName: senderName,
                        senderPhotoURL: dict["senderPhotoURL"] as? String,
                        timestamp: timestamp
                    )
                    newMessages.append(message)
                }
            }
            
            newMessages.sort { $0.timestamp < $1.timestamp }
            
            DispatchQueue.main.async {
                self?.messages = newMessages
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
        
        messagesRef.childByAutoId().setValue(messageData)
    }
    
    deinit {
        messagesRef.removeAllObservers()
    }
}

// Supporting model
struct ChatMessage: Identifiable {
    let id: String
    let text: String
    let senderId: String
    let senderName: String
    let senderPhotoURL: String?
    let timestamp: TimeInterval
    
    var isSentByCurrentUser: Bool {
        return senderId == Auth.auth().currentUser?.uid
    }
}
