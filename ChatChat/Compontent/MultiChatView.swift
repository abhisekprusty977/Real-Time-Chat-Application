import SwiftUI

struct MultiUserChatView: View {
    let chatRoomId: String
    @StateObject private var viewModel: MultiUserChatViewModel
    @State private var newMessage: String = ""
    @State private var showingUsersList = false
    
    init(chatRoomId: String) {
        self.chatRoomId = chatRoomId
        self._viewModel = StateObject(wrappedValue: MultiUserChatViewModel(chatRoomId: chatRoomId))
    }
    
    var body: some View {
        VStack {
            // Messages
            ScrollViewReader { scrollProxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.messages) { message in
                            MultiUserMessageRow(message: message)
                                .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel.messages.count) { _ in
                    if let lastMessage = viewModel.messages.last {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            scrollProxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            Divider()
            
            // Input
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
        .navigationTitle("\(chatRoomId.capitalized) Chat")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingUsersList.toggle()
                }) {
                    HStack {
                        Image(systemName: "person.2.fill")
                        Text("\(viewModel.onlineUsers.count)")
                    }
                }
            }
        }
        .sheet(isPresented: $showingUsersList) {
            OnlineUsersView(users: viewModel.onlineUsers)
        }
        .overlay(
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading messages...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.white.opacity(0.8))
                }
            }
        )
    }
    
    private func sendMessage() {
        let message = newMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !message.isEmpty else { return }
        
        viewModel.sendMessage(text: message)
        newMessage = ""
    }
}

