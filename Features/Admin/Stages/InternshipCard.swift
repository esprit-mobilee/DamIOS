import SwiftUI

struct InternshipCard: View {
    let offer: InternshipOffer

    var body: some View {
        HStack(spacing: 16) {

            // Logo entreprise
            AsyncImage(url: offer.logoFullURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                case .failure(_):
                    Image(systemName: "briefcase.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.gray.opacity(0.3))

                default:
                    ProgressView()
                        .frame(width: 60, height: 60)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(offer.title)
                    .font(.headline)

                Text(offer.company)
                    .font(.subheadline)
                    .foregroundColor(.gray)

                if let loc = offer.location {
                    Text(loc)
                        .font(.caption)
                        .foregroundColor(.gray.opacity(0.8))
                }
            }

            Spacer()
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
}

