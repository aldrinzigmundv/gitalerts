import 'package:flutter/material.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:gitalerts/pages/loadingpage.dart';

class NotificationService {
  static final NotificationService _notificationService =
      NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: false,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
            macOS: null);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (response) =>
            selectNotification(response));
  }

  final AndroidNotificationDetails _androidNotificationDetails =
      const AndroidNotificationDetails(
    'gitalerts_notifications',
    'GitAlerts Notifications',
    channelDescription:
        'Receive notifications from your GitHub account via GitAlerts',
    playSound: true,
    priority: Priority.high,
    importance: Importance.high,
  );

  Future<void> showNotifications(
      int id, String title, String description) async {
    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      description,
      NotificationDetails(android: _androidNotificationDetails),
    );
  }

  clearNotfications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}

selectNotification(NotificationResponse response) async {
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final navigatorState = navigatorKey.currentState;
  if (navigatorState?.context != null) {
    Navigator.of(navigatorState!.context)
        .push(MaterialPageRoute(builder: (context) => const LoadingPage()));
  }
}
