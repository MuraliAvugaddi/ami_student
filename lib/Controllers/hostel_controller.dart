import 'dart:convert';

import 'package:ami_student/services/hostel_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ============================================================
// HOSTEL CONTROLLER
// Keeps complaints, SOS and hostel notifications in one place
// so Home, Hostel tab and the bell all show the same data.
// ============================================================

class HostelController extends GetxController {
  final HostelService _service = HostelService();

  final RxList<Map<String, dynamic>> complaints = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> notifications = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> mySos = <Map<String, dynamic>>[].obs;

  final RxInt unread = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool isSending = false.obs;

  // ============================================================
  // GETTERS
  // ============================================================

  List<Map<String, dynamic>> get activeComplaints => complaints
      .where((c) => ['open', 'in_progress', 'reopened', 'repaired'].contains(c['status']))
      .toList();

  int get waitingForConfirm => complaints.where((c) => c['status'] == 'repaired').length;

  Map<String, dynamic>? get activeSos {
    for (final s in mySos) {
      if (s['status'] != 'handled') return s;
    }
    return null;
  }

  // ============================================================
  // INIT
  // ============================================================

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  Future<void> loadAll() async {
    isLoading.value = complaints.isEmpty;
    await Future.wait([loadComplaints(), loadNotifications(), loadSos()]);
    isLoading.value = false;
  }

  Future<void> loadComplaints() async {
    final res = await _service.getMyComplaints();
    if (res['success'] == true) complaints.assignAll(_list(res['complaints']));
  }

  Future<void> loadNotifications() async {
    final res = await _service.getNotifications();
    if (res['success'] == true) {
      notifications.assignAll(_list(res['notifications']));
      unread.value = (res['unread'] is num) ? (res['unread'] as num).toInt() : 0;
    }
  }

  Future<void> loadSos() async {
    final res = await _service.getMySos();
    if (res['success'] == true) mySos.assignAll(_list(res['sos']));
  }

  Future<void> markAllRead() async {
    if (unread.value == 0) return;
    unread.value = 0;
    await _service.markAllRead();
  }

  // ============================================================
  // ACTIONS
  // ============================================================

  Future<bool> raiseComplaint({
    required String category,
    required String title,
    String description = '',
    List<int>? photoBytes,
  }) async {
    isSending.value = true;
    final res = await _service.raiseComplaint(
      category: category,
      title: title,
      description: description,
      photoBase64: photoBytes == null ? null : base64Encode(photoBytes),
    );
    isSending.value = false;

    _toast(res);
    if (res['success'] == true) {
      await loadComplaints();
      return true;
    }
    return false;
  }

  Future<Map<String, dynamic>?> confirmComplaint(
    String id, {
    required bool fixed,
    int rating = 5,
    String comment = '',
  }) async {
    isSending.value = true;
    final res = await _service.confirmComplaint(id, fixed: fixed, rating: rating, comment: comment);
    isSending.value = false;

    _toast(res);
    if (res['success'] == true) {
      await loadComplaints();
      return Map<String, dynamic>.from(res['complaint'] as Map);
    }
    return null;
  }

  Future<bool> sendSos(String type, String note) async {
    isSending.value = true;
    final res = await _service.sendSos(type, note);
    isSending.value = false;

    if (res['success'] == true) {
      await loadSos();
      return true;
    }
    _toast(res);
    return false;
  }

  Future<Map<String, dynamic>?> getComplaint(String id) async {
    final res = await _service.getComplaint(id);
    if (res['success'] == true && res['complaint'] is Map) {
      return Map<String, dynamic>.from(res['complaint'] as Map);
    }
    return null;
  }

  // ============================================================
  // LIVE UPDATE (from SocketService)
  // ============================================================

  void onLiveUpdate(dynamic data) {
    loadAll();
  }

  // ============================================================
  // HELPERS
  // ============================================================

  List<Map<String, dynamic>> _list(dynamic v) =>
      v is List ? v.map((e) => Map<String, dynamic>.from(e as Map)).toList() : <Map<String, dynamic>>[];

  void _toast(Map<String, dynamic> res) {
    final ok = res['success'] == true;
    Get.snackbar(
      ok ? "Done" : "Oops",
      '${res['message'] ?? (ok ? 'Saved' : 'Something went wrong')}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: ok ? const Color(0xFF252A27) : Colors.red.shade500,
      colorText: Colors.white,
      margin: const EdgeInsets.all(14),
      borderRadius: 14,
    );
  }
}
