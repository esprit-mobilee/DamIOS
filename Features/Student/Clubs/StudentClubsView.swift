import SwiftUI

struct StudentClubsView: View {

    @EnvironmentObject var appState: AppState
    @State private var clubs: [Club] = []
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(clubs) { club in
                        NavigationLink {
                            StudentClubDetailView(club: club)
                        } label: {
                            StudentClubCard(club: club)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationTitle("Clubs")
            .task { await load() }
            .alert(errorMessage ?? "", isPresented: .constant(errorMessage != nil)) {
                Button("OK") { errorMessage = nil }
            }
        }
    }

    private func load() async {
        guard let token = appState.token else { return }
        do {
            let fetched = try await EspritAPI.shared.fetchClubs(token: token)
            await MainActor.run { self.clubs = fetched }
        } catch {
            await MainActor.run { self.errorMessage = error.localizedDescription }
        }
    }
}

struct StudentClubCard: View {

    let club: Club

    var body: some View {
        HStack(spacing: 14) {

            // --- IMAGE DU CLUB ---
            AsyncImage(url: club.fullImageURL) { phase in
                switch phase {
                case .success(let img):
                    img.resizable().scaledToFill()
                case .failure(_):
                    Image(systemName: "photo")
                        .resizable().scaledToFit()
                        .padding(18)
                        .foregroundColor(.gray.opacity(0.5))
                default:
                    ProgressView()
                }
            }
            .frame(width: 90, height: 90)
            .background(Color.gray.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 16))

            VStack(alignment: .leading, spacing: 6) {

                Text(club.name)
                    .font(.headline)

                if let desc = club.description, !desc.isEmpty {
                    Text(desc)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                if let p = club.president {
                    HStack {
                        Image(systemName: "person.crop.circle.badge.checkmark")
                            .foregroundColor(.red)

                        Text("\(p.firstName ?? "") \(p.lastName ?? "")")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }

            Spacer()

        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}
