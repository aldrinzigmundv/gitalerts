import 'package:flutter/material.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:permission_handler/permission_handler.dart';

import 'package:gitalerts/services/workmanager.dart';
import 'package:gitalerts/services/githubapi.dart';
import 'package:gitalerts/pages/setuppage.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.storage, required this.github});

  final FlutterSecureStorage storage;
  final GitHubApi github;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late FlutterSecureStorage storage;
  late GitHubApi github;

  bool _permissionAllowed = true;

  String _frequencyDropdownValue = 'Check GitHub Every 15 Mins';

  final List<String> _frequencies = <String>[
    'Check GitHub Every 15 Mins',
    'Check GitHub Every Hour',
    'Check GitHub Once a Day',
  ];

  _checkNotificationPermission() async {
    if (await Permission.notification.isGranted) {
      setState(() {
        _permissionAllowed = true;
      });
    } else {
      setState(() {
        _permissionAllowed = false;
      });
    }
  }

  _getNotificationPermission() async {
    PermissionStatus result = await Permission.notification.request();
    if (result == PermissionStatus.granted) {
      setState(() {
        _permissionAllowed = true;
      });
    } else {
      setState(() {
        _permissionAllowed = false;
      });
    }
  }

  _setNewFrequency() async {
    late Duration duration;
    if (await Permission.notification.isGranted) {
      switch (_frequencyDropdownValue) {
        case 'Check GitHub Every 15 Mins':
          duration = const Duration(minutes: 15);
          break;
        case 'Check GitHub Every Hour':
          duration = const Duration(hours: 1);
          break;
        case 'Check GitHub Once a Day':
          duration = const Duration(days: 1);
          break;
      }
      await initializeBackgroundTasks(duration);
      _showSuccess();
    }
  }

  _resetApp() {
    storage.deleteAll();
    _goToSetupPage();
  }

  _showSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Successfully updated GitAlerts Settings."),
      duration: Duration(seconds: 2),
    ));
  }

  _goToSetupPage() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (context) => SetupPage(
                storage: storage,
                github: github,
              )),
      (route) => false,
    );
  }

  @override
  void initState() {
    super.initState();
    storage = widget.storage;
    github = widget.github;
    _checkNotificationPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const SizedBox(
          height: 9.0,
        ),
        Padding(
          padding: const EdgeInsets.all(9.0),
          child: ElevatedButton(
            onPressed:
                (!_permissionAllowed) ? _getNotificationPermission : null,
            style: ButtonStyle(
                backgroundColor: (!_permissionAllowed)
                    ? MaterialStateProperty.all(Colors.black)
                    : MaterialStateProperty.all(Colors.grey),
                foregroundColor: MaterialStateProperty.all(Colors.white)),
            child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  (!_permissionAllowed)
                      ? 'Grant Notifications Permission'
                      : 'Notifications Already Granted',
                  style: const TextStyle(fontSize: 20.0),
                )),
          ),
        ),
        const SizedBox(
          height: 27.0,
        ),
        Padding(
          padding: const EdgeInsets.all(9.0),
          child: DropdownMenu(
            width: MediaQuery.of(context).size.width - 18.0,
            initialSelection: _frequencyDropdownValue,
            dropdownMenuEntries: _frequencies.map((String value) {
              return DropdownMenuEntry(
                value: value,
                label: value,
              );
            }).toList(),
            onSelected: (String? newValue) {
              setState(() {
                _frequencyDropdownValue = newValue!;
              });
            },
          ),
        ),
        Padding(
            padding: const EdgeInsets.all(9.0),
            child: ElevatedButton(
              onPressed: () => _setNewFrequency(),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.black),
                  foregroundColor: MaterialStateProperty.all(Colors.white)),
              child: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    "Save Frequency",
                    style: TextStyle(fontSize: 20.0),
                  )),
            )),
        const SizedBox(
          height: 36.0,
        ),
        Padding(
            padding: const EdgeInsets.all(9.0),
            child: ElevatedButton(
              onPressed: () => _resetApp(),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.black),
                  foregroundColor: MaterialStateProperty.all(Colors.white)),
              child: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    "Reset And Enter New Token",
                    style: TextStyle(fontSize: 20.0),
                  )),
            )),
      ])),
    );
  }
}
