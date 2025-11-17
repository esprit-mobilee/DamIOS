import SwiftUI

struct AdminHomeView: View {
    let user: EspritUser
    @EnvironmentObject var appState: AppState

    @State private var showMenu = false

    var body: some View {
        ZStack(alignment: .leading) {
            NavigationStack {

                ScrollView {
                    VStack(spacing: 16) {

                        // MARK: - Top bar + Menu button
                        HStack {
                            Button {
                                withAnimation { showMenu.toggle() }
                            } label: {
                                Image(systemName: "line.3.horizontal")
                                    .font(.title2)
                                    .foregroundColor(.black)
                            }

                            Spacer()

                            TopBar(title: "Espace Administrateur",
                                   userName: user.fullName) {
                                appState.logout()
                            }
                        }

                        // MARK: - Hero banner
                        HeroCard(
                            title: "Panneau de gestion ESPRIT",
                            subtitle: "Gérez utilisateurs, annonces, stages et événements."
                        )

                        // MARK: - Grid (déjà existante)
                        ActionGrid(role: .ADMIN)

                        // MARK: - Row : Stages & Clubs
                        HStack(spacing: 12) {

                            NavigationLink {
                                AdminStagesView()
                                    .environmentObject(appState)
                            } label: {
                                AdminStatCard(title: "Stages",
                                              value: "15",
                                              icon: "briefcase.fill")
                                    .frame(maxWidth: .infinity)
                            }

                            NavigationLink {
                                AdminClubsListView()
                                    .environmentObject(appState)
                            } label: {
                                AdminStatCard(title: "Clubs",
                                              value: "8",
                                              icon: "person.3.fill")
                                    .frame(maxWidth: .infinity)
                            }
                        }

                        // MARK: - Events
                        NavigationLink {
                            AdminEventsListView()
                                .environmentObject(appState)
                        } label: {
                            AdminStatCard(title: "Événements",
                                          value: "25",
                                          icon: "calendar")
                                .frame(maxWidth: .infinity)
                        }

                        // MARK: - Applications (NOUVEAU)
                        NavigationLink {
                            AdminApplicationsListView()   // 👉 tu vas me l’envoyer pour le finition UI
                                .environmentObject(appState)
                        } label: {
                            AdminStatCard(title: "Candidatures",
                                          value: "32",
                                          icon: "doc.text.fill")
                                .frame(maxWidth: .infinity)
                        }

                        AdminQuickPanels()
                    }
                    .padding()
                }
                .background(Color.espritBgGray.ignoresSafeArea())
            }
            .disabled(showMenu)

            // MARK: - Side menu
            if showMenu {
                SideMenuView(
                    user: user,
                    onSelect: { _ in withAnimation { showMenu = false } },
                    onLogout: { appState.logout() }
                )
                .transition(.move(edge: .leading))
            }
        }
    }
}


// MARK: - Tableau de bord

struct AdminQuickPanels: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tableau de bord")
                .font(.headline)

            HStack(spacing: 12) {
                AdminStatCard(title: "Étudiants", value: "2450", icon: "person.3.fill")
                AdminStatCard(title: "Enseignants", value: "120", icon: "person.fill.badge.plus")
            }

            HStack(spacing: 12) {
                AdminStatCard(title: "Annonces", value: "8", icon: "megaphone.fill")
                AdminStatCard(title: "Stages", value: "15", icon: "briefcase.fill")
            }
        }
    }
}

// MARK: - Card réutilisable

struct AdminStatCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.white)
                .padding(10)
                .background(Color.espritRedPrimary)
                .clipShape(Circle())

            VStack(alignment: .leading) {
                Text(value)
                    .font(.headline)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.espritTextGray)
            }

            Spacer()
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.03), radius: 2, x: 0, y: 1)
    }
}
