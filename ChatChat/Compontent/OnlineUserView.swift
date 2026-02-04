import SwiftUI

struct OnlineUsersView: View {
    let users: [ChatUser]
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                Section("Online Users (\(users.filter { $0.isOnline }.count))") {
                    ForEach(users.filter { $0.isOnline }) { user in
                        UserRowView(user: user)
                    }
                }
                
                if !users.filter { !$0.isOnline }.isEmpty {
                    Section("Offline") {
                        ForEach(users.filter { !$0.isOnline }) { user in
                            UserRowView(user: user)
                        }
                    }
                }
            }
            .navigationTitle("Users")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct UserRowView: View {
    let user: ChatUser
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: user.photoURL ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Image(systemName: "person.circle.fill")
                    .foregroundColor(.gray)
            }
            .frame(width: 40, height: 40)
            .clipShape(Circle())
            
            VStack(alignment: .leading) {
                Text(user.name)
                    .font(.headline)
                
                HStack {
                    Circle()
                        .fill(user.isOnline ? Color.green : Color.gray)
                        .frame(width: 8, height: 8)
                    
                    Text(user.isOnline ? "Online" : "Offline")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

