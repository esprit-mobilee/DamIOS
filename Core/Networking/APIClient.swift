import Foundation
import Network

enum APIError: Error {
    case server(status: Int, body: String)
    case invalidResponse
    case invalidURL
}

final class APIClient {
    static let shared = APIClient()
    private init() {}

    /// Détecte automatiquement l’IP locale du Mac (utilisée par Nest)
    private var localIPAddress: String {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>?

        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next }
                guard let interface = ptr?.pointee else { continue }

                // Wi-Fi ou Ethernet
                let name = String(cString: interface.ifa_name)
                if name == "en0" || name == "en1" {
                    var addr = interface.ifa_addr.pointee
                    if addr.sa_family == UInt8(AF_INET) {
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(&addr,
                                    socklen_t(interface.ifa_addr.pointee.sa_len),
                                    &hostname,
                                    socklen_t(hostname.count),
                                    nil,
                                    0,
                                    NI_NUMERICHOST)
                        address = String(cString: hostname)
                        break
                    }
                }
            }
            freeifaddrs(ifaddr)
        }

        return address ?? "127.0.0.1" // fallback
    }

    /// Construit automatiquement le bon URL en fonction du réseau
    private var baseURL: URL {
        let urlString = "http://\(localIPAddress):3000/api"
        guard let url = URL(string: urlString) else {
            fatalError("❌ URL invalide: \(urlString)")
        }
        print("🌐 Base URL utilisée : \(urlString)")
        return url
    }

    // -------------------------------------------------------------
    // MARK: - Requête générique
    // -------------------------------------------------------------
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

        print("⬅️ [API] status: \(http.statusCode)")
        print("⬅️ [API] raw: \(String(data: data, encoding: .utf8) ?? "no body")")

        guard (200..<300).contains(http.statusCode) else {
            let bodyText = String(data: data, encoding: .utf8) ?? ""
            throw APIError.server(status: http.statusCode, body: bodyText)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(T.self, from: data)
    }
    // pour les requêtes sans body de retour (DELETE ...)
    func requestEmpty(
        _ path: String,
        method: String = "GET",
        token: String? = nil
    ) async throws {
        let url = baseURL.appendingPathComponent(path)
        var req = URLRequest(url: url)
        req.httpMethod = method
        if let token { req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }

        let (_, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
}
