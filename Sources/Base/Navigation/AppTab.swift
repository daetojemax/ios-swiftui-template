import Foundation
import Design
import SwiftUI

public enum AppTab: String, TabType {
    case main, profile, console

    public var id: String { rawValue }

    public var title: Text {
        switch self {
        case .main: return Text("Main")
        case .console: return Text("Console")
        case .profile: return Text("Profile")
        }
    }

    public var icon: Image {
        switch self {
        case .main: return Image.homeTabIcon
        case .console: return Image(systemName: "ant")
        case .profile: return Image.profileTabIcon
        }
    }
}
