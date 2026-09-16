import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

typedef DeviceTokenRegistrar =
    Future<bool> Function(String token, String platform);

/// One push event, reduced to the fields the backend actually sends.
///
/// Deliberately free of any Firebase type so the apps (and their tests) can
/// react to a push without depending on Firebase or on navigation.
///
/// The backend's FCM data map carries exactly one key — `type` — and no entity
/// identifier, so nothing here can identify a specific booking, estimate,
/// invoice or notification: [type] is the only routing input there is.
@immutable
class PushMessage {
  /// Firebase's own message id, used only to ignore a duplicate delivery.
  /// Empty when the platform did not supply one.
  final String messageId;

  /// The raw notification category (`approvalNeeded`, `bookingReceived`, …).
  /// Empty when the payload carried none.
  final String type;

  const PushMessage({this.messageId = '', this.type = ''});

  factory PushMessage.fromRemote(RemoteMessage message) => PushMessage(
    messageId: message.messageId ?? '',
    type: (message.data['type'] ?? '').toString(),
  );

  /// The payload of a locally displayed notification, which is the category.
  factory PushMessage.fromLocalPayload(String? payload) =>
      PushMessage(type: (payload ?? '').trim());

  @override
  bool operator ==(Object other) =>
      other is PushMessage &&
      other.messageId == messageId &&
      other.type == type;

  @override
  int get hashCode => Object.hash(messageId, type);

  @override
  String toString() => 'PushMessage($messageId, $type)';
}

/// The push events an application may react to.
///
/// Implemented by [PushNotificationService] and replaced by a fake in tests, so
/// no widget or test needs Firebase.
abstract interface class PushNotificationSource {
  /// Pushes that arrived while the app was in the foreground.
  Stream<PushMessage> get foregroundMessages;

  /// Pushes the user tapped, in the background or while the app was running.
  Stream<PushMessage> get openedMessages;

  /// The push that launched the app, if it was launched by one. Reads it once.
  Future<PushMessage?> takeInitialMessage();
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) await Firebase.initializeApp();
}

/// One notification implementation shared by all four mobile applications.
/// Native Firebase config remains app-specific; permission, foreground display,
/// installation refresh and backend registration stay consistent everywhere.
///
/// Delivering events to the UI is opt-in and navigation-agnostic: an app
/// subscribes to [foregroundMessages] / [openedMessages] only if it wants them,
/// so the other applications are unaffected.
class PushNotificationService implements PushNotificationSource {
  PushNotificationService._();

  static final PushNotificationService instance = PushNotificationService._();
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'orient_updates',
    'Orient updates',
    description: 'Workshop status, assignments and customer updates',
    importance: Importance.high,
  );

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  DeviceTokenRegistrar? _registrar;
  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedSubscription;
  final StreamController<PushMessage> _foreground =
      StreamController<PushMessage>.broadcast();
  final StreamController<PushMessage> _opened =
      StreamController<PushMessage>.broadcast();
  Future<PushMessage?>? _initialMessage;
  bool _initialized = false;

  @override
  Stream<PushMessage> get foregroundMessages => _foreground.stream;

  @override
  Stream<PushMessage> get openedMessages => _opened.stream;

  @override
  Future<PushMessage?> takeInitialMessage() {
    // Read once per process: a launched-by-push message must never be replayed
    // after the user has already been taken to its destination.
    return _initialMessage ??= _readInitialMessage();
  }

  Future<PushMessage?> _readInitialMessage() async {
    try {
      final message = await FirebaseMessaging.instance.getInitialMessage();
      return message == null ? null : PushMessage.fromRemote(message);
    } catch (error, _) {
      debugPrint('Initial push message unavailable: $error');
      return null;
    }
  }

  bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> initialize() async {
    if (_initialized || !isSupported) return;
    try {
      if (Firebase.apps.isEmpty) await Firebase.initializeApp();
    } catch (error, _) {
      debugPrint('Firebase initialization skipped: $error');
      return;
    }
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _localNotifications.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      // Tapping the notification we displayed ourselves is an open intent too.
      onDidReceiveNotificationResponse: (response) {
        final message = PushMessage.fromLocalPayload(response.payload);
        if (message.type.isNotEmpty) _opened.add(message);
      },
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    await FirebaseMessaging.instance.requestPermission();
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    _foregroundSubscription = FirebaseMessaging.onMessage.listen(
      _showForegroundNotification,
    );
    _openedSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      (message) => _opened.add(PushMessage.fromRemote(message)),
    );
    _tokenRefreshSubscription = FirebaseMessaging.instance.onTokenRefresh
        .listen(_registerToken);
    _initialized = true;
  }

  Future<void> registerForAuthenticatedUser(
    DeviceTokenRegistrar registrar,
  ) async {
    _registrar = registrar;
    if (!_initialized) await initialize();
    if (!_initialized) return;
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null && token.isNotEmpty) {
      await _registerToken(token);
    }
  }

  Future<void> clearAuthenticatedUser() async {
    _registrar = null;
    if (_initialized) await FirebaseMessaging.instance.deleteToken();
  }

  Future<void> _registerToken(String token) async {
    final registrar = _registrar;
    if (registrar == null) return;
    final platform = defaultTargetPlatform == TargetPlatform.iOS
        ? 'ios'
        : 'android';
    await registrar(token, platform);
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    // Publish before any platform-specific display so every platform can react
    // to the event; the local copy below stays Android-only.
    _foreground.add(PushMessage.fromRemote(message));

    // iOS already presents foreground notifications through
    // setForegroundNotificationPresentationOptions; showing a local copy would
    // display the same notification twice.
    if (defaultTargetPlatform == TargetPlatform.iOS) return;
    final notification = message.notification;
    if (notification == null) return;
    await _localNotifications.show(
      id: message.messageId.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'orient_updates',
          'Orient updates',
          channelDescription:
              'Workshop status, assignments and customer updates',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      // The backend sends the category, never a route, so the tapped payload
      // is the one value that can be resolved safely.
      payload: message.data['type']?.toString(),
    );
  }

  Future<void> dispose() async {
    await _tokenRefreshSubscription?.cancel();
    await _foregroundSubscription?.cancel();
    await _openedSubscription?.cancel();
    await _foreground.close();
    await _opened.close();
  }
}
