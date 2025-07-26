import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:finalflutter/models/item_model.dart';
import 'package:finalflutter/services/user/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finalflutter/services/data/task_complete.dart';

AuthService authService = AuthService();

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

Future<String> auth() async {
  final token = await authService.getToken();
  if (token == null) {
    throw AuthException('Token not found');
  }
  return token;
}

class Service {
  final http.Client client;
  late String bearer;

  Service({http.Client? client}) : client = client ?? http.Client();

  Future<List<Item>> getItems() async {
    bearer = await auth();
    final response = await client.get(
      Uri.parse("https://todo.hemex.ai/api/todo"),
      headers: {'Authorization': 'Bearer $bearer'},
    );

    if (response.statusCode == 401) {
      authService.clearToken();
      throw AuthException("Token expired");
    }

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Item.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load posts");
    }
  }

  Future<Item> getDetailed(int id) async {
    final completedTasks = await CompletedTaskStorage.getCompletedTasks();

    try {
      return completedTasks.firstWhere((item) => item.id == id);
    } catch (_) {}

    bearer = await auth();
    final response = await client.get(
      Uri.parse("https://todo.hemex.ai/api/todo/$id"),
      headers: {'Authorization': 'Bearer $bearer'},
    );

    if (response.statusCode == 401) {
      authService.clearToken();
      throw AuthException("Token expired");
    }

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Item.fromJson(json);
    } else {
      throw Exception("Failed to load item details");
    }
  }

  Future<String> addItems(PostItem item) async {
    bearer = await auth();
    final response = await client.post(
      Uri.parse("https://todo.hemex.ai/api/todo"),
      headers: {
        'Authorization': 'Bearer $bearer',
        'Content-Type': 'application/json'
      },
      body: json.encode(item.toJson()),
    );

    if (response.statusCode == 401) {
      authService.clearToken();
      throw AuthException("Token expired");
    }

    if (response.statusCode == 200) {
      return 'Added';
    } else {
      throw Exception("Failed to add post");
    }
  }

  Future<void> delItems(int id) async {
    bearer = await auth();
    final response = await client.delete(
      Uri.parse("https://todo.hemex.ai/api/todo/$id"),
      headers: {'Authorization': 'Bearer $bearer'},
    );

    if (response.statusCode == 401) {
      authService.clearToken();
      throw AuthException("Token expired");
    }

    if (response.statusCode != 200) {
      throw Exception("Failed to delete post");
    }
  }

  Future<void> updateItems(PostItem item, int id) async {
    bearer = await auth();
    final response = await client.patch(
      Uri.parse("https://todo.hemex.ai/api/todo/$id"),
      headers: {
        'Authorization': 'Bearer $bearer',
        'Content-Type': 'application/json'
      },
      body: json.encode(item.toJson()),
    );

    if (response.statusCode == 401) {
      authService.clearToken();
      throw AuthException("Token expired");
    }

    if (response.statusCode != 200) {
      throw Exception("Failed to update post");
    }
  }

  Future<void> completeTask(Item item) async {
    await delItems(item.id);
    await CompletedTaskStorage.addCompletedTask(item);
  }
}
