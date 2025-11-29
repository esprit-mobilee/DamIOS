import SwiftUI

struct ConversationRow: View {
    let item: Conversation

    var body: some View {
        HStack(spacing: 14) {

            // Avatar cercle
            Circle()
                .fill(Color.red.opacity(0.8))
                .frame(width: 48, height: 48)
                .overlay(
                    Text(item.userName.prefix(1))
                        .font(.title2)
                        .foregroundColor(.white)
                )

            VStack(alignment: .leading, spacing: 4) {
                // Nom UNIQUEMENT
                Text(item.userName)
                    .font(.headline)

                // Dernier message
                Text(item.lastMessage)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(item.lastMessageTime)
                    .font(.caption)
                    .foregroundColor(.gray)

                if item.unreadCount > 0 {
                    Text("\(item.unreadCount)")
                        .font(.caption)
                        .padding(6)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal)
    }
}
