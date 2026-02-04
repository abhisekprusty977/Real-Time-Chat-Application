import SwiftUI
import Foundation
// Enhanced Chat Room Card View
struct ChatRoomCard: View {
    let room: ChatRoom
    
    var body: some View {
        HStack(spacing: 16) {
            // Room Icon
            Image(systemName: room.icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.7)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Circle())
            
            // Room Info
            VStack(alignment: .leading, spacing: 6) {
                Text(room.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(room.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Active indicator and arrow
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 6, height: 6)
                    Text("Active")
                        .font(.caption2)
                        .foregroundColor(.green)
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}
