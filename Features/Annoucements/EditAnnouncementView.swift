import SwiftUI

struct EditAnnouncementView: View {

    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @StateObject private var vm = AnnouncementsViewModel()

    let announcement: Announcement

    @State private var title: String
    @State private var content: String
    @State private var audience: String

    let audiences = ["Tous", "Étudiants", "Administration"]

    init(announcement: Announcement) {
        self.announcement = announcement
        _title = State(initialValue: announcement.title)
        _content = State(initialValue: announcement.content)
        _audience = State(initialValue: announcement.audience ?? "Tous")
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 22) {

                TextField("Titre", text: $title)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                TextField("Contenu", text: $content, axis: .vertical)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                Picker("Audience", selection: $audience) {
                    ForEach(audiences, id: \.self) { a in
                        Text(a)
                    }
                }
                .pickerStyle(.menu)

                Button("Enregistrer les modifications") {
                    print("👆 Bouton modifier cliqué !")

                    Task {
                        if let token = appState.token,
                           let userId = appState.currentUser?.id {

                            let ok = await vm.updateAnnouncement(
                                id: announcement.id,
                                title: title,
                                content: content,
                                audience: audience,
                                senderId: userId,   // ⬅ IMPORTANT !
                                token: token
                            )

                            if ok { dismiss() }
                        }
                    }
                }
                    
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(.orange)
                .cornerRadius(12)

                Spacer()
            }
            .padding()
            .navigationTitle("Modifier annonce")
        }
    }
}
