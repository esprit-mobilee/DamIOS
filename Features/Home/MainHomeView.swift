import SwiftUI

struct MainHomeView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {

                Text("Bienvenue \(appState.currentUser?.email ?? "")")
                    .font(.title3)
                    .padding(.top, 20)

                NavigationLink {
                    ConversationsView()
                } label: {
                    Text("Ouvrir la Messagerie")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(12)
                }

                NavigationLink {
                    AnnouncementsView()     // ← AJOUT IMPORTANT
                } label: {
                    Text("Voir les Annonces")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }

                Spacer()
            }
            .padding()
        }
    }
}
