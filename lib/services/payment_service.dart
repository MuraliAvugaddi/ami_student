// =====================================================================
// Mess-fee payment API (UPI QR + screenshot upload, receipts, fee status)
// =====================================================================
import 'dart:convert';
import 'package:ami_student/api/api_endpoint.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class PaymentService {
  final _box = GetStorage();

  // New URLs are built from baseUrl, so api_endpoint.dart does not need changes
  static String get _statusUrl => '${ApiEndpoints.baseUrl}/payments/status';
  static String get _receiptListUrl => '${ApiEndpoints.baseUrl}/payments/receipts';

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_box.read('token') ?? ''}',
      };

  bool get isLoggedIn => _box.read('token') != null;

  Map<String, dynamic> _decode(http.Response res) {
    try {
      final data = jsonDecode(res.body);
      if (data is Map<String, dynamic>) {
        data['statusCode'] = res.statusCode;
        return data;
      }
    } catch (_) {}
    return {
      'success': false,
      'statusCode': res.statusCode,
      'message': 'Server error (${res.statusCode}). Please try again.',
    };
  }

  Future<Map<String, dynamic>> _get(String url, {int seconds = 40}) async {
    try {
      final res = await http.get(Uri.parse(url), headers: _headers).timeout(Duration(seconds: seconds));
      return _decode(res);
    } catch (_) {
      return {'success': false, 'message': 'No internet connection. Please try again.'};
    }
  }

  /// Plans, UPI id, fine, paid months and my recent submissions.
  Future<Map<String, dynamic>> getConfig() => _get(ApiEndpoints.paymentConfig);

  /// Paid / due / late + fine — used for reminders.
  Future<Map<String, dynamic>> getStatus() => _get(_statusUrl, seconds: 30);

  /// Receipts (UPI + cash) with receipt numbers.
  Future<Map<String, dynamic>> getReceiptList() => _get(_receiptListUrl);

  /// Older month-wise payments (before receipts existed).
  Future<Map<String, dynamic>> getMyReceipts() => _get(ApiEndpoints.paymentReceipts);

  Future<Map<String, dynamic>> submitScreenshot({
    required int planMonths,
    required String startMonth,
    required String utr,
    required String imageBase64,
    required Map<String, dynamic> detected,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse(ApiEndpoints.paymentSubmit),
            headers: _headers,
            body: jsonEncode({
              'planMonths': planMonths,
              'startMonth': startMonth,
              'utr': utr,
              'imageBase64': imageBase64,
              'detected': detected,
            }),
          )
          .timeout(const Duration(seconds: 90));
      return _decode(res);
    } catch (_) {
      return {
        'success': false,
        'message': 'Upload failed. Check your internet and try again.',
      };
    }
  }
}
