import Foundation

public enum URLNavigationHelper {
    static func navigate<Destination: DestinationType>(
        url: URL,
        applyDestinations: ([Destination]) -> Void
    ) -> Bool {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return false
        }

        var pathComponents: [String] = []

        if let host = components.host {
            pathComponents.append(host)
        }

        if !components.path.isEmpty {
            let pathParts = components.path.split(separator: "/").map(String.init).filter { !$0.isEmpty }
            pathComponents.append(contentsOf: pathParts)
        }

        guard !pathComponents.isEmpty else { return false }

        let queryParameters = parseQueryParameters(from: components.queryItems)

        var destinations: [Destination] = []
        for pathComponent in pathComponents {
            if let destination = Destination.from(
                path: pathComponent, fullPath: pathComponents, parameters: queryParameters)
            {
                destinations.append(destination)
            }
        }

        guard !destinations.isEmpty else { return false }

        applyDestinations(destinations)
        return true
    }

    private static func parseQueryParameters(from queryItems: [URLQueryItem]?) -> [String: String] {
        guard let queryItems = queryItems else { return [:] }

        var parameters: [String: String] = [:]
        for item in queryItems {
            if let value = item.value {
                parameters[item.name] = value
            }
        }
        return parameters
    }
}
