import SwiftUI

struct StudentHomeView: View {
    let user: EspritUser
    @EnvironmentObject var appState: AppState
    @State private var showMenu = false
    @State private var selected: MenuItem?

    var body: some View {
        ZStack(alignment: .leading) {
            NavigationStack {
                ScrollView {
                    VStack(spacing: 20) {
                        // barre du haut
                        HStack {
                            Button {
                                withAnimation { showMenu.toggle() }
                            } label: {
                                Image(systemName: "line.3.horizontal")
                                    .font(.title2)
                                    .foregroundColor(.black)
                            }

                            Spacer()

                            Text("Espace Étudiant")
                                .font(.headline)

                            Spacer()

                            Button {
                                appState.logout()
                            } label: {
                                Image(systemName: "power")
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.horizontal)

                        // bandeau
                        HeroCard(
                            title: "Bienvenue dans votre Espace",
                            subtitle: "Consultez votre emploi du temps, vos absences, vos résultats..."
                        )

                        // tes actions déjà existantes
                        ActionGrid(role: .STUDENT)

                        // 👉 carte "Clubs"
                        NavigationLink {
                            StudentClubsView()
                                .environmentObject(appState)
                        } label: {
                            studentCard(
                                icon: "person.3.fill",
                                title: "Clubs",
                                subtitle: "Consulter les clubs existants"
                            )
                        }

                        // 👉 carte "Stages"
                        NavigationLink {
                            StudentStagesView()
                                .environmentObject(appState)
                        } label: {
                            studentCard(
                                icon: "briefcase.fill",
                                title: "Stages",
                                subtitle: "Voir les offres de stage"
                            )
                        }
                        // 👉 carte "Stages"
                        NavigationLink {
                            StudentEventsListView()
                                .environmentObject(appState)
                        } label: {
                            studentCard(
                                icon: "calendar",
                                title: "Events",
                                subtitle: "Voir les offres de stage"
                            )
                        }
                        
                    }
                    .padding(.vertical)
                }
                .background(Color(.systemGray6))
            }
            .disabled(showMenu)

            if showMenu {
                SideMenuView(
                    user: user,
                    onSelect: { item in
                        selected = item
                        withAnimation { showMenu = false }
                    },
                    onLogout: {
                        appState.logout()
                    }
                )
                .transition(.move(edge: .leading))
            }
        }
    }

    // petit helper pour éviter de répéter le même style
    private func studentCard(icon: String, title: String, subtitle: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.white)
                .padding(10)
                .background(Color.espritRedPrimary)
                .clipShape(Circle())

            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.03), radius: 3, x: 0, y: 1)
        .padding(.horizontal)
    }
}
