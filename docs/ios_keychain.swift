import Foundation
import Security

enum KeychainError: Error { case guardar(OSStatus), leer(OSStatus) }

struct KeychainHelper {
    static let service = "com.miapp.auth"
    static let account = "jwt_token"

    static func guardar(token: String) throws {
        let data = Data(token.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary) // evita duplicados

        var nuevo = query
        nuevo[kSecValueData as String] = data
        nuevo[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock

        let status = SecItemAdd(nuevo as CFDictionary, nil)
        guard status == errSecSuccess else { throw KeychainError.guardar(status) }
    }

    static func leer() throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecItemNotFound { return nil }
        guard status == errSecSuccess, let data = item as? Data else {
            throw KeychainError.leer(status)
        }
        return String(data: data, encoding: .utf8)
    }

    static func borrar() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
    }
}