import SwiftUI

struct AnnouncementCard: View {

    let item: Announcement
    let onEdit: (() -> Void)?
    let onDelete: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // HEADER : Audience + Date + Buttons
            HStack {

                Text(item.audience?.uppercased() ?? "TOUS")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red)
                    .cornerRadius(6)

                Spacer()

                Text(formatDate(item.createdAt))
                    .font(.caption)
                    .foregroundColor(.gray)

                Button {
                    onEdit?()
                } label: {
                    Image(systemName: "pencil")
                        .foregroundColor(.orange)
                        .font(.system(size: 16, weight: .bold))
                }
                .padding(.leading, 6)

                Button {
                    onDelete?()
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .font(.system(size: 16, weight: .bold))
                }
                .padding(.leading, 4)
            }

            Text(item.title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.black)

            Text(item.content)
                .font(.system(size: 15))
                .foregroundColor(.gray)
                .lineLimit(3)

        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
        )
    }

    func formatDate(_ iso: String) -> String {
        let f = ISO8601DateFormatter()
        if let date = f.date(from: iso) {
            let df = DateFormatter()
            df.dateStyle = .medium
            return df.string(from: date)
        }
        return iso
    }
}
