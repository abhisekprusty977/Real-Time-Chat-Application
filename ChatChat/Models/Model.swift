import Foundation
import FirebaseAuth

struct Message: Identifiable, Codable {
    let id: String
    let text: String
    let senderId: String
    let senderName: String
    let senderPhotoURL: String?
    let timestamp: TimeInterval
    let chatRoomId: String
    
    var isSentByCurrentUser: Bool {
        return senderId == Auth.auth().currentUser?.uid
    }
    
    init(id: String = UUID().uuidString, text: String, senderId: String, senderName: String, senderPhotoURL: String? = nil, chatRoomId: String, timestamp: TimeInterval = Date().timeIntervalSince1970) {
        self.id = id
        self.text = text
        self.senderId = senderId
        self.senderName = senderName
        self.senderPhotoURL = senderPhotoURL
        self.chatRoomId = chatRoomId
        self.timestamp = timestamp
    }
}




//user model

import Foundation

struct ChatUser: Identifiable, Codable {
    let id: String
    let name: String
    let email: String
    let photoURL: String?
    let isOnline: Bool
    let lastSeen: TimeInterval
    
    init(id: String, name: String, email: String, photoURL: String? = nil, isOnline: Bool = true, lastSeen: TimeInterval = Date().timeIntervalSince1970) {
        self.id = id
        self.name = name
        self.email = email
        self.photoURL = photoURL
        self.isOnline = isOnline
        self.lastSeen = lastSeen
    }
}
