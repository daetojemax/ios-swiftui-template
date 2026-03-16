import Foundation

public class NetworkConst {
    public static let isDebug: Bool = false
    public static let currentDomain: String = isDebug ? "stage.api.example.com" : "api.example.com"
    public static let currentHostUrl: String = "https://\(currentDomain)"
    public static let requestTimeout: TimeInterval = 30
}
