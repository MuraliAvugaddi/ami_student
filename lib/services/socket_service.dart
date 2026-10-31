import 'package:ami_student/api/api_endpoint.dart';
import 'package:ami_student/Controllers/hostel_controller.dart';
import 'package:ami_student/services/fee_reminder_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:get_storage/get_storage.dart';

class SocketService {
  SocketService._internal();
  static final SocketService instance = SocketService._internal();
  factory SocketService() => instance;

  IO.Socket? _socket;
  final box = GetStorage();

  void connectAndListen() {
    if (_socket != null && _socket!.connected) return;

    final token = box.read('token');
    final Map<String, dynamic>? userData = box.read('user_data');
    final String? userId = userData?['user']?['_id'] ?? userData?['_id'];

    if (token == null || userId == null) return;

    _socket = IO.io(ApiEndpoints.socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'query': {'token': token},
    });

    _socket!.connect();

    _socket!.onConnect((_) => _socket!.emit('registerUser', userId));

    // ✅ AUTOMATIC REAL-TIME UPDATE LISTENER (Updated & Verified)
    _socket!.on('statusUpdated', (data) {
      if (data != null) {
        // Check if the update is meant for this logged-in student (or broadcasted globally)
        String? targetUserId = data['userId'];
        if (targetUserId == null || targetUserId == userId) {
          _syncStatusToStorage(data);
        }
      }
    });

    // ✅ Payment approved / cash received → notification + receipt instantly
    _socket!.on('paymentReceipt', (data) {
      if (_isMine(data, userId)) FeeReminderService.instance.onReceipt(data);
    });

    // ✅ Screenshot rejected → notification with reason
    _socket!.on('paymentReviewed', (data) {
      if (_isMine(data, userId)) FeeReminderService.instance.onRejected(data);
    });

    // ✅ Hostel: complaint updates, SOS "help is coming"
    _socket!.on('hostelNotification', (data) {
      if (data is! Map) return;
      if (Get.isRegistered<HostelController>()) {
        Get.find<HostelController>().onLiveUpdate(data);
      }
      FeeReminderService.instance.showHostel(
        '${data['title'] ?? 'Ami Hostlers'}',
        '${data['body'] ?? ''}',
        '${data['type'] ?? ''}' == 'complaint' ? 'complaint:${data['refId'] ?? ''}' : 'hostel',
      );
    });

    // Re-sync after the phone was offline (missed events)
    _socket!.onReconnect((_) {
      _socket!.emit('registerUser', userId);
      FeeReminderService.instance.sync();
      if (Get.isRegistered<HostelController>()) Get.find<HostelController>().loadAll();
    });
  }

  bool _isMine(dynamic data, String userId) =>
      data is Map && (data['userId'] == null || '${data['userId']}' == userId);

  void _syncStatusToStorage(dynamic data) {
    bool newStatus = data['isApproved'] ?? false;
    String? newExpiry = data['accessExpiresAt'];

    Map<String, dynamic>? storedData = box.read('user_data');
    if (storedData == null) return;

    // Update nested data structures safely
    if (storedData.containsKey('user')) {
      storedData['user']['isApproved'] = newStatus;
      storedData['user']['accessExpiresAt'] = newExpiry;
    } else {
      storedData['isApproved'] = newStatus;
      storedData['accessExpiresAt'] = newExpiry;
    }

    // ✅ This triggers any UI listening to 'user_data' across the WHOLE app
    box.write('user_data', storedData);

    // Show alert no matter what screen the user is on
    Get.snackbar(
      "Mess Status Updated",
      newStatus ? "Access Granted!" : "Access Revoked.",
      backgroundColor: newStatus ? Colors.green : Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }
} 