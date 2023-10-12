import 'dart:convert';

import 'package:http/http.dart';

class GitHubApi {
  Future<bool> checkNotificationsAccess(String token) async {
    final response = await get(
      Uri.parse('https://api.github.com/notifications'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 304) {
      return true;
    } else {
      return false;
    }
  }

  Future<List<dynamic>> getGitHubNotifications(String token) async {
    final uri = Uri.parse('https://api.github.com/notifications')
        .replace(queryParameters: {
      'all': 'true',
    });
    Response response = await get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/vnd.github+json',
        'X-GitHub-Api-Version': '2022-11-28',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 304) {
      final List<dynamic> notifications = jsonDecode(response.body);
      return notifications;
    } else {
      throw Exception('Failed to fetch notifications');
    }
  }

  Future<List<dynamic>> checkGitHubNotifications(String token) async {
    final uri = Uri.parse('https://api.github.com/notifications');
    Response response = await get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/vnd.github+json',
        'X-GitHub-Api-Version': '2022-11-28',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 304) {
      final List<dynamic> notifications = jsonDecode(response.body);
      return notifications;
    } else {
      throw Exception('Failed to fetch notifications');
    }
  }

  Future<void> markNotificationsAsRead(String token) async {
    await put(
      Uri.parse('https://api.github.com/notifications'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/vnd.github+json',
        'X-GitHub-Api-Version': '2022-11-28',
      },
    );
  }
}
