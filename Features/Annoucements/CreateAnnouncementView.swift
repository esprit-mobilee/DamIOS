import SwiftUI

struct CreateAnnouncementView: View {

    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @StateObject private var vm = AnnouncementsViewModel()

    var onCreated: (() -> Void)?

    @State private var title = ""
    @State private var content = ""
    @State private var audience = "Tous"

    let audiences = ["Tous", "Étudiants", "Administration"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {

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

                Button {
                    Task {
                        if let token = appState.token,
                           let userId = appState.currentUser?.id {

                            let ok = await vm.createAnnouncement(
                                title: title,
                                content: content,
                                audience: audience,
                                senderId: userId,
                                token: token
                            )

                            if ok {
                                onCreated?()
                                dismiss()
                            }
                        }
                    }
                } label: {
                    Text("Publier l'annonce")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background((title.isEmpty || content.isEmpty) ? .gray : .red)
                        .cornerRadius(12)
                }
                .disabled(title.isEmpty || content.isEmpty)

                Spacer()
            }
            .padding()
            .navigationTitle("Créer une annonce")
        }
    }
}
