import 'dart:async';
import 'dart:convert';

import 'package:ami_student/Screens/auth/onbording_screen.dart';
import 'package:ami_student/api/api_endpoint.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

// ============================================================
// HOSTEL SERVICE
// Room complaints, SOS and hostel notifications.
// ============================================================

class HostelService {
  final box = GetStorage();

  String? get token => box.read('token');

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  // ============================================================
  // SESSION EXPIRED → back to login (same as ApiService)
  // ============================================================

  void _checkTokenExpiry(int statusCode) {
    if (statusCode == 401) {
      box.remove('token');
      box.remove('user_data');

      Get.offAll(() => const OnboardingScreen());

      Get.snackbar(
        "Session Expired",
        "Your session has expired. Please log in again.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<Map<String, dynamic>> _send(
    Future<http.Response> Function() request, {
    int seconds = 25,
  }) async {
    if (token == null) {
      return {'success': false, 'message': 'Please log in again.'};
    }
    try {
      final response = await request().timeout(Duration(seconds: seconds));
      _checkTokenExpiry(response.statusCode);

      final dynamic data = json.decode(response.body);
      if (data is Map<String, dynamic>) {
        data['success'] ??= response.statusCode >= 200 && response.statusCode < 300;
        return data;
      }
      return {'success': false, 'message': 'Something went wrong.'};
    } on TimeoutException {
      return {'success': false, 'message': 'Server is slow. Please try again.'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error. Check your internet.'};
    }
  }

  // ============================================================
  // COMPLAINTS
  // ============================================================

  Future<Map<String, dynamic>> raiseComplaint({
    required String category,
    required String title,
    String description = '',
    String? photoBase64,
  }) {
    return _send(
      () => http.post(
        Uri.parse(ApiEndpoints.complaints),
        headers: _headers,
        body: json.encode({
          'category': category,
          'title': title,
          'description': description,
          if (photoBase64 != null) 'photoBase64': photoBase64,
        }),
      ),
      seconds: 60,
    );
  }

  Future<Map<String, dynamic>> getMyComplaints() {
    return _send(() => http.get(Uri.parse(ApiEndpoints.myComplaints), headers: _headers));
  }

  Future<Map<String, dynamic>> getComplaint(String id) {
    return _send(() => http.get(Uri.parse(ApiEndpoints.complaintById(id)), headers: _headers));
  }

  Future<Map<String, dynamic>> confirmComplaint(
    String id, {
    required bool fixed,
    int rating = 5,
    String comment = '',
  }) {
    return _send(
      () => http.post(
        Uri.parse(ApiEndpoints.confirmComplaint(id)),
        headers: _headers,
        body: json.encode({'fixed': fixed, 'rating': rating, 'comment': comment}),
      ),
    );
  }

  // ============================================================
  // SOS
  // ============================================================

  Future<Map<String, dynamic>> sendSos(String type, String note) {
    return _send(
      () => http.post(
        Uri.parse(ApiEndpoints.sos),
        headers: _headers,
        body: json.encode({'type': type, 'note': note}),
      ),
    );
  }

  Future<Map<String, dynamic>> getMySos() {
    return _send(() => http.get(Uri.parse(ApiEndpoints.mySos), headers: _headers));
  }

  // ============================================================
  // NOTIFICATIONS
  // ============================================================

  Future<Map<String, dynamic>> getNotifications() {
    return _send(() => http.get(Uri.parse(ApiEndpoints.hostelNotifications), headers: _headers));
  }

  Future<Map<String, dynamic>> markAllRead() {
    return _send(() => http.post(Uri.parse(ApiEndpoints.hostelNotificationsReadAll), headers: _headers));
  }
}
