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
}
