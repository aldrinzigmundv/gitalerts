import 'package:flutter/material.dart';

import 'package:workmanager/workmanager.dart';

import 'package:gitalerts/services/updatechecker.dart';
import 'package:gitalerts/pages/loadingpage.dart';


@pragma('vm:entry-point')
void callbackDispatcher() async {
  Workmanager().executeTask((task, inputData) async {
    UpdateChecker updatechecker = UpdateChecker();
    bool result = await updatechecker.checkForUpdates();
    return Future.value(result);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
      title: "GitAlerts",
      home: LoadingPage(),
    ));
}