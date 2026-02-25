import Flutter
import UIKit
import FirebaseCore
import FirebaseMessaging
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // Initialize Firebase FIRST before anything else
    FirebaseApp.configure()

    // Register Flutter plugins
    GeneratedPluginRegistrant.register(with: self)

    // Set up notification delegates
    UNUserNotificationCenter.current().delegate = self
    Messaging.messaging().delegate = self

    // Register for remote notifications
    application.registerForRemoteNotifications()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // MARK: - APNs Token Handling

  /// Called when APNs successfully registers and provides a device token
  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    // Pass the APNs token to Firebase Messaging
    Messaging.messaging().apnsToken = deviceToken

    // Debug: Print APNs token
    let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
    print("📱 APNs Device Token: \(tokenString)")

    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  /// Called when APNs registration fails
  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    print("❌ Failed to register for remote notifications: \(error.localizedDescription)")
    super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
  }

  // MARK: - Handle Remote Notification (Background/Terminated)

  override func application(
    _ application: UIApplication,
    didReceiveRemoteNotification userInfo: [AnyHashable: Any],
    fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
  ) {
    // Let Firebase handle the message
    Messaging.messaging().appDidReceiveMessage(userInfo)

    print("📩 Received remote notification: \(userInfo)")

    // Call completion handler
    completionHandler(.newData)
  }
}

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate {

  /// Called when notification is delivered while app is in foreground
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    let userInfo = notification.request.content.userInfo

    // Let Firebase handle the message
    Messaging.messaging().appDidReceiveMessage(userInfo)

    print("🔔 Foreground notification received: \(userInfo)")

    // Show the notification banner, sound, and badge even when app is in foreground
    if #available(iOS 14.0, *) {
      completionHandler([[.banner, .sound, .badge, .list]])
    } else {
      completionHandler([[.alert, .sound, .badge]])
    }
  }

  /// Called when user taps on a notification
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    let userInfo = response.notification.request.content.userInfo

    // Let Firebase handle the message
    Messaging.messaging().appDidReceiveMessage(userInfo)

    print("👆 User tapped notification: \(userInfo)")

    // The Flutter firebase_messaging plugin will handle navigation
    completionHandler()
  }
}

// MARK: - MessagingDelegate

extension AppDelegate: MessagingDelegate {

  /// Called when FCM token is generated or refreshed
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    print("🔥 FCM Token: \(fcmToken ?? "nil")")

    // Post notification so Flutter side can be notified if needed
    let dataDict: [String: String] = ["token": fcmToken ?? ""]
    NotificationCenter.default.post(
      name: Notification.Name("FCMToken"),
      object: nil,
      userInfo: dataDict
    )
  }
}
