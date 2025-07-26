import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {


  Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse('https://todo.hemex.ai/api/auth/signin');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);

        return {
          "status": "succeed",
          "accessToken": data['accessToken'],
          "user": data['user'],
        };
      } else {
        final errorData = jsonDecode(response.body);

        return {
          "status": "failed",
          "message": errorData['message'] ?? ['Unknown error'],
        };
      }
    } catch (e) {
      return {
        "status": "failed",
        "message": ['Network error: $e'],
      };
    }
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', token);
  }
  Future<void> saveusername(String user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', user);
  }

  // Optional: add method to retrieve the token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  // Optional: clear token
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
  }

  Future<Map<String, dynamic>> signup(String username, String password) async {
    final url = Uri.parse('https://todo.hemex.ai/api/auth/signup');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);

        return {
          "status": "succeed",

        };
      } else {
        final errorData = jsonDecode(response.body);

        return {
          "status": "failed",
          "message": errorData['message'] ?? ['Unknown error'],
        };
      }
    } catch (e) {
      return {
        "status": "failed",
        "message": ['Network error: $e'],
      };
    }
  }
}