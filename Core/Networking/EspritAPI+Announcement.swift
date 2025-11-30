import Foundation

extension EspritAPI {

    // ---------------------------------------------------
    // MARK: - GET ALL ANNOUNCEMENTS
    // ---------------------------------------------------
    func getAnnouncements(token: String) async throws -> [Announcement] {
        try await client.request(
            "announcements",
            token: token
        )
    }

    // ---------------------------------------------------
    // MARK: - CREATE ANNOUNCEMENT
    // ---------------------------------------------------
    func createAnnouncement(
        title: String,
        content: String,
        audience: String,
        senderId: String,
        token: String
    ) async throws -> Announcement {

        let body = try JSONEncoder().encode([
            "title": title,
            "content": content,
            "audience": audience,
            "senderId": senderId
        ])

        return try await client.request(
            "announcements",
            method: "POST",
            body: body,
            token: token
        )
    }

    // ---------------------------------------------------
    // MARK: - UPDATE ANNOUNCEMENT
    // ---------------------------------------------------
    func updateAnnouncement(
            id: String,
            title: String,
            content: String,
            audience: String,
            senderId: String,
            token: String
        ) async throws -> Announcement {

            let body = try JSONEncoder().encode([
                "title": title,
                "content": content,
                "audience": audience,
                "senderId": senderId
            ])

            return try await client.request(
                "announcements/\(id)",
                method: "PUT",
                body: body,
                token: token
            )
        }
    

    // ---------------------------------------------------
    // MARK: - DELETE ANNOUNCEMENT
    // ---------------------------------------------------
    func deleteAnnouncement(id: String, token: String) async throws -> Bool {

        let _: EmptyResponse = try await client.request(
            "announcements/\(id)",
            method: "DELETE",
            token: token
        )

        return true
    }
}

// ❗ Obligatoire si pas déjà ailleurs
struct EmptyResponse: Codable {}
