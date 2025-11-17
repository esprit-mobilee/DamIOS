import SwiftUI

struct StudentStagesView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var vm = InternshipListViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 22) {
                    ForEach(vm.offers) { offer in
                        NavigationLink {
                            StudentStageDetailView(offer: offer)
                                .environmentObject(appState)
                        } label: {
                            StudentStageCard(offer: offer)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationTitle("Stages")
            .task {
                if let token = appState.token {
                    await vm.load(token: token)
                }
            }
        }
    }
}

struct StudentStageCard: View {
    let offer: InternshipOffer

    var body: some View {
        HStack(spacing: 16) {

            AsyncImage(url: offer.logoFullURL) { phase in
                switch phase {
                case .success(let img):
                    img.resizable().scaledToFill()
                case .failure(_):
                    Image(systemName: "briefcase.fill")
                        .resizable().scaledToFit()
                        .foregroundColor(.red)
                        .padding(20)
                default:
                    ProgressView()
                }
            }
            .frame(width: 110, height: 110)
            .background(Color.gray.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 18))

            VStack(alignment: .leading, spacing: 6) {
                Text(offer.title).font(.title3.bold())
                Text(offer.company).font(.subheadline).foregroundColor(.gray)

                if let loc = offer.location {
                    Label(loc, systemImage: "mappin.and.ellipse")
                        .font(.subheadline)
                        .foregroundColor(.gray.opacity(0.8))
                }

                HStack(spacing: 12) {
                    Label("\(offer.duration) sem.", systemImage: "clock")
                        .foregroundColor(.red)
                        .font(.caption)

                    if let sal = offer.salary {
                        Label("\(sal) TND", systemImage: "banknote")
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                }
            }

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .frame(height: 150)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(.white)
                .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 4)
        )
    }
}
