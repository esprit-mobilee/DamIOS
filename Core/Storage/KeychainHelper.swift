import Foundation
import Security

final class KeychainHelper {
    static let shared = KeychainHelper()
    private init() {}

    func save(_ data: Data, service: String, account: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    func read(service: String, account: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &item)
        return item as? Data
    }

    func delete(service: String, account: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
    }
}

private let tokenService = "esprit.token.service"
private let tokenAccount = "esprit.token.account"

func saveToken(_ token: String) {
    KeychainHelper.shared.save(Data(token.utf8), service: tokenService, account: tokenAccount)
}

func readToken() -> String? {
    if let data = KeychainHelper.shared.read(service: tokenService, account: tokenAccount) {
        return String(data: data, encoding: .utf8)
    }
    return nil
}

func deleteToken() {
    KeychainHelper.shared.delete(service: tokenService, account: tokenAccount)
}
