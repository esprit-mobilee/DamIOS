import Foundation

// Rôle côté app (pour la navigation)
enum UserRole: String, Codable {
    case student = "STUDENT"
    case teacher = "TEACHER"
    case parent  = "PARENT"
    case admin   = "ADMIN"
    case user    = "USER"
}

// Modèle user simplifié (ce que l’app utilise)
struct EspritUser: Codable {
    let id: String
    let email: String
    let role: String
    
    // Compatibilité avec l’ancien code (SideMenu, RoleRouter, etc.)
    var fullName: String { email }
    
    var roles: [UserRole] {
        if let r = UserRole(rawValue: role.uppercased()) {
            return [r]
        } else {
            return [.user]
        }
    }
}
