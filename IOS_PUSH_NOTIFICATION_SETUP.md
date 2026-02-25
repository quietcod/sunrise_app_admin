# iOS Push Notification Setup Guide for Sunrise Admin

This document provides a complete step-by-step guide to configure iOS push notifications for the Sunrise Admin Flutter app.

---

## Table of Contents

1. [Firebase Console Setup](#1-firebase-console-setup)
2. [Apple Developer Setup](#2-apple-developer-setup)
3. [Xcode Configuration](#3-xcode-configuration)
4. [Flutter Code Implementation](#4-flutter-code-implementation)
5. [Testing Push Notifications](#5-testing-push-notifications)
6. [Production Checklist](#6-production-checklist)
7. [Troubleshooting](#7-troubleshooting)

---

## 1. Firebase Console Setup

### Step 1.1: Add iOS App to Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project **"Sunrise Admin"**
3. Click the **gear icon** → **Project Settings**
4. Under **"Your apps"**, click **"Add app"** → Select **iOS**
5. Enter the following details:
   - **iOS bundle ID**: `com.sunrise.admin`
   - **App nickname**: `Sunrise Admin iOS`
   - **App Store ID**: (Optional, add later)
6. Click **"Register app"**

### Step 1.2: Download GoogleService-Info.plist

1. After registering, download **GoogleService-Info.plist**
2. **IMPORTANT**: Place this file in the correct location:
   ```
   ios/Runner/GoogleService-Info.plist
   ```
3. In Xcode, right-click on the **Runner** folder → **Add Files to "Runner"**
4. Select `GoogleService-Info.plist`
5. Ensure **"Copy items if needed"** is checked
6. Select **Target: Runner**
7. Click **Add**

### Step 1.3: Verify Firebase Configuration

Your `GoogleService-Info.plist` should contain:
```xml
<key>BUNDLE_ID</key>
<string>com.sunrise.admin</string>
<key>PROJECT_ID</key>
<string>your-firebase-project-id</string>
```

---

## 2. Apple Developer Setup

### Step 2.1: Create App ID (if not exists)

1. Go to [Apple Developer Portal](https://developer.apple.com/account)
2. Navigate to **Certificates, Identifiers & Profiles**
3. Click **Identifiers** → **+** (Add new)
4. Select **App IDs** → Continue
5. Select **App** → Continue
6. Configure:
   - **Description**: Sunrise Admin
   - **Bundle ID**: Explicit → `com.sunrise.admin`
7. Enable **Push Notifications** capability
8. Click **Continue** → **Register**

### Step 2.2: Enable Push Notifications Capability

If App ID already exists:
1. Go to **Identifiers** → Select your App ID (`com.sunrise.admin`)
2. Scroll to **Capabilities**
3. Enable **Push Notifications**
4. Click **Save**

### Step 2.3: Create APNs Authentication Key (.p8)

This is the **recommended method** (easier than certificates):

1. Go to **Keys** in Apple Developer Portal
2. Click **+** (Create a new key)
3. Enter **Key Name**: `Sunrise Admin APNs Key`
4. Enable **Apple Push Notifications service (APNs)**
5. Click **Continue** → **Register**
6. **IMPORTANT**: Download the `.p8` file immediately
   - You can only download it **ONCE**!
   - File will be named like: `AuthKey_XXXXXXXXXX.p8`
7. Note your **Key ID** (displayed on the page)
8. Note your **Team ID** (found in Membership section)

### Step 2.4: Upload APNs Key to Firebase

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project → **Project Settings** (gear icon)
3. Go to **Cloud Messaging** tab
4. Scroll to **Apple app configuration**
5. Under **APNs Authentication Key**, click **Upload**
6. Upload your `.p8` file
7. Enter:
   - **Key ID**: The 10-character Key ID from Apple
   - **Team ID**: Your Apple Developer Team ID (e.g., `ABC123XYZ`)
8. Click **Upload**

---

## 3. Xcode Configuration

### Step 3.1: Open Xcode Project

```bash
cd /Users/apple/StudioProjects/sunrise_app_admin/ios
open Runner.xcworkspace
```

**IMPORTANT**: Always open `.xcworkspace`, not `.xcodeproj`!

### Step 3.2: Set Bundle Identifier

1. Select **Runner** in the project navigator
2. Select **Runner** target
3. Go to **Signing & Capabilities** tab
4. Set **Bundle Identifier**: `com.sunrise.admin`
5. Select your **Team** (Apple Developer account)

### Step 3.3: Add Push Notifications Capability

1. In **Signing & Capabilities** tab
2. Click **+ Capability**
3. Search and add **Push Notifications**

### Step 3.4: Add Background Modes Capability

1. Click **+ Capability**
2. Search and add **Background Modes**
3. Enable:
   - ✅ **Background fetch**
   - ✅ **Remote notifications**

### Step 3.5: Verify Entitlements File

The file `ios/Runner/Runner.entitlements` has been created with:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>aps-environment</key>
    <string>development</string>
</dict>
</plist>
```

**For Production**: Change `development` to `production` when releasing to App Store.

### Step 3.6: Link Entitlements in Build Settings

1. Select **Runner** target
2. Go to **Build Settings** tab
3. Search for **"Code Signing Entitlements"**
4. Set for all configurations:
   ```
   Runner/Runner.entitlements
   ```

---

## 4. Flutter Code Implementation

### 4.1: pubspec.yaml Dependencies

Your `pubspec.yaml` already has the required dependencies:

```yaml
dependencies:
  firebase_core: ^4.4.0
  firebase_messaging: ^16.1.1
  flutter_local_notifications: ^20.1.0
```

Run after any changes:
```bash
flutter pub get
cd ios && pod install && cd ..
```

### 4.2: Files Updated/Created

| File | Status | Description |
|------|--------|-------------|
| `lib/main.dart` | ✅ Updated | Background handler, permission requests, token handling |
| `lib/core/service/notification_service.dart` | ✅ Created | Comprehensive notification service |
| `lib/core/helper/notification_helper.dart` | ✅ Existing | Navigation handling on notification tap |
| `ios/Runner/AppDelegate.swift` | ✅ Updated | Firebase & APNs configuration |
| `ios/Runner/Info.plist` | ✅ Updated | Background modes, Firebase proxy |
| `ios/Runner/Runner.entitlements` | ✅ Created | Push notification entitlements |
| `ios/Podfile` | ✅ Updated | iOS 15.0 minimum deployment target |

### 4.3: Key Implementation Details

#### Background Handler (main.dart)
```dart
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Handle background message
}
```

#### Permission Request
```dart
final NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
  alert: true,
  badge: true,
  sound: true,
);
```

#### Token Retrieval
```dart
// APNs Token (iOS only)
final apnsToken = await FirebaseMessaging.instance.getAPNSToken();

// FCM Token (cross-platform)
final fcmToken = await FirebaseMessaging.instance.getToken();
```

#### Foreground Notification Display
```dart
// iOS: Automatically shown via setForegroundNotificationPresentationOptions
await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
  alert: true,
  badge: true,
  sound: true,
);

// Android: Must show manually via flutter_local_notifications
```

### 4.4: Best Practice: Store Token in Firestore

Example implementation for syncing FCM token to backend:

```dart
// In your auth/login controller
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> saveFcmTokenToFirestore() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final fcmToken = await FirebaseMessaging.instance.getToken();
  if (fcmToken == null) return;

  await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .set({
        'fcmTokens': FieldValue.arrayUnion([fcmToken]),
        'lastTokenUpdate': FieldValue.serverTimestamp(),
        'platform': Platform.isIOS ? 'ios' : 'android',
      }, SetOptions(merge: true));
}

// Listen for token refresh
FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
  await saveFcmTokenToFirestore();
});
```

---

## 5. Testing Push Notifications

### 5.1: Debug Mode Testing

1. Build and run on a **physical iOS device** (simulator doesn't support push):
   ```bash
   flutter run -d <device_id>
   ```

2. Check debug console for tokens:
   ```
   📱 APNs Token: <hex_string>
   🔥 FCM Token: <long_string>
   ```

### 5.2: Send Test Notification from Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Navigate to **Engage** → **Messaging**
3. Click **Create your first campaign** → **Firebase Notification messages**
4. Enter:
   - **Notification title**: Test Notification
   - **Notification text**: Hello from Firebase!
5. Click **Send test message**
6. Enter your FCM token
7. Click **Test**

### 5.3: Send Test via cURL

```bash
curl -X POST \
  https://fcm.googleapis.com/v1/projects/YOUR_PROJECT_ID/messages:send \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  -d '{
    "message": {
      "token": "YOUR_FCM_TOKEN",
      "notification": {
        "title": "Test Title",
        "body": "Test Body"
      },
      "data": {
        "type": "ticket",
        "id": "123"
      }
    }
  }'
```

### 5.4: Test Different App States

| State | How to Test | Expected Behavior |
|-------|-------------|-------------------|
| **Foreground** | App open | Banner appears, `onMessage` called |
| **Background** | App minimized | System notification, tap triggers `onMessageOpenedApp` |
| **Terminated** | App killed | System notification, tap triggers `getInitialMessage` |

---

## 6. Production Checklist

### 6.1: Pre-Release Checklist

- [ ] Bundle ID matches Firebase iOS app configuration
- [ ] GoogleService-Info.plist is in `ios/Runner/`
- [ ] APNs Authentication Key uploaded to Firebase
- [ ] Team ID and Key ID are correct in Firebase
- [ ] Push Notifications capability added in Xcode
- [ ] Background Modes enabled (remote notifications, background fetch)
- [ ] Runner.entitlements has `aps-environment` set to `production`
- [ ] App built with Release configuration

### 6.2: Update Entitlements for Production

Before submitting to App Store, update `Runner.entitlements`:

```xml
<key>aps-environment</key>
<string>production</string>
```

### 6.3: APNs Environment

| Environment | When Used | Entitlements Value |
|-------------|-----------|-------------------|
| **Sandbox** | Debug builds, TestFlight | `development` |
| **Production** | App Store release | `production` |

**Note**: TestFlight uses **sandbox** APNs environment, same as debug builds.

### 6.4: TestFlight Testing

1. Build with:
   ```bash
   flutter build ipa
   ```
2. Upload to App Store Connect
3. Distribute to TestFlight testers
4. Push notifications work in TestFlight with **sandbox** environment

---

## 7. Troubleshooting

### Issue: APNs Token is null

**Causes**:
- Running on iOS Simulator (not supported)
- Push Notifications capability not added
- Provisioning profile doesn't have push enabled
- Device not connected to internet

**Solutions**:
1. Use a physical iOS device
2. Verify Push Notifications capability in Xcode
3. Regenerate provisioning profiles in Xcode (Signing & Capabilities → Automatically manage signing)

### Issue: FCM Token is null

**Causes**:
- APNs token not available yet
- Firebase not initialized properly
- GoogleService-Info.plist missing or incorrect

**Solutions**:
1. Wait for APNs token first (with retry logic)
2. Verify Firebase.initializeApp() is called
3. Check GoogleService-Info.plist bundle ID matches

### Issue: Notification not received

**Causes**:
- Incorrect FCM token
- APNs key not uploaded to Firebase
- Team ID or Key ID mismatch
- Device notifications disabled

**Solutions**:
1. Get fresh FCM token and test again
2. Re-upload APNs key to Firebase Console
3. Verify Team ID in Firebase matches Apple Developer account
4. Check device Settings → Notifications → Your App

### Issue: Notification received but no sound/banner

**Causes**:
- Foreground presentation options not set
- Device in Do Not Disturb mode
- Notification importance/priority too low

**Solutions**:
1. Verify `setForegroundNotificationPresentationOptions` is called
2. Check device notification settings
3. Ensure notification channel importance is HIGH

### Issue: Background handler not called

**Causes**:
- Handler not registered early enough
- Handler not a top-level function
- Missing `@pragma('vm:entry-point')`

**Solutions**:
1. Register handler immediately after Firebase.initializeApp()
2. Ensure handler is outside any class
3. Add `@pragma('vm:entry-point')` annotation

### Debug Logs

To see detailed Firebase Messaging logs:

```bash
# Terminal 1: Run app
flutter run

# Terminal 2: View iOS logs
idevicesyslog | grep -i "firebase\|notification\|apns"
```

---

## Quick Reference Commands

```bash
# Clean and rebuild
flutter clean
flutter pub get
cd ios && rm -rf Pods Podfile.lock && pod install && cd ..
flutter build ios

# Run on device
flutter run -d <device_id> --verbose

# Build for release
flutter build ipa --release

# Open Xcode
cd ios && open Runner.xcworkspace
```

---

## Support

If you encounter issues not covered here:

1. Check [Firebase Flutter Documentation](https://firebase.google.com/docs/flutter/setup)
2. Review [firebase_messaging Package](https://pub.dev/packages/firebase_messaging)
3. See [Apple Push Notification Documentation](https://developer.apple.com/documentation/usernotifications)

---

*Last Updated: February 2026*

