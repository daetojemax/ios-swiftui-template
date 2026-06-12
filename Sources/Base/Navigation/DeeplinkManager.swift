import Foundation
import Observation

public enum DeeplinkEvent: Sendable {
    case settings
    case event(id: String)
    case url(String)
}

@Observable
@MainActor
public final class DeeplinkManager {
    
    public static let shared = DeeplinkManager()

    public let events: AsyncStream<DeeplinkEvent>
    private let eventContinuation: AsyncStream<DeeplinkEvent>.Continuation

    private init() {
        let (stream, continuation) = AsyncStream<DeeplinkEvent>.makeStream()
        self.events = stream
        self.eventContinuation = continuation
    }
}

// MARK: - Public API

public extension DeeplinkManager {
    // "/settings" -> .settings
    // "/event/21" -> .event(id: "21")
    func open(deeplink: String) {
        guard deeplink.hasPrefix("/") else {
            return
        }

        if let event = event(from: deeplink) {
            eventContinuation.yield(event)
        }
    }

    // template://settings -> .settings
    // https://template.com/event/21 -> .event(id: "21")
    // https://example.com/unknown -> .url("https://example.com/unknown")
    func open(url: URL) {
        let path: String
        if url.scheme?.lowercased() == "template" {
            path = [url.host, url.path].compactMap { $0 }.joined(separator: "/")
        } else {
            path = url.path
        }

        if let event = event(from: path) {
            eventContinuation.yield(event)
            return
        }

        eventContinuation.yield(.url(url.absoluteString))
    }
}

// MARK: - Parsing

private extension DeeplinkManager {
    // "/settings" -> .settings
    // "/event/21" -> .event(id: "21")
    // "/unknown" -> nil
    func event(from value: String) -> DeeplinkEvent? {
        let path = pathComponents(from: value)
        guard let rawEntity = path.first else {
            return nil
        }

        let entity = rawEntity.lowercased()

        switch entity {
        case "settings":
            guard path.count == 1 else { return nil }
            return .settings
        case "event":
            guard path.count == 2 else { return nil }
            return .event(id: path[1])
        default:
            return nil
        }
    }

    func pathComponents(from value: String) -> [String] {
        value
            .components(separatedBy: "?")
            .first?
            .split(separator: "/")
            .map(String.init) ?? []
    }
}
