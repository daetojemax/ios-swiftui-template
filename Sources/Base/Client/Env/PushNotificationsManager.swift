import Foundation
import Models
import Observation
import UIKit
import UserNotifications

extension UNNotification: @unchecked @retroactive Sendable {}
extension UNNotificationResponse: @unchecked @retroactive Sendable {}
extension UNUserNotificationCenter: @unchecked @retroactive Sendable {}

@Observable
@MainActor
public final class PushNotificationsManager: NSObject {

    // MARK: - Constants

    public static let shared = PushNotificationsManager()

    // MARK: - Dependencies

    private let parser = PushPayloadParser()
    private var client: NetworkClient?

    // MARK: - State

    public private(set) var rawDeviceToken: Data?
    public private(set) var apnsDeviceToken = ""

    private var isConfigured = false
    private let eventContinuation: AsyncStream<PushEvent>.Continuation
    public let events: AsyncStream<PushEvent>

    // MARK: - Init

    private override init() {
        let (stream, continuation) = AsyncStream<PushEvent>.makeStream()
        self.events = stream
        self.eventContinuation = continuation
        super.init()
    }
}

// MARK: - Public API

public extension PushNotificationsManager {
    
    func configure(client: NetworkClient) {
        self.client = client
        guard !isConfigured else { return }
        isConfigured = true
        setUpRemoteNotifications()
    }

    func setDeviceToken(_ deviceToken: Data?) {
        rawDeviceToken = deviceToken
        apnsDeviceToken = deviceToken?.map { String(format: "%02.2hhx", $0) }.joined() ?? ""
    }

    func handleRemoteNotificationPayload(_ userInfo: [AnyHashable: Any]) {
        process(userInfo: userInfo)
    }

    /// Registers the current APNS token on the backend.
    ///
    /// This method is intentionally explicit instead of being called automatically from
    /// `setDeviceToken(_:)`: backend registration usually requires an authenticated user,
    /// while APNS can return a token before the app finishes restoring auth state.
    func registerDeviceTokenOnServer() async throws {
        guard !apnsDeviceToken.isEmpty else {
            throw NetworkError.noData
        }

        guard let client else {
            throw NetworkError.noData
        }

        let request = PushDeviceTokenRequest(token: apnsDeviceToken)
        let _: Empty = try await client.request(PushAPI.registerDeviceToken(request))
    }
}

// MARK: - Remote Notification Setup

private extension PushNotificationsManager {
    func setUpRemoteNotifications() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
        UIApplication.shared.registerForRemoteNotifications()
    }
}

// MARK: - Payload Processing

private extension PushNotificationsManager {
    
    func process(userInfo: [AnyHashable: Any]) {
        if let event = parser.event(from: userInfo) {
            eventContinuation.yield(event)
        }
    }
}

// MARK: - User Notifications

extension PushNotificationsManager: UNUserNotificationCenterDelegate {
    
    public func userNotificationCenter(
        _: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        return [.banner, .list, .badge, .sound]
    }

    public func userNotificationCenter(
        _: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        process(userInfo: response.notification.request.content.userInfo)
    }
}
