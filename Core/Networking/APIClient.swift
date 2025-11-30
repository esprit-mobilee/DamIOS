import Foundation

enum APIError: Error {
    case server(status: Int, body: String)
    case invalidResponse
    case invalidURL
}

final class APIClient {
    static let shared = APIClient()
    private init() {}

    // ✅ IP DE TON WINDOWS QUI HÉBERGE NEST
    private var baseURL: URL {
        let urlString = "http://192.168.137.1:3000/api"
        print("🌐 Base URL utilisée : \(urlString)")
        guard let url = URL(string: urlString) else {
            fatalError("URL invalide : \(urlString)")
        }
        return url
    }

    // Requête générique avec décodage
    func request<T: Decodable>(
        _ path: String,
        method: String = "GET",
        body: Data? = nil,
        token: String? = nil
    ) async throws -> T {

        let url = baseURL.appendingPathComponent(path)
        var req = URLRequest(url: url)
        req.httpMethod = method

        if let token {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        if let body {
            req.httpBody = body
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        print("➡️ [API] \(method) \(url.absoluteString)")

        let (data, response) = try await URLSession.shared.data(for: req)

        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        print("⬅️ Status: \(http.statusCode)")
        print("⬅️ Body: \(String(data: data, encoding: .utf8) ?? "")")

        guard (200..<300).contains(http.statusCode) else {
            throw APIError.server(
                status: http.statusCode,
                body: String(data: data, encoding: .utf8) ?? ""
            )
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(T.self, from: data)
    }
}
