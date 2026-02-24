import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutex_admin/core/helper/shared_preference_helper.dart';
import 'package:flutex_admin/core/utils/url_container.dart';
import 'package:flutex_admin/core/route/route.dart';

class NotificationHelper {
  /// Stores pending notification data when app is launched from terminated state.
  /// Processed after the splash screen completes and user reaches dashboard.
  static Map<String, dynamic>? _pendingNotificationData;

  // ---------------------------------------------------------------------------
  // FCM TOKEN SYNC
  // ---------------------------------------------------------------------------

  /// Reads the locally stored FCM token and access token, then POSTs the token
  /// to the backend `auth/fcm-token` endpoint.
  ///
  /// Call this:
  ///   - After a successful login (in LoginController)
  ///   - On app startup when the user is already remembered (in SplashController)
  ///   - Whenever Firebase rotates the FCM token (onTokenRefresh in main.dart)
  static Future<void> syncFcmTokenToServer() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final fcmToken = prefs.getString(SharedPreferenceHelper.fcmTokenKey);
      final accessToken =
          prefs.getString(SharedPreferenceHelper.accessTokenKey);

      if (fcmToken == null || fcmToken.isEmpty) return;
      if (accessToken == null || accessToken.isEmpty) return;

      final url =
          Uri.parse('${UrlContainer.baseUrl}${UrlContainer.fcmTokenUrl}');
      final response = await http.post(
        url,
        body: {'fcm_token': fcmToken},
        headers: {
          'Accept': 'application/json',
          'X-Authorization': accessToken,
        },
      );
    } catch (_) {}
  }

  /// Call this in main() BEFORE runApp — only sets up listeners,
  /// does NOT navigate immediately for cold-start.
  static Future<void> setupInteractedMessage() async {
    // ---- App was terminated and opened via notification tap ----
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      // Don't navigate now — app isn't ready yet.
      // Store the data and process it after splash/login flow completes.
      _pendingNotificationData = initialMessage.data;
    }

    // ---- App was in background and opened via notification tap ----
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  /// Call this from SplashController AFTER the user has been routed
  /// to the dashboard. Processes any pending notification from cold-start.
  static void processPendingNotification() {
    if (_pendingNotificationData != null) {
      final data = _pendingNotificationData!;
      _pendingNotificationData = null; // Clear so it doesn't fire again

      // Small delay to let the dashboard finish building
      Future.delayed(const Duration(milliseconds: 500), () {
        _navigateFromData(data);
      });
    }
  }

  /// Called when a local notification is tapped (foreground notifications).
  /// The payload is a JSON string with {type, id}.
  static void onLocalNotificationTapped(String? payload) {
    if (payload == null || payload.isEmpty) return;

    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      _navigateFromData(data);
    } catch (_) {}
  }

  /// Navigate based on notification data payload (from FCM RemoteMessage).
  static void _handleMessage(RemoteMessage message) {
    _navigateFromData(message.data);
  }

  /// Navigate based on data map.
  /// Data should contain: { "type": "ticket", "id": "123" }
  static void _navigateFromData(Map<String, dynamic> data) {
    final String? type = data['type'];
    final String? id = data['id'];

    if (type == null) {
      return;
    }

    switch (type) {
      case 'ticket':
        if (id != null) {
          Get.toNamed(RouteHelper.ticketDetailsScreen, arguments: id);
        } else {
          Get.toNamed(RouteHelper.ticketScreen);
        }
        break;
      case 'invoice':
        if (id != null) {
          Get.toNamed(RouteHelper.invoiceDetailsScreen, arguments: id);
        } else {
          Get.toNamed(RouteHelper.invoiceScreen);
        }
        break;
      case 'task':
        if (id != null) {
          Get.toNamed(RouteHelper.taskDetailsScreen, arguments: id);
        } else {
          Get.toNamed(RouteHelper.taskScreen);
        }
        break;
      case 'project':
        if (id != null) {
          Get.toNamed(RouteHelper.projectDetailsScreen, arguments: id);
        } else {
          Get.toNamed(RouteHelper.projectScreen);
        }
        break;
      case 'lead':
        if (id != null) {
          Get.toNamed(RouteHelper.leadDetailsScreen, arguments: id);
        } else {
          Get.toNamed(RouteHelper.leadScreen);
        }
        break;
      case 'estimate':
        if (id != null) {
          Get.toNamed(RouteHelper.estimateDetailsScreen, arguments: id);
        } else {
          Get.toNamed(RouteHelper.estimateScreen);
        }
        break;
      case 'proposal':
        if (id != null) {
          Get.toNamed(RouteHelper.proposalDetailsScreen, arguments: id);
        } else {
          Get.toNamed(RouteHelper.proposalScreen);
        }
        break;
      case 'contract':
        if (id != null) {
          Get.toNamed(RouteHelper.contractDetailsScreen, arguments: id);
        } else {
          Get.toNamed(RouteHelper.contractScreen);
        }
        break;
      case 'customer':
        if (id != null) {
          Get.toNamed(RouteHelper.customerDetailsScreen, arguments: id);
        } else {
          Get.toNamed(RouteHelper.customerScreen);
        }
        break;
      case 'payment':
        if (id != null) {
          Get.toNamed(RouteHelper.paymentDetailsScreen, arguments: id);
        } else {
          Get.toNamed(RouteHelper.paymentScreen);
        }
        break;
      default:
        break;
    }
  }
}
