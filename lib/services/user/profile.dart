import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart'; // for co
import 'package:mime/mime.dart';

class ProfileService {
  final String apiUrl = 'https://todo.hemex.ai/api/user'; // Replace this with your API URL

  /// Fetch profile, manually add username from SharedPrefs, and save it back to SharedPrefs
  Future<Map<String, dynamic>> fetchAndSaveUsername() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      final username = prefs.getString('username'); // locally stored username

      if (token == null) throw Exception("Token not found");

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Manually insert username if it exists in prefs
        if (username != null && username.isNotEmpty) {
          data['username'] = username;
        }

        // Re-save username just in case
        await prefs.setString('username', username ?? '');

        return data;
      } else {
        throw Exception("Failed to fetch profile: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching profile: $e");
    }
  }


  /// Patch profile with optional image and fields like petName, address
  Future<bool> updateProfile({
    String? petName,
    String? address,
    File? imageFile,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      if (token == null) throw Exception("Token not found");

      final request = http.MultipartRequest("PATCH", Uri.parse(apiUrl));
      request.headers['Authorization'] = 'Bearer $token';

      if (petName != null && petName != "") {
        request.fields['petName'] = petName;
      }

      if (address != null && address != "") {
        request.fields['address'] = address;
      }

      if (imageFile != null) {
        final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';
        final fileStream = http.MultipartFile(
          'photo',
          imageFile.readAsBytes().asStream(),
          await imageFile.length(),
          filename: imageFile.path.split("/").last,
          contentType: MediaType.parse(mimeType),
        );
        request.files.add(fileStream);
      }

      final response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 204 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Error');
        return false;
      }
    } catch (e) {
      throw Exception("Error updating profile: $e");
      return false;
    }
  }

  /// Optionally get stored username
  Future<String?> getStoredUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }
}
