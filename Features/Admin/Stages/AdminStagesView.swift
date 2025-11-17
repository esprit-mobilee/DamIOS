import SwiftUI

struct AdminStagesView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var vm = InternshipListViewModel()

    @State private var showAdd = false
    @State private var offerToEdit: InternshipOffer?

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 22) {
                    ForEach(vm.offers) { offer in

                        NavigationLink {
                            AdminStageDetailView(offer: offer)
                        } label: {
                            internshipCard(offer)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 12)
            }
            .navigationTitle("Stages")
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
                if let token = appState.token {
                    await vm.load(token: token)
                }
            }
            .sheet(isPresented: $showAdd) {
                AdminAddInternshipView { newOffer in
                    vm.offers.insert(newOffer, at: 0)
                }
                .environmentObject(appState)
            }
        }
    }

    // MARK: - CARD DESIGN MODERNE & GRANDE
    @ViewBuilder
    func internshipCard(_ offer: InternshipOffer) -> some View {
        HStack(spacing: 16) {

            // MARK: Image LARGE
            AsyncImage(url: offer.logoFullURL) { phase in
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
            .frame(width: 110, height: 110)     // 👉 IMAGE BEAUCOUP PLUS GRANDE
            .background(Color.gray.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 18))

            // MARK: Infos
            VStack(alignment: .leading, spacing: 8) {
                Text(offer.title)
                    .font(.title3)              // 👉 PLUS GRAND
                    .bold()
                    .foregroundColor(.black)

                Text(offer.company)
                    .font(.headline)
                    .foregroundColor(.gray)

                if let loc = offer.location {
                    Label(loc, systemImage: "mappin.and.ellipse")
                        .font(.subheadline)
                        .foregroundColor(.gray.opacity(0.8))
                }
            }

            Spacer()

            // MARK: Bouton Modifier
            Button {
                offerToEdit = offer
            } label: {
                Image(systemName: "square.and.pencil")
                    .font(.title2)
                    .foregroundColor(.espritRedPrimary)
            }
            .buttonStyle(.plain)
            .sheet(item: $offerToEdit) { offer in
                if let token = appState.token {
                    AdminEditInternshipView(token: token, offer: offer) { updated in
                        if let idx = vm.offers.firstIndex(where: { $0._id == updated._id }) {
                            vm.offers[idx] = updated
                        }
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .frame(height: 160)   // 👉 CARD BEAUCOUP PLUS GRANDE
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(.white)
                .shadow(color: .black.opacity(0.07), radius: 8, x: 0, y: 4)
        )
    }
}
