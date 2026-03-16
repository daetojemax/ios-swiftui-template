import Foundation
import KeychainSwift

public struct KeychainWrapper {

    private nonisolated(unsafe) static let keychain: KeychainSwift = {
        let kc = KeychainSwift()
        kc.accessGroup = nil
        return kc
    }()

    public static func set(_ value: String, for key: String) {
        keychain.set(value, forKey: key)
    }

    public static func get(_ key: String) -> String? {
        keychain.get(key)
    }

    public static func delete(_ key: String) {
        keychain.delete(key)
    }
}
