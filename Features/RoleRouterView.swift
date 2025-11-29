import SwiftUI

struct RoleRouterView: View {
    let user: EspritUser1

    var body: some View {
        switch user.role {
        case "Admin":
            Text("Admin Home")   // Tu changeras plus tard
        case "Teacher":
            Text("Teacher Home")
        case "Parent":
            Text("Parent Home")
        case "Student":
            Text("Student Home")

        default:
            Text("Aucun rôle reconnu")
        }
    }
}
