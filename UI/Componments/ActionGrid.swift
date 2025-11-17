import SwiftUI

struct ActionItem: Identifiable {
    let id = UUID()
    let icon: String
    let label: String
}
struct ActionGrid: View {
    let role: UserRole
    var onNavigateToEvents: (() -> Void)?    // <--- ajouté

    private var actions: [ActionItem] {
        switch role {
        case .STUDENT:
            return [
                ActionItem(icon: "calendar", label: "Emploi du temps"),
                ActionItem(icon: "person.fill.xmark", label: "Absences"),
                ActionItem(icon: "doc.text.magnifyingglass", label: "Examens"),
                ActionItem(icon: "chart.bar", label: "Résultats"),
                ActionItem(icon: "briefcase.fill", label: "Stages"),
                ActionItem(icon: "megaphone.fill", label: "Annonces")
            ]
        case .TEACHER:
            return [
                ActionItem(icon: "book.closed.fill", label: "Mes cours"),
                ActionItem(icon: "checkmark.circle", label: "Présences"),
                ActionItem(icon: "doc.text", label: "Examens"),
                ActionItem(icon: "megaphone.fill", label: "Annonces"),
                ActionItem(icon: "envelope.fill", label: "Messages")
            ]
        case .PARENT:
            return [
                ActionItem(icon: "person.2.fill", label: "Suivi de l'élève"),
                ActionItem(icon: "person.fill.xmark", label: "Absences"),
                ActionItem(icon: "chart.bar", label: "Résultats"),
                ActionItem(icon: "megaphone.fill", label: "Annonces"),
                ActionItem(icon: "envelope.fill", label: "Messages")
            ]
        case .ADMIN:
            return [
                ActionItem(icon: "person.3.fill", label: "Gestion utilisateurs"),
                ActionItem(icon: "megaphone.fill", label: "Annonces"),
                ActionItem(icon: "briefcase.fill", label: "Stages"),
                ActionItem(icon: "calendar", label: "Événements"),
                ActionItem(icon: "envelope.fill", label: "Messages internes")
            ]
        case .PRESIDENT:
            return [
                ActionItem(icon: "person.3.fill", label: "Gestion Clubs et Event"),
                ActionItem(icon: "briefcase.fill", label: "Clubs"),
                ActionItem(icon: "calendar", label: "Événements"),
                ActionItem(icon: "envelope.fill", label: "Messages internes")
            ]
        }
    }

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: 16)], spacing: 16) {
            ForEach(actions) { item in
                VStack(spacing: 10) {
                    Image(systemName: item.icon)
                        .font(.system(size: 30))
                        .foregroundColor(.espritRedPrimary)
                    Text(item.label)
                        .font(.footnote)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, minHeight: 90)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                .onTapGesture {
                    handleTap(item)
                }
            }
        }
    }

    func handleTap(_ item: ActionItem) {
        if item.label == "Événements" {
            onNavigateToEvents?()
        }
    }
}
