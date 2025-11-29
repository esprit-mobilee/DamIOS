import SwiftUI

struct ConversationsView: View {

    @EnvironmentObject var appState: AppState
    @StateObject private var vm = ConversationsViewModel()

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Messagerie")
                // Se relance quand l'utilisateur courant change (ou au premier affichage)
                .task(id: appState.currentUser?.id) {
                    await reloadConversations()
                }
        }
    }

    // Vue principale en fonction de l'état du ViewModel
    @ViewBuilder
    private var content: some View {
        if vm.isLoading && vm.conversations.isEmpty {
            ProgressView("Chargement…")
        } else if let error = vm.errorMessage {
            VStack(spacing: 12) {
                Text(error)
                    .foregroundColor(.red)
                Button("Réessayer") {
                    Task {
                        await reloadConversations()
                    }
                }
            }
            .padding()
        } else {
            if vm.conversations.isEmpty {
                VStack(spacing: 8) {
                    Text("Aucune conversation")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Button("Recharger") {
                        Task {
                            await reloadConversations()
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(vm.conversations) { conv in
                    NavigationLink(
                        destination: ChatView(
                            userId: conv.userId,
                            userName: conv.userName
                        )
                    ) {
                        ConversationRow(item: conv)
                    }
                }
                // Pull to refresh pour voir les nouveaux messages
                .refreshable {
                    await reloadConversations()
                }
            }
        }
    }

    // Fonction commune de rechargement
    private func reloadConversations() async {
        guard let token = appState.token,
              let userId = appState.currentUser?.id else {
            return
        }

        await vm.loadConversations(
            token: token,
            currentUserId: userId
        )
    }
}
