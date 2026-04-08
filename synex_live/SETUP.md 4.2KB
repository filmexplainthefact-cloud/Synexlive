# ðŸš€ Synex Live â€” Setup Guide

## Prerequisites
- Flutter 3.x installed
- Firebase account
- Android Studio / VS Code

---

## Step 1 â€” Firebase Setup

1. Go to https://console.firebase.google.com
2. Create a new project: **synex-live**
3. Enable these services:
   - **Authentication** â†’ Email/Password + Google
   - **Firestore Database** â†’ Start in production mode
   - **Cloud Messaging** (FCM)
   - **Storage** (for profile photos)

---

## Step 2 â€” Add Firebase to Flutter

Install FlutterFire CLI:
```bash
dart pub global activate flutterfire_cli
```

Run configuration:
```bash
flutterfire configure
```
This auto-generates `lib/firebase_options.dart` with your credentials.

---

## Step 3 â€” Android Setup

1. Download `google-services.json` from Firebase Console
2. Place it at: `android/app/google-services.json`
3. In `android/app/build.gradle`, set your package name:
   ```
   applicationId "com.yourname.synex_live"
   ```

---

## Step 4 â€” Google Sign-In Setup

1. In Firebase Console â†’ Authentication â†’ Sign-in method â†’ Google â†’ Enable
2. Add your SHA-1 fingerprint:
```bash
cd android && ./gradlew signingReport
```
3. Copy SHA-1 â†’ Firebase Console â†’ Project Settings â†’ Your App â†’ Add fingerprint

---

## Step 5 â€” Firestore Rules

In Firebase Console â†’ Firestore â†’ Rules, paste contents of `firestore.rules`

---

## Step 6 â€” Install & Run

```bash
flutter pub get
flutter run
```

---

## Firestore Data Structure

```
users/
  {uid}: { name, email, photoUrl, bio, fcmToken, ... }

lives/
  {liveId}: { hostId, hostName, title, speakers[], blockedUsers[], mutedSpeakers[], isLive, viewerCount, startedAt }

live_chats/
  {liveId}/messages/
    {msgId}: { userId, userName, message, timestamp, isHost }

live_requests/
  {liveId}: {
    {userId}: { name, status: "pending|accepted|rejected", requestedAt }
  }

signaling/
  {liveId}/connections/
    {callerId_calleeId}: { offer, answer }
  {liveId}/ice_candidates/
    {uid}/{peerId}/{docId}: { candidate, sdpMid, sdpMLineIndex }
```

---

## WebRTC Notes

- Current impl: P2P mesh (good for â‰¤6 speakers)
- For production scale (100+ concurrent), use SFU servers:
  - **LiveKit** (open source, self-hosted or cloud)
  - **Daily.co** API
  - **Agora.io** SDK
- TURN servers needed for NAT traversal in production

---

## FCM Push Notifications

To send actual push notifications, deploy a Cloud Function:

```javascript
// functions/index.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendNotification = functions.firestore
  .document('notifications/{notifId}')
  .onCreate(async (snap) => {
    const data = snap.data();
    if (data.sent || !data.targetFcmToken) return;
    await admin.messaging().send({
      token: data.targetFcmToken,
      notification: { title: 'Synex Live', body: data.message },
      data: { liveId: data.liveId, type: data.type },
    });
    await snap.ref.update({ sent: true });
  });
```

---

## Folder Structure

```
lib/
â”œâ”€â”€ main.dart
â”œâ”€â”€ firebase_options.dart
â”œâ”€â”€ screens/
â”‚   â”œâ”€â”€ splash_screen.dart
â”‚   â”œâ”€â”€ home_screen.dart
â”‚   â”œâ”€â”€ live_screen.dart        â† Main live room
â”‚   â”œâ”€â”€ go_live_screen.dart     â† Host start live
â”‚   â”œâ”€â”€ profile_screen.dart
â”‚   â””â”€â”€ auth/
â”‚       â”œâ”€â”€ login_screen.dart
â”‚       â””â”€â”€ signup_screen.dart
â”œâ”€â”€ services/
â”‚   â”œâ”€â”€ auth_service.dart       â† Email + Google auth
â”‚   â”œâ”€â”€ live_service.dart       â† Firestore live ops
â”‚   â”œâ”€â”€ webrtc_service.dart     â† WebRTC P2P
â”‚   â”œâ”€â”€ notification_service.dart â† FCM
â”‚   â””â”€â”€ user_service.dart
â”œâ”€â”€ models/
â”‚   â”œâ”€â”€ user_model.dart
â”‚   â”œâ”€â”€ live_model.dart
â”‚   â”œâ”€â”€ chat_model.dart
â”‚   â””â”€â”€ live_request_model.dart
â”œâ”€â”€ widgets/
â”‚   â”œâ”€â”€ custom_button.dart
â”‚   â”œâ”€â”€ custom_text_field.dart
â”‚   â”œâ”€â”€ live_card.dart
â”‚   â”œâ”€â”€ speaker_tile.dart
â”‚   â”œâ”€â”€ chat_bubble.dart
â”‚   â”œâ”€â”€ request_tile.dart
â”‚   â”œâ”€â”€ user_avatar.dart
â”‚   â””â”€â”€ loading_shimmer.dart
â””â”€â”€ utils/
    â”œâ”€â”€ app_theme.dart
    â”œâ”€â”€ app_constants.dart
    â”œâ”€â”€ validators.dart
    â””â”€â”€ helpers.dart
```
