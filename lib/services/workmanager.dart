import 'package:gitalerts/main.dart';
import 'package:workmanager/workmanager.dart';

initializeBackgroundTasks(Duration duration) async {
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  await Workmanager().registerPeriodicTask(
    "gitalertspushnotifications",
    "GitAlerts Push Notifications",
    frequency: duration,
    initialDelay: const Duration(seconds: 900),
    constraints: Constraints(networkType: NetworkType.connected),
    existingWorkPolicy: ExistingWorkPolicy.replace,
  );
}
