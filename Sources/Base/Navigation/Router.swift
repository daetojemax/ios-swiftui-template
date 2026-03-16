import Foundation
import SwiftUI

@Observable
@MainActor
public final class Router<Tab: TabType, Destination: DestinationType, Sheet: SheetType, FullScreen: FullScreenType> {

    private var paths: [Tab: [Destination]] = [:]

    public var selectedTab: Tab
    public var presentedSheet: Sheet?
    public var presentedFullScreen: FullScreen?

    public init(initialTab: Tab) {
        self.selectedTab = initialTab
    }

    public subscript(tab: Tab) -> [Destination] {
        get { paths[tab] ?? [] }
        set { paths[tab] = newValue }
    }

    public var selectedTabPath: [Destination] {
        paths[selectedTab] ?? []
    }

    public var isInDetailView: Bool {
        !selectedTabPath.isEmpty
    }

    public func popToRoot(for tab: Tab? = nil) {
        paths[tab ?? selectedTab] = []
    }

    public func popNavigation(for tab: Tab? = nil) {
        let targetTab = tab ?? selectedTab
        if paths[targetTab]?.isEmpty == false {
            paths[targetTab]?.removeLast()
        }
    }

    public func navigateTo(_ destination: Destination, for tab: Tab? = nil) {
        let targetTab = tab ?? selectedTab
        if paths[targetTab] == nil {
            paths[targetTab] = [destination]
        } else {
            paths[targetTab]?.append(destination)
        }
    }

    public func presentSheet(_ sheet: Sheet) {
        presentedSheet = sheet
    }

    public func dismissSheet() {
        presentedSheet = nil
    }

    public func presentFullScreen(_ fullScreen: FullScreen) {
        presentedFullScreen = fullScreen
    }

    public func dismissFullScreen() {
        presentedFullScreen = nil
    }

    @discardableResult
    public func navigateFullScreen(to url: URL) -> Bool where FullScreen: DestinationType {
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

        guard !pathComponents.isEmpty, let firstPath = pathComponents.first else { return false }

        var parameters: [String: String] = [:]
        if let queryItems = components.queryItems {
            for item in queryItems {
                if let value = item.value {
                    parameters[item.name] = value
                }
            }
        }

        if let fullScreen = FullScreen.from(path: firstPath, fullPath: pathComponents, parameters: parameters) {
            presentFullScreen(fullScreen)
            return true
        }

        return false
    }

    @discardableResult
    public func navigate(to url: URL) -> Bool {
        return URLNavigationHelper.navigate(url: url) { destinations in
            paths[selectedTab] = destinations
        }
    }

    @discardableResult
    public func navigate(to urlString: String) -> Bool {
        guard let url = URL(string: urlString) else {
            return false
        }
        return navigate(to: url)
    }
}
