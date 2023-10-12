import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:gitalerts/services/githubapi.dart';
import 'package:gitalerts/services/notifications.dart';

class UpdateChecker {
  late GitHubApi github;
  late FlutterSecureStorage storage;
  late String token;
  late List<dynamic> notifications;
  late String lastNotification;
  late NotificationService notificationService;
  late int notificationNumber;
  late int notificationsSent;

  Future<bool> checkForUpdates() async {
    try {
      await _downloadNotifications();
      if (notifications.isNotEmpty) {
        await _prepareSendingNotifications();
        await _iterateOverNotifications();
        await _saveLastNotification();
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  _downloadNotifications() async {
    github = GitHubApi();
    storage = const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true));

    token = await storage.read(key: "token") ?? "";
    notifications = await github.checkGitHubNotifications(token);
    lastNotification = await storage.read(key: 'lastnotification') ?? "";
  }

  _prepareSendingNotifications() async {
    notificationService = NotificationService();
    await notificationService.init();
    notificationNumber =
        int.parse(await storage.read(key: 'notificationnumber') ?? "0");
    notificationsSent = 0;
  }

  _iterateOverNotifications() async {
    for (dynamic notification in notifications) {
      if (notificationsSent < 9) {
        if (notification['subject']['title'] == lastNotification) {
          // Found the last notification, no need to send more notifications.
          break;
        } else {
          // Call notification function, passing the current notification.
          if (notification['repository']['full_name'] != null &&
              notification['subject']['title'] != null) {
            String title = notification['repository']['full_name'] ?? "";
            String description = notification['subject']['title'] ?? "";
            await notificationService.showNotifications(
                notificationNumber, title, description);
            notificationsSent++;
            notificationNumber++;
            await storage.write(
                key: 'notificationnumber',
                value: notificationNumber.toString());
          }
        }
      } else {
        // Reached the maximum of 9 notifications, stop checking.
        break;
      }
    }
  }

  _saveLastNotification() async {
    await storage.write(
        key: 'lastnotification',
        value: notifications[0]['subject']['title'] ?? "");
  }
}
