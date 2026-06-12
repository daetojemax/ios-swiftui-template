import Observation
import SwiftUI

@Observable
@MainActor
public final class UserPreferences: Sendable {
    
    class Storage {
        @AppStorage("onboardingCompleted")
        var onboardingCompleted = false

        @AppStorage("isFirstStart")
        var isFirstStart = true
    }

    public static let shared = UserPreferences()

    private let storage = Storage()

    private init() {}

    public var onboardingCompleted: Bool {
        get { storage.onboardingCompleted }
        set { storage.onboardingCompleted = newValue }
    }

    public var isFirstStart: Bool {
        get { storage.isFirstStart }
        set { storage.isFirstStart = newValue }
    }
}
