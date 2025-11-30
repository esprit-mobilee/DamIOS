import SwiftUI

struct ChatMessageBubble: View {
    let message: Message

    var body: some View {
        HStack {
            if message.isMine {
                Spacer()
                Text(message.content)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.red)
                    .cornerRadius(12)
            } else {
                Text(message.content)
                    .padding()
                    .foregroundColor(.black)
                    .background(Color(.systemGray5))
                    .cornerRadius(12)
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
        .id(message.id)
    }
}
