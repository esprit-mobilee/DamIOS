import Foundation
import UIKit

// MARK: - DTOs internes

private struct LoginRequest: Codable {
    let identifiant: String
    let password: String
}

/// Réponse vide pour les DELETE
private struct EmptyResponse: Decodable {}

final class EspritAPI {
    static let shared = EspritAPI()
    private init() {}

    private let client = APIClient.shared
    // ⚠️ vérifie bien cette IP (c’est celle que ton Nest affiche)
    private let baseAPIURL = URL(string: "http://localhost:3000/api")!

    // MARK: - AUTH
    func login(identifiant: String, password: String) async throws -> AuthResponse {
        let body = try JSONEncoder().encode(LoginRequest(identifiant: identifiant, password: password))
        return try await client.request("auth/login", method: "POST", body: body)
    }

    func getMe(token: String) async throws -> EspritUser {
        try await client.request("auth/me", token: token)
    }

    // MARK: - STAGES / INTERNSHIPS

    // MARK: - Créer une candidature
    func createApplication(
        token: String,
        userId: String,
        internshipId: String,
        cvUrl: String,
        coverLetter: String?
    ) async throws -> Application {

        let url = baseAPIURL.appendingPathComponent("applications")   // ✅ FIX HERE

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "userId": userId,
            "internshipId": internshipId,
            "cvUrl": cvUrl,
            "coverLetter": coverLetter ?? ""
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(Application.self, from: data)
    }


    // MARK: - Modifier une candidature
    func updateApplication(
        token: String,
        id: String,
        coverLetter: String?
    ) async throws -> Application {

        let url = baseAPIURL.appendingPathComponent("applications/\(id)")   // ✅ FIX HERE

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "coverLetter": coverLetter ?? ""
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(Application.self, from: data)
    }


    // MARK: - Supprimer une candidature
    func deleteApplication(token: String, id: String) async throws {
        let url = baseAPIURL.appendingPathComponent("applications/\(id)")   // ✅ FIX HERE

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        _ = try await URLSession.shared.data(for: request)
    }


    func getAllApplications(token: String) async throws -> [Application] {
        return try await client.request("applications", token: token)
    }

    /// Récupérer la liste
    func fetchInternshipOffers(token: String) async throws -> [InternshipOffer] {
        try await client.request("internship-offers", token: token)
    }
    /// ✅ Créer une offre de stage
    func createInternshipOffer(
        token: String,
        title: String,
        company: String,
        description: String,
        location: String?,
        duration: Int,
        salary: Int?,
        logo: UIImage?
    ) async throws -> InternshipOffer {
        try await multipartRequest(
            endpoint: "internship-offers",
            method: "POST",
            token: token,
            fields: [
                "title": title,
                "company": company,
                "description": description,
                "duration": "\(duration)"
            ],
            optionals: [
                "location": location,
                "salary": salary != nil ? "\(salary!)" : nil
            ],
            logo: logo
        )
    }

    /// ✅ Mettre à jour par ID
    func updateInternshipOffer(
        token: String,
        id: String,
        dto: UpdateInternshipOfferDto,
        logo: UIImage?
    ) async throws -> InternshipOffer {
        try await multipartRequest(
            endpoint: "internship-offers/\(id)",
            method: "PUT",
            token: token,
            fields: [
                "title": dto.title,
                "company": dto.company,
                "description": dto.description,
                "duration": "\(dto.duration)"
            ],
            optionals: [
                "location": dto.location,
                "salary": dto.salary != nil ? "\(dto.salary!)" : nil
            ],
            logo: logo
        )
    }

    /// ✅ Mettre à jour par titre (si tu veux continuer à l’utiliser)
    func updateInternshipOfferByTitle(
        token: String,
        title: String,
        dto: UpdateInternshipOfferDto,
        logo: UIImage?
    ) async throws -> InternshipOffer {

        return try await multipartRequest(
            endpoint: "internship-offers/by-title/\(title)",
            method: "PUT",
            token: token,
            fields: [
                "title": dto.title,
                "company": dto.company,
                "description": dto.description,
                "duration": "\(dto.duration)"
            ],
            optionals: [
                "location": dto.location,
                "salary": dto.salary != nil ? "\(dto.salary!)" : nil
            ],
            logo: logo
        )
    }

    /// Supprimer
    func deleteInternshipOffer(token: String, id: String) async throws {
        let _: EmptyResponse = try await client.request(
            "internship-offers/\(id)",
            method: "DELETE",
            token: token
        )
    }

    // MARK: - CLUBS

    func fetchClubs(token: String) async throws -> [Club] {
        try await client.request("clubs", token: token)
    }

    // CREATE — MULTIPART
    func createClub(
        token: String,
        name: String,
        description: String?,
        president: String?,
        tags: [String]?,
        image: Data?
    ) async throws -> Club {

        // Champs envoyés en texte
        var fields: [String: String] = [
            "name": name
        ]

        if let description { fields["description"] = description }
        if let president { fields["president"] = president }
        if let tags { fields["tags"] = tags.joined(separator: ",") }

        let optionals: [String: String?] = [:]

        // Data -> UIImage
        let uiImage = image != nil ? UIImage(data: image!) : nil

        return try await multipartRequest(
            endpoint: "clubs",
            method: "POST",
            token: token,
            fields: fields,
            optionals: optionals,
            logo: uiImage    // 👈 envoyé en tant que "image"
        )
    }

    // UPDATE — MULTIPART
    func updateClub(
        token: String,
        id: String,
        name: String?,
        description: String?,
        president: String?,
        tags: [String]?,
        image: Data?
    ) async throws -> Club {

        var fields: [String: String] = [:]

        if let name { fields["name"] = name }
        if let description { fields["description"] = description }
        if let president { fields["president"] = president }
        if let tags { fields["tags"] = tags.joined(separator: ",") }

        let optionals: [String: String?] = [:]

        let uiImage = image != nil ? UIImage(data: image!) : nil

        return try await multipartRequest(
            endpoint: "clubs/\(id)",
            method: "PUT",
            token: token,
            fields: fields,
            optionals: optionals,
            logo: uiImage     // 👈 envoyé en tant que "image"
        )
    }


    func deleteClub(token: String, id: String) async throws {
        let _: EmptyResponse = try await client.request(
            "clubs/\(id)",
            method: "DELETE",
            token: token
        )
    }
    func fetchApplications(token: String) async throws -> [Application] {
        let url = baseAPIURL.appendingPathComponent("applications")

        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: req)
        return try JSONDecoder().decode([Application].self, from: data)
    }

    private func multipartRequest<T: Decodable>(
        endpoint: String,
        method: String,
        token: String,
        fields: [String: String],
        optionals: [String: String?],
        logo: UIImage?
    ) async throws -> T {

        let url = baseAPIURL.appendingPathComponent(endpoint)
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let boundary = "Boundary-\(UUID().uuidString)"
        req.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        func appendField(_ name: String, _ value: String) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }

        // Champs textes
        for (k, v) in fields { appendField(k, v) }
        for (k, v) in optionals { if let v { appendField(k, v) } }

        // ✅ IMAGE ENVOYÉE SOUS LE CHAMP "image"
        if let logo,
           let imgData = logo.jpegData(compressionQuality: 0.8) {

            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imgData)
            body.append("\r\n".data(using: .utf8)!)
        }

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        req.httpBody = body

        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode)
        else {
            let msg = String(data: data, encoding: .utf8) ?? "Erreur inconnue"
            throw NSError(domain: "EspritAPI",
                          code: (response as? HTTPURLResponse)?.statusCode ?? -1,
                          userInfo: [NSLocalizedDescriptionKey: msg])
        }

        return try JSONDecoder().decode(T.self, from: data)
    }
    func fetchEvents(token: String) async throws -> [Event] {
           try await client.request("events", token: token)
       }

       func getEventById(token: String, id: String) async throws -> Event {
           try await client.request("events/\(id)", token: token)
       }

       func createEvent(
           token: String,
           title: String,
           description: String?,
           date: String,
           location: String?,
           category: String?,
           organizerId: String,
           image: UIImage?
       ) async throws -> Event {

           try await multipartRequest(
               endpoint: "events",
               method: "POST",
               token: token,
               fields: [
                   "title": title,
                   "date": date,
                   "organizerId": organizerId
               ],
               optionals: [
                   "description": description,
                   "location": location,
                   "category": category
               ],
               logo: image    // envoyé sous "image"
           )
       }

       func updateEvent(
           token: String,
           id: String,
           fields: [String: String],
           optionals: [String: String?],
           image: UIImage?
       ) async throws -> Event {

           try await multipartRequest(
               endpoint: "events/\(id)",
               method: "PUT",
               token: token,
               fields: fields,
               optionals: optionals,
               logo: image
           )
       }

       func deleteEvent(token: String, id: String) async throws {
           let _: EmptyResponse = try await client.request(
               "events/\(id)",
               method: "DELETE",
               token: token
           )
       }
    func updateApplicationStatus(
        token: String,
        id: String,
        status: String
    ) async throws -> Application {

        let body: [String: Any] = ["status": status]

        return try await request(
            endpoint: "applications/\(id)",
            method: "PATCH",
            token: token,
            body: body
        )
    }
    // MARK: - Fetch internship by ID
    func getInternshipById(token: String, id: String) async throws -> InternshipOffer {
        try await request(
            endpoint: "internship-offers/\(id)",
            token: token
        )
    }

    // MARK: - Fetch user by ID
    func getUserById(token: String, id: String) async throws -> EspritUser {
        try await request(
            endpoint: "utilisateurs/\(id)",
            token: token
        )
    }
    // MARK: - Generic JSON Request
    private func request<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        token: String,
        body: [String: Any]? = nil
    ) async throws -> T {

        let url = baseAPIURL.appendingPathComponent(endpoint)

        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let body {
            req.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        }

        let (data, response) = try await URLSession.shared.data(for: req)

        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard (200...299).contains(http.statusCode) else {
            let msg = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NSError(
                domain: "EspritAPI",
                code: http.statusCode,
                userInfo: [NSLocalizedDescriptionKey : msg]
            )
        }

        return try JSONDecoder().decode(T.self, from: data)
    }




}
