import 'dart:async';

import 'package:firebase_app_installations/firebase_app_installations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

typedef DeviceTokenRegistrar =
    Future<bool> Function(String token, String platform);

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) await Firebase.initializeApp();
}

/// One notification implementation shared by all four mobile applications.
/// Native Firebase config remains app-specific; permission, foreground display,
/// installation refresh and backend registration stay consistent everywhere.
class PushNotificationService {
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
  StreamSubscription<String>? _installationIdSubscription;
  bool _initialized = false;

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
    FirebaseMessaging.onMessage.listen(_showForegroundNotification);
    _installationIdSubscription = FirebaseInstallations.instance.onIdChange
        .listen(_registerInstallation);
    _initialized = true;
  }

  Future<void> registerForAuthenticatedUser(
    DeviceTokenRegistrar registrar,
  ) async {
    _registrar = registrar;
    if (!_initialized) await initialize();
    if (!_initialized) return;
    final installationId = await FirebaseInstallations.instance.getId();
    if (installationId.isNotEmpty) {
      await _registerInstallation(installationId);
    }
  }

  Future<void> clearAuthenticatedUser() async {
    _registrar = null;
    if (_initialized) await FirebaseInstallations.instance.delete();
  }

  Future<void> _registerInstallation(String installationId) async {
    final registrar = _registrar;
    if (registrar == null) return;
    final platform = defaultTargetPlatform == TargetPlatform.iOS
        ? 'ios'
        : 'android';
    await registrar(installationId, platform);
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
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
      payload: message.data['route']?.toString(),
    );
  }

  Future<void> dispose() async {
    await _installationIdSubscription?.cancel();
  }
}
