# Firebase push notifications

The four Flutter applications are registered in Firebase project
`orient-a843b`, with separate Android and iOS app records. Each app contains
its own native Firebase configuration.

## Backend runtime

Firebase Cloud Messaging is off by default so local development remains
usable without cloud credentials. Enable it in a deployed environment with:

```text
FIREBASE_ENABLED=true
FIREBASE_PROJECT_ID=orient-a843b
GOOGLE_APPLICATION_CREDENTIALS=/secure/path/firebase-service-account.json
```

Alternatively, set `FIREBASE_CREDENTIALS_PATH` to the same secure absolute
path. The Java configuration explicitly opens that file with
`GoogleCredentials.fromStream(...)`; when it is blank, it uses Application
Default Credentials, which reads `GOOGLE_APPLICATION_CREDENTIALS`.

`serviceAccountKey.json` is intentionally absent from Git. Download it only
for a server that cannot use workload identity: Firebase Console > Project
settings > Service accounts > Generate new private key. Store it outside the
repository (or under the ignored `.secrets/` directory) and rotate/revoke it
if it is ever exposed.

Prefer the hosting platform's workload identity/Application Default
Credentials over a downloaded JSON key. Never commit a service-account key.

The existing `POST /api/v1/notifications/device-token` endpoint now assigns a
Firebase Installation ID (FID) to the authenticated user without duplicates
(the legacy endpoint/column name is retained for compatibility). Every notification
emitted through the core notification service remains in the database and is
also sent through FCM when Firebase is enabled. Invalid registration tokens are
removed automatically.

## iOS delivery

The projects contain the Push Notifications entitlement and background remote
notification mode. Before TestFlight/device delivery, upload an Apple APNs
authentication key in Firebase Console > Project settings > Cloud Messaging.
That key, its Key ID, and Apple Team ID come from the Apple Developer account
and are not stored in this repository.
