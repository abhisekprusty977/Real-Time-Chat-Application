import Foundation
import SwiftUI
import FirebaseDatabase
import FirebaseAuth

struct ChatRoomView: View {
    let room: ChatRoom // Your ChatRoom model
    
    @StateObject private var chatViewModel: ChatRoomViewModel
    @State private var newMessage: String = ""
    
    init(room: ChatRoom) {
        self.room = room
        self._chatViewModel = StateObject(wrappedValue: ChatRoomViewModel(roomId: room.id))
    }
    
    var body: some View {
        VStack {
            // Messages List
            ScrollViewReader { scrollProxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(chatViewModel.messages) { message in
                            ChatMessageView(message: message)
                                .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: chatViewModel.messages.count) { _ in
                    if let lastMessage = chatViewModel.messages.last {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            scrollProxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            Divider()
            
            // Input Area
            HStack {
                TextField("Type a message...", text: $newMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button("Send") {
                    sendMessage()
                }
                .disabled(newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
        }
        .navigationTitle(room.name)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func sendMessage() {
        let trimmed = newMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        chatViewModel.sendMessage(text: trimmed)
        newMessage = ""
    }
}

// You will also need ChatRoomViewModel, ChatMessageView, Message, and ChatRoom model defined similarly.
