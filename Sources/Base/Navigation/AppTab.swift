import Foundation
import Design
import SwiftUI

public enum AppTab: String, TabType {
    case main, profile

    public var id: String { rawValue }

    public var title: Text {
        switch self {
        case .main: return Text("Main")
        case .profile: return Text("Profile")
        }
    }

    public var icon: Image {
        switch self {
        case .main: return Image.homeTabIcon
        case .profile: return Image.profileTabIcon
        }
    }
}
