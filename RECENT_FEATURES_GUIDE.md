# Recent Features Guide

This document provides a comprehensive overview of the recent features added to both the **Mobile App** and the **Web Backend (cPanel / Perfex CRM)**. It is intended for developers involved in testing and deployment.

---

## 1. Firebase Cloud Messaging (FCM) Push Notifications

**What we added:**
- **App:** The mobile application now receives real-time FCM push notifications whenever a new support ticket is assigned to a staff member.
- **Web:** The backend is now capable of storing device FCM tokens and triggering push notifications automatically through the Firebase API when ticket assignments occur.

**Why we added them:**
- To significantly improve staff responsiveness by alerting them immediately on their mobile devices, even when the application is backgrounded or closed. 

**How they are added:**
- The Flutter app requests notification permissions, obtains an FCM device token upon login, and sends it to the newly created backend API endpoint `auth/fcm-token`. 
- The backend stores this token in the database. When the Perfex CRM hook `after_ticket_assigned` fires, it retrieves the assigned staff member's token and executes the `send_push_notification` helper method to send the payload to the device.

**Where the code/files are located:**
- **Web (cPanel):**
  - FCM Token API Endpoint: `perfex_crm/modules/flutex_admin_api/controllers/FcmToken.php`
  - Notification Helper: `perfex_crm/modules/flutex_admin_api/helpers/fcm_helper.php`
- **App:**
  - Firebase Messaging & Token Handling logic within the Flutter App (`lib/` directory).

---

## 2. Secure OTP Ticket Closure Flow

**What we added:**
- **App:** A new full-screen One-Time Password (OTP) verification form matching the web CRM's design. This screen must be completed to successfully close a ticket.
- **Web:** Backend logic to securely generate, email, and verify OTPs prior to finalizing a ticket status change. 

**Why we added them:**
- To enforce a stricter layer of security and auditability. It ensures that critical actions, such as closing support tickets, are only performed by authorized staff who can explicitly verify their identity, thereby preventing accidental or unauthorized closures.

**How they are added:**
- **App:** Intercepts the "Change Status to Closed" action in the `Ticket Details` screen, pauses the API request, and calls the `/send-otp` backend API. It navigates to an `OTP Verification` screen. Upon successful OTP entry, it calls `/verify-otp` and then finalizes the status change.
- **Web:** Exposes two new API endpoints (`/send-otp` and `/verify-otp`). It also integrates the OTP flow within the Perfex CRM support views. An additional staff permission setting (`ticket_close_without_otp`) was added to bypass the OTP flow for higher-level administrators.

**Where the code/files are located:**
- **Web (cPanel):**
  - CRM Ticket Controllers: `perfex_crm/application/controllers/admin/Tickets.php`
  - CRM Ticket Views: `perfex_crm/application/views/admin/tables/tickets.php`
  - API Controllers (Flutex Admin API routing).
- **App:**
  - OTP Screen UI: `lib/features/ticket/widget/otp_verification_screen.dart`
  - Ticket Interception Logic: `lib/screens/ticket/ticket_details_screen.dart`

---
