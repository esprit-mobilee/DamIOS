import SwiftUI

struct AdminEventsListView: View {
    @EnvironmentObject var appState: AppState
    @State private var events: [Event] = []
    @State private var showAdd = false
    @State private var eventToEdit: Event?

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 22) {
                    ForEach(events) { event in
                        NavigationLink {
                            EventDetailView(event: event)
                        } label: {
                            eventCard(event)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 12)
            }
            .navigationTitle("Événements")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAdd = true } label: {
                        ZStack {
                            Circle()
                                .fill(Color.espritRedPrimary.opacity(0.12))
                                .frame(width: 34, height: 34)

                            Image(systemName: "plus")
                                .font(.headline)
                                .foregroundColor(.espritRedPrimary)
                        }
                    }
                }
            }
            .task {
                await loadEvents()
            }
            .sheet(isPresented: $showAdd) {
                if let token = appState.token {
                    AdminAddEventView(token: token) { newEvent in
                        events.insert(newEvent, at: 0)
                    }
                }
            }
        }
    }


    // MARK: - CARD DESIGN (même style que internshipCard)
    @ViewBuilder
    func eventCard(_ event: Event) -> some View {
        HStack(spacing: 16) {

            // IMAGE
            AsyncImage(url: event.fullImageURL) { phase in
                switch phase {
                case .success(let img):
                    img.resizable().scaledToFill()
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

            // TEXTE
            VStack(alignment: .leading, spacing: 8) {

                Text(event.title)
                    .font(.title3)
                    .bold()
                    .foregroundColor(.black)

                if let category = event.category, !category.isEmpty {
                    Text(category)
                        .font(.headline)
                        .foregroundColor(.gray)
                }

                Label(formatDate(event.date), systemImage: "calendar")
                    .font(.subheadline)
                    .foregroundColor(.gray.opacity(0.8))
            }

            Spacer()

            // BOUTON EDIT
            Button {
                eventToEdit = event
            } label: {
                Image(systemName: "square.and.pencil")
                    .font(.title2)
                    .foregroundColor(.espritRedPrimary)
            }
            .buttonStyle(.plain)
            .sheet(item: $eventToEdit) { selected in
                if let token = appState.token {
                    AdminEditEventView(
                        event: Binding(
                            get: { selected },
                            set: { updated in
                                // mettre à jour la liste
                                if let index = events.firstIndex(where: { $0.id == updated.id }) {
                                    events[index] = updated
                                }
                            }
                        ),
                        token: token
                    )
                }
            }

        }
        .padding()
        .frame(maxWidth: .infinity)
        .frame(height: 160)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(.white)
                .shadow(color: .black.opacity(0.07), radius: 8, x: 0, y: 4)
        )
    }



    // MARK: - FORMAT DATE
    func formatDate(_ iso: String) -> String {
        let f = ISO8601DateFormatter()
        if let date = f.date(from: iso) {
            let df = DateFormatter()
            df.dateStyle = .medium
            df.timeStyle = .short
            return df.string(from: date)
        }
        return iso
    }

    // MARK: - LOAD
    private func loadEvents() async {
        guard let token = appState.token else { return }
        do {
            events = try await EspritAPI.shared.fetchEvents(token: token)
        } catch {
            print("Erreur load events:", error)
        }
    }
}
