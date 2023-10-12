import 'package:flutter/material.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:gitalerts/services/githubapi.dart';
import 'package:gitalerts/pages/homepage.dart';

class SetupPage extends StatefulWidget {
  const SetupPage({super.key, required this.storage, required this.github});

  final FlutterSecureStorage storage;
  final GitHubApi github;

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  final TextEditingController _token = TextEditingController();

  late FlutterSecureStorage storage;
  late GitHubApi github;

  _saveTokenButtonPressed() async {
    bool tokenworking = await github.checkNotificationsAccess(_token.text);
    if (tokenworking) {
      await storage.write(key: "token", value: _token.text);
      _goToHomePage();
    } else {
      _showError();
    }
  }

  _goToHomePage() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => HomePage(
                  storage: storage,
                  github: github,
                  token: _token.text,
                )));
  }

  _showError() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text(
          "Something went wrong. Please, check your token and internet connection."),
      duration: Duration(seconds: 2),
    ));
  }

  @override
  void dispose() {
    _token.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    storage = widget.storage;
    github = widget.github;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: const Text('Setup GitAlerts'),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(9.0),
                  child: TextField(
                    controller: _token,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                        hintText:
                            'Enter GitHub Personal Access Token (Classic)'),
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.all(9.0),
                    child: ElevatedButton(
                      onPressed: () => _saveTokenButtonPressed(),
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.black),
                          foregroundColor:
                              MaterialStateProperty.all(Colors.white)),
                      child: const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Text(
                            "Save Token",
                            style: TextStyle(fontSize: 20.0),
                          )),
                    )),
                const SizedBox(
                  height: 18.0,
                ),
                const Padding(
                    padding: EdgeInsets.all(27.0),
                    child: Text(
                        'Please enter a personal access token (classic) with access limited to your GitHub notifications.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 255, 0, 0),
                        ))),
              ],
            ),
          ),
        ));
  }
}
