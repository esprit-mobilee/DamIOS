import SwiftUI

struct ChatView: View {

    @EnvironmentObject var appState: AppState
    @StateObject private var vm = MessagingViewModel()

    let userId: String
    let userName: String

    var body: some View {
        VStack {

            // ---- messages list ----
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(vm.messages) { msg in
                            ChatMessageBubble(message: msg)
                                .id(msg.id)
                        }
                    }
                    .padding(.horizontal)
                }
                .onChange(of: vm.messages.count) { _ in
                    if let last = vm.messages.last {
                        withAnimation {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }

            // ---- SEND BAR ----
            HStack {
                TextField("Message...", text: $vm.messageText)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                Button {
                    Task {
                        if let token = appState.token {
                            await vm.send(appState: appState, to: userId, token: token)
                        }
                    }
                } label: {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .clipShape(Circle())
                }
            }
            .padding()
        }
        .navigationTitle(userName)
        .task {
            if let token = appState.token {
                await vm.loadMessages(appState: appState, otherUserId: userId, token: token)
            }
        }
    }
}
