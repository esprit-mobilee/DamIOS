import Foundation

// MARK: - Rôle flexible
enum UserRole: String, Decodable {
    case STUDENT
    case TEACHER
    case PARENT
    case ADMIN
    case PRESIDENT

    // pour quand le backend envoie "student" ou "Admin"
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self).uppercased()
        self = UserRole(rawValue: raw) ?? .STUDENT
    }
}

// MARK: - Utilisateur très tolérant
struct EspritUser: Decodable {
    let id: String?
    let fullName: String
    let roles: [UserRole]

    // init manuel qu'on peut appeler
    init(id: String? = nil, fullName: String, roles: [UserRole] = [.STUDENT]) {
        self.id = id
        self.fullName = fullName
        self.roles = roles
    }

    enum CodingKeys: String, CodingKey {
        case id
        case _id
        case fullName
        case name
        case username
        case firstName
        case lastName
        case roles
        case role   // cas où le backend envoie un seul rôle
        case profil // on essaye tout
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)

        // id
        self.id = (try? c.decode(String.self, forKey: .id))
            ?? (try? c.decode(String.self, forKey: ._id))

        // full name: on essaie plusieurs clés
        if let fn = try? c.decode(String.self, forKey: .fullName) {
            self.fullName = fn
        } else if let n = try? c.decode(String.self, forKey: .name) {
            self.fullName = n
        } else if let u = try? c.decode(String.self, forKey: .username) {
            self.fullName = u
        } else if let f = try? c.decode(String.self, forKey: .firstName),
                  let l = try? c.decode(String.self, forKey: .lastName) {
            self.fullName = "\(f) \(l)"
        } else {
            self.fullName = "Utilisateur ESPRIT"
        }

        // rôles : tableau ou string
        if let arr = try? c.decode([UserRole].self, forKey: .roles) {
            self.roles = arr
        } else if let one = try? c.decode(UserRole.self, forKey: .role) {
            self.roles = [one]
        } else if let one = try? c.decode(UserRole.self, forKey: .profil) {
            self.roles = [one]
        } else {
            self.roles = [.STUDENT]
        }
    }
}

// MARK: - Réponse login
struct AuthResponse: Decodable {
    let accessToken: String
    let user: EspritUser?

    enum CodingKeys: String, CodingKey {
        case accessToken
        case access_token
        case user
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        if let t = try? c.decode(String.self, forKey: .accessToken) {
            self.accessToken = t
        } else {
            self.accessToken = try c.decode(String.self, forKey: .access_token)
        }
        self.user = try? c.decode(EspritUser.self, forKey: .user)
    }
}
