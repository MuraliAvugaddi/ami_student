import 'dart:convert';
import 'package:ami_student/api/api_endpoint.dart';
import 'package:http/http.dart' as http;

class AuthService {
  // Step 1: Checks availability and sends SMTP OTP email
  Future<bool> checkEmailAvailability(String email) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.signupStep1),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        return true; 
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to send verification code.');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // NEW METHOD: Sends verification code to backend
  Future<bool> verifyOtp(String email, String otp) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.verifyOtp),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
        }),
      );

      if (response.statusCode == 200) {
        return true; 
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Verification failed.');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Step 2: Creates the actual account
  Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
    required String enrollmentNo,
    required String course,
    required String year,
    required String phonenumber,
    required String hostelblock,
    required String room,
    required String gender,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.signupStep2),
        headers: {'Content-Type': 'application/json'}, 
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'enrollmentNo': enrollmentNo,
          'course': course,
          'year': year,
          'phonenumber': phonenumber,
          'hostelblock': hostelblock,
          'room': room,
          'gender': gender,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception('Error during registration: ${e.toString()}');
    }
  }

  // Standard Signin
  static Future<Map<String, dynamic>> signin(
      {required String email, required String password}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.signinpage),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"email": email, 'password': password}),
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'Failed to sign in.');
      }
    } catch (e) {
      throw Exception('Error during sign-in: ${e.toString()}');
    }
  }

  // ✅ ADDED: HTTP Requester for sending forgot password code
  Future<bool> requestPasswordReset(String email) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.forgotPassword),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return true;
      throw Exception(data['message'] ?? 'Failed to send reset code.');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // ✅ ADDED: HTTP Requester for resetting password with OTP verification
  Future<bool> finalizePasswordReset(String email, String otp, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.resetPassword),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
          'newPassword': newPassword,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return true;
      throw Exception(data['message'] ?? 'Failed to update password.');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}