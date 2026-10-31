import 'dart:convert';
import 'package:ami_student/Models/user_model.dart';
import 'package:ami_student/api/api_endpoint.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

class UserService {
  // ============================================================
  // FETCH PROFILE
  // ============================================================
  Future<User> fetchUserProfile() async {
    final box = GetStorage();
    final token = box.read('token');
    if (token == null) {
      throw Exception('Authentication token not found. Please log in again.');
    }

    final response = await http.get(
      Uri.parse(ApiEndpoints.userProfile),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
        _extractError(response, 'Failed to load profile'),
      );
    }
  }

  // ============================================================
  // SUBMIT FEEDBACK
  // ============================================================
  Future<bool> submitFeedback(int rating, String message) async {
    final box = GetStorage();
    final token = box.read('token');
    if (token == null) {
      throw Exception('Authentication token not found. Please log in again.');
    }

    final response = await http
        .post(
          Uri.parse(ApiEndpoints.feedback),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'rating': rating,
            'message': message,
          }),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      throw Exception(
        _extractError(response, 'Failed to submit feedback'),
      );
    }
  }

  // ============================================================
  // DELETE ACCOUNT
  // ============================================================
  Future<bool> deleteAccount() async {
    final box = GetStorage();
    final token = box.read('token');
    if (token == null) {
      throw Exception('Authentication token not found.');
    }

    final response = await http.delete(
      Uri.parse(ApiEndpoints.userProfile),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception(
        _extractError(response, 'Failed to delete account'),
      );
    }
  }

  // ============================================================
  // ERROR HELPER
  // ============================================================
  String _extractError(http.Response response, String fallback) {
    try {
      final data = jsonDecode(response.body);
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
    } catch (_) {}
    return '$fallback. Status code: ${response.statusCode}';
  }
}