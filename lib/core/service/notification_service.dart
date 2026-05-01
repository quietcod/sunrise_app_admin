import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutex_admin/core/helper/shared_preference_helper.dart';
import 'package:flutex_admin/core/helper/notification_helper.dart';

/// Production-ready Notification Service for iOS and Android
///
/// Handles:
/// - FCM token management
/// - APNs token (iOS)
/// - Permission requests
/// - Foreground, background, and terminated notifications
/// - Local notification display
/// - Token refresh and persistence
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Android notification channel
  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
    'sunrise_admin_channel',
    'Sunrise Admin Notifications',
    description: 'Notifications for Sunrise Admin app',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
    showBadge: true,
  );

  // iOS notification details
  static const DarwinNotificationDetails _iOSDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
    // Optional: specify sound file
    // sound: 'notification_sound.aiff',
  );

  /// Initialize the notification service
  /// Call this in main() before runApp()
  Future<void> initialize() async {
    // Request permissions (iOS will show prompt, Android 13+ also needs this)
    await _requestPermissions();

    // Initialize local notifications plugin
    await _initializeLocalNotifications();

    // Set foreground notification presentation options (iOS)
    await _setForegroundOptions();

    // Get and store FCM token
    await _handleFcmToken();

    // Set up token refresh listener
    _setupTokenRefreshListener();

    // Set up message handlers
    _setupMessageHandlers();

    // Print authorization status for debugging
    await _printAuthorizationStatus();
  }

  /// Request notification permissions
  /// iOS: Shows system permission dialog
  /// Android 13+: Shows system permission dialog
  Future<NotificationSettings> _requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false, // Set to true for provisional (quiet) notifications
      sound: true,
    );

    if (kDebugMode) {
      print('🔔 Notification permission status: ${settings.authorizationStatus}');
    }

    return settings;
  }

  /// Request provisional permission (iOS only)
  /// Provisional notifications appear quietly in the Notification Center
  /// without interrupting the user
  Future<NotificationSettings> requestProvisionalPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: true, // Provisional authorization
      sound: true,
    );

    if (kDebugMode) {
      print('🔔 Provisional permission status: ${settings.authorizationStatus}');
    }

    return settings;
  }

  /// Initialize local notifications plugin
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iOSSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iOSSettings,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
      onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationTapped,
    );

    // Create Android notification channel
    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_androidChannel);
    }

    // Request iOS notification permissions through local notifications plugin
    if (Platform.isIOS) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
  }

  /// Set iOS foreground notification presentation options
  Future<void> _setForegroundOptions() async {
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// Handle FCM token retrieval and storage
  Future<void> _handleFcmToken() async {
    try {
      // For iOS, get APNs token first
      if (Platform.isIOS) {
        final apnsToken = await _messaging.getAPNSToken();
        if (kDebugMode) {
          print('📱 APNs Token: $apnsToken');
        }

        // If APNs token is null, wait a bit and retry
        if (apnsToken == null) {
          await Future.delayed(const Duration(seconds: 2));
          final retryApnsToken = await _messaging.getAPNSToken();
          if (kDebugMode) {
            print('📱 APNs Token (retry): $retryApnsToken');
          }
        }
      }

      // Get FCM token
      final fcmToken = await _messaging.getToken();
      if (fcmToken != null) {
        await _saveFcmToken(fcmToken);
        if (kDebugMode) {
          print('🔥 FCM Token: $fcmToken');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting FCM token: $e');
      }
    }
  }

  /// Save FCM token to SharedPreferences
  Future<void> _saveFcmToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(SharedPreferenceHelper.fcmTokenKey, token);
  }

  /// Get stored FCM token
  Future<String?> getFcmToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(SharedPreferenceHelper.fcmTokenKey);
  }

  /// Get current FCM token from Firebase
  Future<String?> getCurrentFcmToken() async {
    return await _messaging.getToken();
  }

  /// Get APNs token (iOS only)
  Future<String?> getApnsToken() async {
    if (Platform.isIOS) {
      return await _messaging.getAPNSToken();
    }
    return null;
  }

  /// Set up token refresh listener
  void _setupTokenRefreshListener() {
    _messaging.onTokenRefresh.listen((newToken) async {
      if (kDebugMode) {
        print('🔄 FCM Token refreshed: $newToken');
      }
      await _saveFcmToken(newToken);

      // Sync new token to server
      await NotificationHelper.syncFcmTokenToServer();
    });
  }

  /// Set up message handlers for foreground, background, and terminated states
  void _setupMessageHandlers() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Background/terminated message tap (handled in NotificationHelper.setupInteractedMessage)
    // FirebaseMessaging.onMessageOpenedApp is handled there
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;

    if (kDebugMode) {
      print('📬 Foreground message received:');
      print('   Title: ${notification?.title}');
      print('   Body: ${notification?.body}');
      print('   Data: ${message.data}');
    }

    // On Android, we need to show local notification manually
    // On iOS, the notification is shown automatically via setForegroundNotificationPresentationOptions
    if (notification != null) {
      if (Platform.isAndroid) {
        _showLocalNotification(
          id: notification.hashCode,
          title: notification.title ?? '',
          body: notification.body ?? '',
          payload: jsonEncode(message.data),
        );
      }
      // iOS handles foreground display via setForegroundNotificationPresentationOptions
    }
  }

  /// Show a local notification
  Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    final NotificationDetails details = NotificationDetails(
      android: AndroidNotificationDetails(
        _androidChannel.id,
        _androidChannel.name,
        channelDescription: _androidChannel.description,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        enableVibration: true,
      ),
      iOS: _iOSDetails,
    );

    await _localNotifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
  }

  /// Show a custom local notification (public method for manual notifications)
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    await _showLocalNotification(
      id: id,
      title: title,
      body: body,
      payload: data != null ? jsonEncode(data) : null,
    );
  }

  /// Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id: id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// Print authorization status for debugging
  Future<void> _printAuthorizationStatus() async {
    final settings = await _messaging.getNotificationSettings();

    if (kDebugMode) {
      print('═══════════════════════════════════════════');
      print('📋 NOTIFICATION AUTHORIZATION STATUS');
      print('═══════════════════════════════════════════');
      print('   Authorization: ${settings.authorizationStatus}');
      print('   Alert: ${settings.alert}');
      print('   Badge: ${settings.badge}');
      print('   Sound: ${settings.sound}');
      print('   Announcement: ${settings.announcement}');
      print('   Car Play: ${settings.carPlay}');
      print('   Critical Alert: ${settings.criticalAlert}');
      print('   Notification Center: ${settings.notificationCenter}');
      print('   Lock Screen: ${settings.lockScreen}');
      print('   Show Previews: ${settings.showPreviews}');
      print('═══════════════════════════════════════════');
    }
  }

  /// Check if notifications are authorized
  Future<bool> isAuthorized() async {
    final settings = await _messaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    if (kDebugMode) {
      print('📌 Subscribed to topic: $topic');
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    if (kDebugMode) {
      print('📌 Unsubscribed from topic: $topic');
    }
  }

  /// Delete FCM token (use when user logs out)
  Future<void> deleteToken() async {
    await _messaging.deleteToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(SharedPreferenceHelper.fcmTokenKey);
    if (kDebugMode) {
      print('🗑️ FCM token deleted');
    }
  }

  /// Get the badge count (iOS only)
  /// Note: Badge count retrieval is managed by the notification payload
  Future<int> getBadgeCount() async {
    // Badge count is typically managed by the server in the notification payload
    return 0;
  }

  /// Set the badge count (iOS only)
  /// Note: On iOS, badge updates require notification payload or manual handling
  Future<void> setBadgeCount(int count) async {
    // Badge count is typically managed by the server in the notification payload
    // or through background app refresh
    if (kDebugMode) {
      print('📛 Badge count request: $count');
    }
  }
}

// ============================================================================
// STATIC CALLBACKS (must be top-level or static)
// ============================================================================


/// Called when user taps on a notification (foreground)
void _onNotificationTapped(NotificationResponse response) {
  if (kDebugMode) {
    print('👆 Notification tapped: ${response.payload}');
  }
  NotificationHelper.onLocalNotificationTapped(response.payload);
}

/// Called when user taps on a notification (background)
/// Must be a top-level function
@pragma('vm:entry-point')
void _onBackgroundNotificationTapped(NotificationResponse response) {
  if (kDebugMode) {
    print('👆 Background notification tapped: ${response.payload}');
  }
  NotificationHelper.onLocalNotificationTapped(response.payload);
}

// ============================================================================
// BACKGROUND MESSAGE HANDLER
// ============================================================================

/// Firebase Messaging background handler
/// MUST be a top-level function, NOT a class method
/// Called when app is in background or terminated
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase if not already initialized
  await Firebase.initializeApp();

  if (kDebugMode) {
    print('═══════════════════════════════════════════');
    print('📩 BACKGROUND MESSAGE RECEIVED');
    print('═══════════════════════════════════════════');
    print('   Message ID: ${message.messageId}');
    print('   Title: ${message.notification?.title}');
    print('   Body: ${message.notification?.body}');
    print('   Data: ${message.data}');
    print('   From: ${message.from}');
    print('   Sent Time: ${message.sentTime}');
    print('═══════════════════════════════════════════');
  }

  // You can process data here if needed
  // Note: You cannot show UI or update state from here
  // The notification will be shown automatically by the system
}

