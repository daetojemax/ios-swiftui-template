import Client
import SwiftUI
import UIKit

@MainActor
public final class AppDelegate: NSObject, UIApplicationDelegate {
    
    public func application(
        _: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        if let remoteNotification = launchOptions?[.remoteNotification] as? [AnyHashable: Any] {
            PushNotificationsManager.shared.handleRemoteNotificationPayload(remoteNotification)
        }
        return true
    }

    public func application(
        _: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        PushNotificationsManager.shared.setDeviceToken(deviceToken)
    }

    public func application(
        _: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        PushNotificationsManager.shared.handleRemoteNotificationPayload(userInfo)
        completionHandler(.noData)
    }
}
