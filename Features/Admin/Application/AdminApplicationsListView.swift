import SwiftUI

struct AdminApplicationsListView: View {
    @EnvironmentObject var appState: AppState

    var offerId: String? = nil

    @State private var applications: [Application] = []
    @State private var internshipCache: [String: InternshipOffer] = [:]
    @State private var userCache: [String: EspritUser] = [:]

    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Chargement…")
                }
                else if applications.isEmpty {
                    VStack(spacing: 14) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.5))

                        Text("Aucune candidature trouvée")
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 80)
                }
                else {
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            ForEach(applications) { app in
                                NavigationLink {
                                    AdminApplicationDetailView(application: app)
                                        .environmentObject(appState)
                                } label: {
                                    adminCard(app)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .animation(.spring(), value: applications.count)   // ✔ VALID

                        .padding(.horizontal)
                        .padding(.top, 10)
                    }
                }
            }
            .navigationTitle("Candidatures")
            .task { await loadApplications() }
        }
    }

    // MARK: — CARD MODERNE
    private func adminCard(_ app: Application) -> some View {

        let internshipId = app.internshipId?.id ?? "unknown"

        return HStack(spacing: 16) {

            // Avatar ou icône
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.gray.opacity(0.1))

                Image(systemName: "person.text.rectangle")
                    .font(.title)
                    .foregroundColor(.gray.opacity(0.7))
            }
            .frame(width: 70, height: 70)

            VStack(alignment: .leading, spacing: 6) {

                // Titre stage
                Text(internshipCache[internshipId]?.title ?? "Stage #\(internshipId.prefix(5))")
                    .font(.headline)

                // Nom candidat
                Text(userCache[app.userId]?.fullName ?? "Candidat #\(app.userId.prefix(5))")
                    .foregroundColor(.gray)
                    .font(.subheadline)

                // Status badge
                statusBadge(app.status)
            }

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
        )
        .task { await loadExtraData(for: app) }
    }

    // MARK: – BADGE
    private func statusBadge(_ status: String) -> some View {
        let color: Color =
            status == "accepted" ? .green :
            status == "rejected" ? .red :
            .orange

        return Text(status.capitalized)
            .font(.caption)
            .bold()
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color.opacity(0.15))
            .foregroundColor(color)
            .clipShape(Capsule())
    }

    // MARK: — LOAD BASE
    private func loadApplications() async {
        guard let token = appState.token else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            var all = try await EspritAPI.shared.fetchApplications(token: token)
            if let id = offerId { all = all.filter { $0.internshipId?.id == id } }
            applications = all
        } catch {
            print("Erreur fetch apps:", error)
        }
    }

    // MARK: — LOAD DETAILS (cache)
    private func loadExtraData(for app: Application) async {
        guard let token = appState.token else { return }

        let internshipId = app.internshipId?.id ?? "unknown"

        if internshipCache[internshipId] == nil {
            if let offer = try? await EspritAPI.shared.getInternshipById(token: token, id: internshipId) {
                await MainActor.run { internshipCache[internshipId] = offer }
            }
        }

        if userCache[app.userId] == nil {
            if let user = try? await EspritAPI.shared.getUserById(token: token, id: app.userId) {
                await MainActor.run { userCache[app.userId] = user }
            }
        }
    }
}
