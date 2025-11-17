import SwiftUI

struct AdminClubDetailView: View {
    let club: Club
    var onEdit: (() -> Void)?
    var onDelete: (() async -> Void)?   // async comme stages

    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteAlert = false
    @State private var isDeleting = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {

                // IMAGE
                if let url = club.fullImageURL {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let img):
                            img.resizable().scaledToFit()
                        default:
                            Color.gray.opacity(0.2)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: 260)
                    .clipped()
                }

                // NAME + DESC
                VStack(alignment: .leading, spacing: 8) {
                    Text(club.name)
                        .font(.largeTitle.bold())

                    if let desc = club.description, !desc.isEmpty {
                        Text(desc)
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                }

                Divider()

                // PRESIDENT
                if let p = club.president {
                    VStack(alignment: .leading) {
                        Text("Président")
                            .font(.headline)
                        Text("\(p.firstName ?? "") \(p.lastName ?? "")")
                    }
                }

                Divider()

                // TAGS
                VStack(alignment: .leading, spacing: 6) {
                    Text("Tags").font(.headline)

                    FlowLayout(items: club.tags, spacing: 8) { tag in
                        Text(tag)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.blue.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                }

                Divider()

                // ACTION BUTTONS (Modifier - Partager - Supprimer)
                HStack(spacing: 40) {

                    // EDIT
                    Button { onEdit?() } label: {
                        Circle()
                            .fill(Color.blue.opacity(0.15))
                            .frame(width: 60, height: 60)
                            .overlay(
                                Image(systemName: "square.and.pencil")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            )
                    }

                    // SHARE
                    Button { shareClub() } label: {
                        Circle()
                            .fill(Color.green.opacity(0.15))
                            .frame(width: 60, height: 60)
                            .overlay(
                                Image(systemName: "square.and.arrow.up")
                                    .font(.title2)
                                    .foregroundColor(.green)
                            )
                    }

                    // DELETE — TFEL DESIGN MTA3 STAGE
                    Button {
                        showDeleteAlert = true
                    } label: {
                        Circle()
                            .fill(Color.red.opacity(0.15))
                            .frame(width: 60, height: 60)
                            .overlay(
                                Image(systemName: "trash")
                                    .font(.title2)
                                    .foregroundColor(.red)
                            )
                    }
                }
                .padding(.vertical, 25)
                .frame(maxWidth: .infinity)
            }
            .padding()
        }
        .navigationTitle("Club")
        .navigationBarTitleDisplayMode(.inline)

        // EXACTEMENT COMME SUPPRESSION DES STAGES
        .alert("Supprimer ce club ?", isPresented: $showDeleteAlert) {
            Button("Annuler", role: .cancel) {}

            Button("Supprimer", role: .destructive) {
                Task {
                    isDeleting = true
                    await onDelete?()
                    isDeleting = false
                    dismiss()
                }
            }
        } message: {
            Text("Cette action est irréversible.")
        }
    }

    // SHARE
    private func shareClub() {
        let text = "Découvrez le club : \(club.name)"
        let av = UIActivityViewController(activityItems: [text], applicationActivities: nil)

        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = scene.windows.first?.rootViewController {
            root.present(av, animated: true)
        }
    }
}
