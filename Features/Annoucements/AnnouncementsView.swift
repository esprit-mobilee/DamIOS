import SwiftUI

struct AnnouncementsView: View {

    @EnvironmentObject var appState: AppState
    @StateObject private var vm = AnnouncementsViewModel()

    @State private var showCreate = false
    @State private var selectedFilter = "Tous"

    @State private var editingAnnouncement: Announcement? = nil
    @State private var selectedDetail: Announcement? = nil

    let filters = ["Tous", "Étudiants", "Administration"]

    var filtered: [Announcement] {
        if selectedFilter == "Tous" { return vm.announcements }
        return vm.announcements.filter { $0.audience == selectedFilter }
    }

    var body: some View {
        NavigationStack {

            VStack(spacing: 16) {

                // FILTRE
                Picker("Filtre", selection: $selectedFilter) {
                    ForEach(filters, id: \.self) { t in
                        Text(t).tag(t)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                // CONTENU
                if vm.isLoading {
                    ProgressView("Chargement…").padding(.top, 40)
                }
                else if let err = vm.errorMessage {
                    Text(err).foregroundColor(.red)
                }
                else {
                    ScrollView {
                        LazyVStack(spacing: 22) {

                            ForEach(filtered) { ann in

                                AnnouncementCard(
                                    item: ann,
                                    onEdit: {
                                        editingAnnouncement = ann
                                    },
                                    onDelete: {
                                        Task {
                                            if let token = appState.token {
                                                await vm.deleteAnnouncement(id: ann.id, token: token)
                                                await vm.loadAnnouncements(token: token)
                                            }
                                        }
                                    }
                                )
                                .padding(.horizontal)
                                .onTapGesture {
                                    selectedDetail = ann
                                }

                            }

                        }.padding(.top, 10)
                    }
                }
            }

            .navigationTitle("Announcements")
            .toolbar {
                Button {
                    showCreate = true
                } label: {
                    Image(systemName: "plus")
                }
            }

            // AJOUT
            .sheet(isPresented: $showCreate) {
                CreateAnnouncementView()
                    .environmentObject(appState)
                    .onDisappear {
                        Task {
                            if let token = appState.token {
                                await vm.loadAnnouncements(token: token)
                            }
                        }
                    }
            }

            // ÉDITION
            .sheet(item: $editingAnnouncement) { ann in
                EditAnnouncementView(announcement: ann)
                    .environmentObject(appState)
                    .onDisappear {
                        Task {
                            if let token = appState.token {
                                await vm.loadAnnouncements(token: token)
                            }
                        }
                    }
            }

            // DÉTAIL
            .sheet(item: $selectedDetail) { ann in
                AnnouncementDetailView(item: ann)
            }

            .task {
                if let token = appState.token {
                    await vm.loadAnnouncements(token: token)
                }
            }
        }
    }
}
