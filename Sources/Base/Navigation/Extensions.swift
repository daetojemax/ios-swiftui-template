import Foundation

extension URL {
    public static func deepLink<Destination: DestinationType>(
        scheme: String,
        destinations: [Destination],
        parameters: [String: String] = [:]
    ) -> URL? {
        guard !destinations.isEmpty else { return nil }

        var components = URLComponents()
        components.scheme = scheme

        components.host = String(describing: destinations.first!)

        if destinations.count > 1 {
            components.path =
                "/" + destinations.dropFirst().map { String(describing: $0) }.joined(separator: "/")
        }

        if !parameters.isEmpty {
            components.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        }

        return components.url
    }
}
