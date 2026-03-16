import Foundation
import Models
import SwiftUI
import Observation

@Observable
public final class CurrentUser: Sendable {

    private let client: NetworkClient

    public let user: User

    public init(client: NetworkClient, user: User) {
        self.client = client
        self.user = user
    }
}
