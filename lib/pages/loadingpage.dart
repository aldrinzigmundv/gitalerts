import 'package:flutter/material.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:gitalerts/services/githubapi.dart';
import 'package:gitalerts/pages/homepage.dart';
import 'package:gitalerts/pages/setuppage.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  late FlutterSecureStorage storage;
  late GitHubApi github;

  _startup() {
    Future.delayed(const Duration(seconds: 1), () async {
      github = GitHubApi();
      storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true));
      String? setup = await storage.read(key: "setup");
      if (setup != null) {
        String token = await storage.read(key: "token") ?? "";
        _goToHomePage(token);
      } else {
        _goToSetupPage();
      }
    });
  }

  _goToHomePage(String token) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => HomePage(
                  storage: storage,
                  github: github,
                  token: token,
                )));
  }

  _goToSetupPage() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => SetupPage(
                  storage: storage,
                  github: github,
                )));
  }

  @override
  void initState() {
    super.initState();
    _startup();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
                padding: const EdgeInsets.all(9.0),
                child: Image.asset('assets/icons/icon.png')),
            const Padding(
              padding: EdgeInsets.all(9.0),
              child: Text(
                'GitAlerts',
                style: TextStyle(color: Colors.white, fontSize: 27.0),
              ),
            ),
          ],
        )));
  }
}
