import Foundation

// Template examples for handling push payloads.
// Replace or extend these cases with app-specific business actions as needed.
public enum PushEvent: Sendable {
    case deeplink(String)
    case alert(title: String, body: String)
}

public struct PushPayloadParser: Sendable {
    
    public init() {}

    public func event(from userInfo: [AnyHashable: Any]) -> PushEvent? {
        // Example payload: { "deeplink": "/settings" }
        if let deeplink = userInfo["deeplink"] as? String {
            return .deeplink(deeplink)
        }

        // Example payload:
        // {
        //   "alert": {
        //     "title": "Template update",
        //     "body": "New demo content is available."
        //   }
        // }
        guard let alert = userInfo["alert"] as? [String: Any] else {
            return nil
        }

        guard
            let title = alert["title"] as? String,
            let body = alert["body"] as? String
        else {
            return nil
        }

        return .alert(title: title, body: body)
    }
}
