import 'package:ami_student/Screens/auth/onbording_screen.dart';
import 'package:ami_student/api/api_endpoint.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ApiService {
  static const String _baseUrl = ApiEndpoints.tokenBaseUrl;
  final box = GetStorage();

  // Helper to get the current token from storage
  String? get token => box.read('token');

  /// ✅ THE MAGIC FUNCTION: Checks for expired tokens globally.
  /// If the Backend returns 401 (Unauthorized) or 403 (Forbidden),
  /// it means the JWT is dead.
  void _checkTokenExpiry(int statusCode) {
    // ✅ FIX: only 401 means the login is invalid. The backend uses 403 for
    // "Access expired / meal skipped" — that must NOT log the student out.
    if (statusCode == 401) {
      // 1. Clear ALL sensitive data from the phone
      box.remove('token');
      box.remove('user_data');

      // 2. Force the user back to the Onboarding/Login screen
      Get.offAll(() => const OnboardingScreen());

      // 3. Notify the student
      Get.snackbar(
        "Session Expired",
        "Your session has expired. Please log in again.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    }
  }

  // --- API METHODS ---

  Future<Map<String, dynamic>> submitMealSkip(
      String date, String mealType) async {
    if (token == null) return {'success': false, 'message': 'Auth missing'};
    try {
      final response = await http.post(
        Uri.parse('${ApiEndpoints.tokenBaseUrl}/skip'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: json.encode({'date': date, 'mealType': mealType}),
      );
      _checkTokenExpiry(response.statusCode);
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Connection error.'};
    }
  }

  Future<Map<String, dynamic>> getMySkips({required int page, required String month}) async {
    if (token == null) return {'success': false, 'message': 'Auth missing'};
    try {
      final response = await http.get(
        Uri.parse('${ApiEndpoints.tokenBaseUrl}/my-skips?page=$page&month=$month'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      _checkTokenExpiry(response.statusCode);
      return response.statusCode == 200
          ? json.decode(response.body)
          : {'success': false, 'message': 'Failed to load skip history.'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error.'};
    }
  }

  // ✅ UPDATED: Added month parameter so history filters by the selected month properly
  Future<Map<String, dynamic>> getUserHistory(int page, String month) async {
    if (token == null) {
      return {'success': false, 'message': 'User not authenticated.'};
    }
    try {
      final response = await http.get(
        Uri.parse('${ApiEndpoints.tokenBaseUrl}/my-history?page=$page&month=$month'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      _checkTokenExpiry(response.statusCode);
      return response.statusCode == 200
          ? json.decode(response.body)
          : {'success': false, 'message': 'Failed to load history.'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error.'};
    }
  }

  // Optional alias if your controller uses getUserHistoryPaginated
  Future<Map<String, dynamic>> getUserHistoryPaginated(int page, String month) async {
    return getUserHistory(page, month);
  }

  Future<Map<String, dynamic>> generateToken(String mealType) async {
    if (token == null) {
      return {'success': false, 'message': 'User not authenticated.'};
    }
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/generate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'mealType': mealType}),
      );
      _checkTokenExpiry(response.statusCode);
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Connection error.'};
    }
  }

  // ==========================================
  // 🚀 CASHFREE PAYMENT METHODS
  // ==========================================

  Future<Map<String, dynamic>> createCashfreeOrder() async {
    if (token == null) return {'success': false, 'message': 'Auth missing'};
    try {
      final response = await http.post(
        Uri.parse('${ApiEndpoints.authBaseUrl}/create-cashfree-order'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      _checkTokenExpiry(response.statusCode);
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Connection error.'};
    }
  }

  Future<Map<String, dynamic>> verifyCashfreePayment(String orderId) async {
    if (token == null) return {'success': false, 'message': 'Auth missing'};
    try {
      final response = await http.post(
        Uri.parse('${ApiEndpoints.authBaseUrl}/verify-cashfree-payment'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'orderId': orderId}),
      );
      _checkTokenExpiry(response.statusCode);
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Payment verification failed.'};
    }
  }

  // ==========================================

  Future<Map<String, dynamic>> getUserPaymentHistory() async {
    if (token == null) return {'success': false, 'message': 'Auth missing'};
    try {
      final response = await http.get(
        Uri.parse('${ApiEndpoints.authBaseUrl}/payment-history'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      _checkTokenExpiry(response.statusCode);
      return response.statusCode == 200
          ? json.decode(response.body)
          : {'success': false, 'message': 'Failed to load payment history.'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error.'};
    }
  }

  Future<Map<String, dynamic>> verifyOnlinePayment(
      String paymentId, String orderId) async {
    if (token == null) return {'success': false, 'message': 'Auth missing'};
    try {
      final response = await http.post(
        Uri.parse('${ApiEndpoints.authBaseUrl}/payment-success'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'paymentId': paymentId,
          'orderId': orderId,
        }),
      );
      _checkTokenExpiry(response.statusCode);
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Payment verification failed.'};
    }
  }

  // ==========================================
  // 🚀 DAY SCHOLAR MEAL PAYMENT METHODS
  // ==========================================

  Future<Map<String, dynamic>> createDayScholarOrder(String mealType) async {
    if (token == null) return {'success': false, 'message': 'Auth missing'};
    try {
      final response = await http.post(
        Uri.parse('${ApiEndpoints.authBaseUrl}/create-dayscholar-order'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'mealType': mealType}),
      );
      _checkTokenExpiry(response.statusCode);
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Connection error.'};
    }
  }

  Future<Map<String, dynamic>> verifyDayScholarPayment(String orderId, String mealType) async {
    if (token == null) return {'success': false, 'message': 'Auth missing'};
    try {
      final response = await http.post(
        Uri.parse('${ApiEndpoints.authBaseUrl}/verify-dayscholar-payment'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'orderId': orderId, 'mealType': mealType}),
      );
      _checkTokenExpiry(response.statusCode);
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Payment verification failed.'};
    }
  }

  Future<Map<String, dynamic>> getTodayStats() async {
    if (token == null) {
      return {'success': false, 'message': 'User not authenticated.'};
    }
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/stats/today'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      _checkTokenExpiry(response.statusCode);
      return response.statusCode == 200
          ? json.decode(response.body)
          : {'breakfast': 0, 'lunch': 0, 'snacks': 0, 'dinner': 0};
    } catch (e) {
      return {'breakfast': 0, 'lunch': 0, 'snacks': 0, 'dinner': 0};
    }
  }
}
