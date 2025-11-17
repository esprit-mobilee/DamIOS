import SwiftUI

struct TeacherHomeView: View {
    let user: EspritUser
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    TopBar(title: "Espace Enseignant", userName: user.fullName) {
                        appState.logout()
                    }

                    HeroCard(
                        title: "Bienvenue dans votre Espace",
                        subtitle: "Gérez vos cours, présences et annonces."
                    )

                    ActionGrid(role: .TEACHER)

                    // exemples de sections
                    TeacherQuickList()
                }
                .padding()
            }
            .background(Color.espritBgGray.ignoresSafeArea())
        }
    }
}

struct TeacherQuickList: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Dernières annonces")
                .font(.headline)
            ForEach(0..<3) { _ in
                HStack {
                    Image(systemName: "megaphone.fill")
                        .foregroundColor(.espritRedPrimary)
                    VStack(alignment: .leading) {
                        Text("Contrôle de TP reporté")
                            .font(.subheadline)
                        Text("Publié le 08/11/2025")
                            .font(.caption)
                            .foregroundColor(.espritTextGray)
                    }
                    Spacer()
                }
                .padding(8)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
}
