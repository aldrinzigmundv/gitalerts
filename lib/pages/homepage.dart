import 'package:flutter/material.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:gitalerts/services/workmanager.dart';
import 'package:gitalerts/services/githubapi.dart';
import 'package:gitalerts/pages/settingspage.dart';

class HomePage extends StatefulWidget {
  const HomePage(
      {super.key,
      required this.storage,
      required this.github,
      required this.token});

  final FlutterSecureStorage storage;
  final GitHubApi github;
  final String token;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late FlutterSecureStorage storage;
  late GitHubApi github;
  late String token;

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  List<dynamic> _notifications = [];

  _checkIfSetupDone() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    if (await storage.read(key: "setup") != "done") {
      await _showInfoDialogBox();
      bool result = await _getNotificationPermission();
      if (result) {
        await initializeBackgroundTasks(const Duration(minutes: 15));
      }
      await storage.write(key: 'setup', value: "done");
    } else {
      await flutterLocalNotificationsPlugin.cancelAll();
    }
  }

  _showInfoDialogBox() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Receive Notifications'),
          content: const Text(
              'Enable notifications for GitAlerts to receive updates from your GitHub Account.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  _getNotificationPermission() async {
    bool? result = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    if (result == true || result == null) {
      return true;
    } else {
      return false;
    }
  }

  _getGitHubNotifications() async {
    try {
      List<dynamic> result = await github.getGitHubNotifications(token);
      setState(() {
        _notifications = result;
      });
      if (_notifications.isNotEmpty) {
        String lastnotification = _notifications[0]['subject']['title'];
        storage.write(key: 'lastnotification', value: lastnotification);
      }
    } catch (_) {
      _showError();
    }
  }

  _showError() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text(
          "Something went wrong. Please, check your token and internet connection."),
      duration: Duration(seconds: 2),
    ));
  }

  _goToSettingsPage() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SettingsPage(
                  storage: storage,
                  github: github,
                )));
  }

  @override
  void initState() {
    super.initState();
    storage = widget.storage;
    github = widget.github;
    token = widget.token;
    _getGitHubNotifications();
    _checkIfSetupDone();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('GitAlerts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _goToSettingsPage(),
          ),
        ],
      ),
      backgroundColor: Colors.grey,
      body: RefreshIndicator(
        onRefresh: () => _getGitHubNotifications(),
        color: Colors.black,
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final notification = _notifications[index];
                  final repoFullName = notification['repository']['full_name'];
                  final notificationText = notification['subject']['title'];

                  return Card(
                    margin: const EdgeInsets.all(6.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(9.0),
                          child: Text(
                            repoFullName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Text(
                            notificationText,
                            style: const TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
