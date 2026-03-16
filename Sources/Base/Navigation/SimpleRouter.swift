import Foundation
import SwiftUI

@Observable
@MainActor
public final class SimpleRouter<Destination: DestinationType, Sheet: SheetType, FullScreen: FullScreenType> {

    public var path: [Destination] = []
    public var presentedSheet: Sheet?
    public var presentedFullScreen: FullScreen?

    public init() {}

    public func popToRoot() {
        path = []
    }

    public func popNavigation() {
        if !path.isEmpty {
            path.removeLast()
        }
    }

    public func navigateTo(_ destination: Destination) {
        path.append(destination)
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
    public func navigate(to url: URL) -> Bool {
        return URLNavigationHelper.navigate(url: url) { destinations in
            path = destinations
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
