import 'dart:convert';
import 'package:ami_student/api/api_endpoint.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class MenuService {
  final box = GetStorage();

  // Fetch current active menu for user
  Future<Map<String, dynamic>> fetchActiveMenu() async {
    final token = box.read('token');
    if (token == null) {
      throw Exception('Authentication token not found.');
    }

    final response = await http.get(
      Uri.parse(ApiEndpoints.menuActive),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return data['menu'];
    } else {
      throw Exception(data['message'] ?? 'Failed to fetch menu');
    }
  }

  // Admin upload/update menu API call
  Future<bool> uploadMonthlyMenu(Map<String, dynamic> menuPayload) async {
    final token = box.read('token');
    if (token == null) {
      throw Exception('Authentication token not found.');
    }

    final response = await http.post(
      Uri.parse(ApiEndpoints.adminUploadMenu),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(menuPayload),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return true;
    } else {
      throw Exception(data['message'] ?? 'Failed to publish menu');
    }
  }
}