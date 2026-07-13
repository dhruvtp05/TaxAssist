import Foundation
import CryptoKit
import Security

class SecurityManager {
    static let shared = SecurityManager()
    
    private let keyTag = "com.taxassist.encryptionkey"
    private var encryptionKey: SymmetricKey!

    private init() {
        self.encryptionKey = loadOrGenerateKey()
    }

    // MARK: - 1. Encrypt Data (Before sending to Firebase)
    func encrypt(_ text: String) throws -> String {
        guard let data = text.data(using: .utf8) else { return "" }
        
        let sealedBox = try AES.GCM.seal(data, using: encryptionKey)
        
        return sealedBox.combined?.base64EncodedString() ?? ""
    }

    // MARK: - 2. Decrypt Data (After downloading from Firebase)
    func decrypt(_ base64String: String) throws -> String {
        guard let combinedData = Data(base64Encoded: base64String) else { return "" }
        
        let sealedBox = try AES.GCM.SealedBox(combined: combinedData)
        let decryptedData = try AES.GCM.open(sealedBox, using: encryptionKey)
        
        return String(data: decryptedData, encoding: .utf8) ?? ""
    }

    // MARK: - 3. Keychain Logic (The Vault)
    private func loadOrGenerateKey() -> SymmetricKey {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keyTag,
            kSecReturnData as String: true
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        if status == errSecSuccess, let keyData = item as? Data {
            return SymmetricKey(data: keyData)
        } else {
            let newKey = SymmetricKey(size: .bits256)
            let keyData = newKey.withUnsafeBytes { Data(Array($0)) }

            let addQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: keyTag,
                kSecValueData as String: keyData,
                kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
            ]

            SecItemAdd(addQuery as CFDictionary, nil)
            return newKey
        }
    }
}
