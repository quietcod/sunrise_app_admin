import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/core/utils/themes.dart';
import 'package:flutex_admin/common/controllers/localization_controller.dart';
import 'package:flutex_admin/common/controllers/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutex_admin/core/helper/notification_helper.dart';
import 'package:flutex_admin/core/helper/shared_preference_helper.dart';
import 'package:flutex_admin/firebase_options.dart';
import 'core/service/di_services.dart' as services;

/// Must be a top-level function — called when app is in the background/terminated
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase in background isolate with platform-specific options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (kDebugMode) {
    print('═══════════════════════════════════════════');
    print('📩 BACKGROUND MESSAGE RECEIVED');
    print('═══════════════════════════════════════════');
    print('   Message ID: ${message.messageId}');
    print('   Title: ${message.notification?.title}');
    print('   Body: ${message.notification?.body}');
    print('   Data: ${message.data}');
    print('═══════════════════════════════════════════');
  }
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel _channel = AndroidNotificationChannel(
  'sunrise_admin_channel',
  'Sunrise Admin Notifications',
  description: 'Notifications for Sunrise Admin app',
  importance: Importance.high,
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase FIRST with platform-specific options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Register background message handler (must be done early)
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // ---- Android: Create notification channel ----
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(_channel);

  // ---- iOS: Request notification permissions ----
  if (Platform.isIOS) {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  // ---- Initialize local notifications (Android icon + iOS) ----
  const InitializationSettings initSettings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    ),
  );

  await flutterLocalNotificationsPlugin.initialize(
    settings: initSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      // User tapped on a foreground local notification
      NotificationHelper.onLocalNotificationTapped(response.payload);
    },
  );

  // ---- Request notification permission (Android 13+ and iOS) ----
  final NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  // Print authorization status for debugging
  if (kDebugMode) {
    print('═══════════════════════════════════════════');
    print('📋 NOTIFICATION PERMISSION STATUS');
    print('═══════════════════════════════════════════');
    print('   Authorization: ${settings.authorizationStatus}');
    print('   Alert: ${settings.alert}');
    print('   Badge: ${settings.badge}');
    print('   Sound: ${settings.sound}');
    print('═══════════════════════════════════════════');
  }

  // ---- iOS: show foreground notifications ----
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  // ---- Listen to foreground messages (both Android & iOS) ----
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final notification = message.notification;

    if (kDebugMode) {
      print('📬 Foreground message received:');
      print('   Title: ${notification?.title}');
      print('   Body: ${notification?.body}');
      print('   Data: ${message.data}');
    }

    if (notification != null && Platform.isAndroid) {
      // Encode FCM data as JSON string so the tap handler can parse it
      final String payload = jsonEncode(message.data);

      // On Android, show a local notification manually since FCM
      // does NOT auto-display when the app is in the foreground.
      flutterLocalNotificationsPlugin.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        payload: payload,
      );
    }
    // iOS shows the notification automatically via setForegroundNotificationPresentationOptions
  });

  // ---- iOS: Get APNs token ----
  if (Platform.isIOS) {
    final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
    if (kDebugMode) {
      print('📱 APNs Token: $apnsToken');
    }

    // If APNs token is null, it might not be ready yet
    // Firebase will handle this automatically when it becomes available
    if (apnsToken == null) {
      // Wait a moment and try again
      await Future.delayed(const Duration(seconds: 2));
      final retryApnsToken = await FirebaseMessaging.instance.getAPNSToken();
      if (kDebugMode) {
        print('📱 APNs Token (retry): $retryApnsToken');
      }
    }
  }

  // ---- Get FCM token and save locally ----
  final token = await FirebaseMessaging.instance.getToken();
  if (kDebugMode) {
    print('🔥 FCM Token: $token');
  }

  final sharedPreferences = await SharedPreferences.getInstance();
  if (token != null) {
    await sharedPreferences.setString(
        SharedPreferenceHelper.fcmTokenKey, token);
  }

  // ---- Listen for token refresh ----
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    if (kDebugMode) {
      print('🔄 FCM Token refreshed: $newToken');
    }
    await sharedPreferences.setString(
        SharedPreferenceHelper.fcmTokenKey, newToken);
    // Re-register the new token with the backend so push notifications
    // are not lost after Firebase rotates the token.
    await NotificationHelper.syncFcmTokenToServer();
  });

  Get.lazyPut(() => sharedPreferences);
  Map<String, Map<String, String>> languages = await services.init();

  // Only bypass SSL in debug mode — production must validate certificates
  if (kDebugMode) {
    HttpOverrides.global = MyHttpOverrides();
  }

  // ---- Setup notification tap handlers ----
  NotificationHelper.setupInteractedMessage();

  runApp(MyApp(languages: languages));
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatelessWidget {
  final Map<String, Map<String, String>> languages;
  const MyApp({super.key, required this.languages});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(builder: (theme) {
      return GetBuilder<LocalizationController>(builder: (localizeController) {
        return GetMaterialApp(
          title: LocalStrings.appName.tr,
          debugShowCheckedModeBanner: false,
          defaultTransition: Transition.noTransition,
          transitionDuration: const Duration(milliseconds: 200),
          initialRoute: RouteHelper.splashScreen,
          navigatorKey: Get.key,
          theme: theme.darkTheme ? dark : light,
          getPages: RouteHelper().routes,
          locale: localizeController.locale,
          translations: Messages(languages: languages),
          fallbackLocale: Locale(localizeController.locale.languageCode,
              localizeController.locale.countryCode),
        );
      });
    });
  }
}
