import SwiftUI

struct AdminClubsListView: View {
    @EnvironmentObject var appState: AppState
    @State private var clubs: [Club] = []
    @State private var showAdd = false
    @State private var clubToEdit: Club?
    @State private var clubToDelete: Club?

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 18) {
                    ForEach(clubs) { club in

                        NavigationLink {
                            AdminClubDetailView(
                                club: club,
                                onEdit: {
                                    clubToEdit = club
                                },
                                onDelete: {
                                    clubToDelete = club
                                }
                            )
                        } label: {
                            clubCard(club)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationTitle("Clubs")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAdd = true } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.red)
                    }
                }
            }

            .task { await load() }

            // ADD
            .sheet(isPresented: $showAdd) {
                if let token = appState.token {
                    AdminAddClubView(token: token) { newClub in
                        clubs.insert(newClub, at: 0)
                    }
                }
            }

            // EDIT
            .sheet(item: $clubToEdit) { club in
                if let token = appState.token {
                    AdminEditClubView(token: token, club: club) { updated in
                        if let idx = clubs.firstIndex(where: { $0.id == updated.id }) {
                            clubs[idx] = updated
                        }
                    }
                }
            }

            // DELETE – confirmation dialog
            .confirmationDialog(
                "Supprimer ce club ?",
                isPresented: Binding(
                    get: { clubToDelete != nil },
                    set: { if !$0 { clubToDelete = nil } }
                ),
                titleVisibility: .visible
            ) {
                Button("Supprimer", role: .destructive) {
                    if let club = clubToDelete {
                        Task { await deleteClub(club) }
                    }
                }
                Button("Annuler", role: .cancel) {}
            }
        }
    }

    // MARK: - CARD DESIGN IDENTIQUE AUX STAGES
    @ViewBuilder
    func clubCard(_ club: Club) -> some View {
        HStack(spacing: 16) {

            // MARK: Image LARGE comme STAGES
            AsyncImage(url: club.fullImageURL) { phase in
                switch phase {
                case .success(let img):
                    img.resizable()
                        .scaledToFill()
                case .failure(_):
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .padding(20)
                        .foregroundColor(.gray.opacity(0.4))
                default:
                    ProgressView()
                }
            }
            .frame(width: 110, height: 110)
            .background(Color.gray.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 18))

            // MARK: Infos
            VStack(alignment: .leading, spacing: 8) {
                Text(club.name)
                    .font(.title3)
                    .bold()
                    .foregroundColor(.black)

                if let desc = club.description, !desc.isEmpty {
                    Text(desc)
                        .font(.headline)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
            }

            Spacer()

            // MARK: Bouton Modifier (identique aux stages)
            Button {
                clubToEdit = club
            } label: {
                Image(systemName: "square.and.pencil")
                    .font(.title2)
                    .foregroundColor(.espritRedPrimary)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .frame(height: 160)   // 👉 EXACTEMENT COMME LES STAGES
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(.white)
                .shadow(color: .black.opacity(0.07), radius: 8, x: 0, y: 4)
        )
    }

    // MARK: - Load
    private func load() async {
        guard let token = appState.token else { return }
        do {
            clubs = try await EspritAPI.shared.fetchClubs(token: token)
        } catch {
            print("Erreur load clubs:", error)
        }
    }

    // MARK: - Delete
    private func deleteClub(_ club: Club) async {
        guard let token = appState.token else { return }
        do {
            try await EspritAPI.shared.deleteClub(token: token, id: club.id)
            clubs.removeAll { $0.id == club.id }
        } catch {
            print("Erreur delete:", error)
        }
        clubToDelete = nil
    }
}

