// =====================================================================
// MESS BILL REMINDERS + PAYMENT NOTIFICATIONS (no Firebase needed)
//
// • Unpaid students: 4 reminders a day (9:00, 13:00, 17:30, 20:30)
//   from the 1st of the month until they pay. After the 10th the
//   reminder shows the late fine (₹20 per day, grows every day).
// • Paid students: no reminders. Reminders start automatically the day
//   after their plan ends (monthly, 3-month or 6-month).
// • "Plan ends soon" notice 3 days and 1 day before expiry.
// • Payment approved / cash received → instant notification + receipt.
// • Screenshot rejected → notification with the reason.
//
// Reminders are planned on the phone for the next 7 days and re-planned
// every time the app opens, so they stop as soon as the payment is seen.
// =====================================================================
import 'dart:convert';

import 'package:ami_student/Controllers/profile_controller.dart';
import 'package:ami_student/Screens/pay_fees_screen.dart';
import 'package:ami_student/Screens/receipt_screen.dart';
import 'package:ami_student/Screens/hostel/complaint_details_screen.dart';
import 'package:ami_student/Screens/hostel/hostel_notifications_screen.dart';
import 'package:ami_student/services/payment_service.dart';
import 'package:ami_student/utils/fee_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class FeeReminderService with WidgetsBindingObserver {
  FeeReminderService._();
  static final FeeReminderService instance = FeeReminderService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  final PaymentService _api = PaymentService();
  final GetStorage _box = GetStorage();

  /// Screens listen to this and reload when a payment is approved / rejected.
  final RxInt changes = 0.obs;

  bool _ready = false;
  bool _syncing = false;

  static const int _firstReminderId = 1000; // ids 1000–1099 belong to reminders
  static const int _lastReminderId = 1099;
  static const int _horizonDays = 7;
  static const List<List<int>> _times = [
    [9, 0],
    [13, 0],
    [17, 30],
    [20, 30],
  ];

  static AndroidNotificationDetails _reminderAndroid(String body) => AndroidNotificationDetails(
        'mess_bill_reminders',
        'Mess bill reminders',
        channelDescription: 'Reminders to pay the mess bill and late fine alerts',
        importance: Importance.high,
        priority: Priority.high,
        styleInformation: BigTextStyleInformation(body),
      );

  static AndroidNotificationDetails _paymentAndroid(String body) => AndroidNotificationDetails(
        'mess_payments',
        'Mess payments',
        channelDescription: 'Payment approved, cash receipt and rejected screenshot alerts',
        importance: Importance.max,
        priority: Priority.high,
        styleInformation: BigTextStyleInformation(body),
      );

  // ------------------------------------------------------------------
  // SETUP
  // ------------------------------------------------------------------

  Future<void> init() async {
    if (_ready || kIsWeb) return;
    try {
      tzdata.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

      const settings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      );
      await _plugin.initialize(settings, onDidReceiveNotificationResponse: _onTap);

      await _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      await _plugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);

      WidgetsBinding.instance.addObserver(this);
      _ready = true;

      // App was opened by tapping a notification
      final launch = await _plugin.getNotificationAppLaunchDetails();
      if (launch?.didNotificationLaunchApp == true) {
        final payload = launch!.notificationResponse?.payload;
        Future.delayed(const Duration(milliseconds: 900), () => _openPayload(payload));
      }
    } catch (e) {
      debugPrint('FeeReminderService init failed: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) sync();
  }

  void _onTap(NotificationResponse response) => _openPayload(response.payload);

  void _openPayload(String? payload) {
    if (payload == null) return;
    if (payload == 'pay') {
      Get.to(() => const PayFeesScreen());
    } else if (payload.startsWith('receipt:')) {
      try {
        final r = Map<String, dynamic>.from(jsonDecode(payload.substring(8)));
        Get.to(() => ReceiptScreen(receipt: r));
      } catch (_) {
        Get.to(() => const ReceiptsListScreen());
      }
    } else if (payload == 'receipts') {
      Get.to(() => const ReceiptsListScreen());
    } else if (payload.startsWith('complaint:') && payload.length > 10) {
      Get.to(() => ComplaintDetailsScreen(complaintId: payload.substring(10)));
    } else if (payload == 'hostel') {
      Get.to(() => HostelNotificationsScreen());
    }
  }

  // ------------------------------------------------------------------
  // SYNC WITH SERVER (on app open / resume / after payment)
  // ------------------------------------------------------------------

  Future<Map<String, dynamic>?> sync() async {
    if (!_api.isLoggedIn || _syncing) return null;
    _syncing = true;
    try {
      final status = await _api.getStatus();
      if (status['success'] != true) return null;

      if (_ready) await _planReminders(status);

      // A receipt we have not shown yet (e.g. admin approved while the app was closed)
      final last = status['lastReceipt'];
      if (last is Map) {
        final receipt = Map<String, dynamic>.from(last);
        final id = '${receipt['_id'] ?? receipt['receiptNo']}';
        final seen = _box.read('last_seen_receipt');
        final created = DateTime.tryParse('${receipt['createdAt'] ?? ''}');
        final recent = created != null && DateTime.now().difference(created).inDays < 3;
        if (seen != id) {
          _box.write('last_seen_receipt', id);
          if (seen != null || recent) await _announceReceipt(receipt, popup: true);
        }
      }
      return status;
    } catch (e) {
      debugPrint('Fee sync failed: $e');
      return null;
    } finally {
      _syncing = false;
    }
  }

  // ------------------------------------------------------------------
  // SOCKET EVENTS (called from SocketService)
  // ------------------------------------------------------------------

  /// Admin approved a screenshot or recorded cash.
  Future<void> onReceipt(dynamic data) async {
    if (data is! Map || data['receipt'] is! Map) return;
    final receipt = Map<String, dynamic>.from(data['receipt']);
    _box.write('last_seen_receipt', '${receipt['_id'] ?? receipt['receiptNo']}');
    await _announceReceipt(receipt, popup: true);
    await _refreshProfile();
    await sync();
  }

  /// Admin rejected a screenshot.
  Future<void> onRejected(dynamic data) async {
    if (data is! Map || data['status'] != 'rejected') return;
    final reason = (data['reason'] ?? 'Please upload the correct screenshot.').toString();
    final months = List<String>.from(data['months'] ?? const []);
    await _show(
      2002,
      'Payment screenshot rejected',
      '${months.isNotEmpty ? '${shortRange(months)}: ' : ''}$reason\nTap to upload again.',
      payload: 'pay',
    );
    changes.value++;
    Get.snackbar(
      'Screenshot rejected',
      reason,
      snackPosition: SnackPosition.TOP,
      backgroundColor: FeeColors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 6),
      margin: const EdgeInsets.all(12),
    );
  }

  Future<void> _announceReceipt(Map<String, dynamic> r, {bool popup = false}) async {
    final months = List<String>.from(r['months'] ?? const []);
    final isCash = r['mode'] == 'cash';
    final total = (r['totalAmount'] ?? 0) as num;
    final utr = (r['utr'] ?? '').toString();
    final paidAt = fmtDate(r['paidAt'], pattern: 'd MMM, h:mm a');

    await _show(
      2001,
      isCash ? 'Cash payment received ✅' : 'Payment approved ✅',
      '₹${fmtMoney(total)} for ${shortRange(months)}'
          '${isCash ? ' paid in cash' : ''}${utr.isNotEmpty ? ' · UTR $utr' : ''}'
          '${paidAt.isNotEmpty ? ' · $paidAt' : ''}\n'
          'Receipt ${r['receiptNo'] ?? ''} · Mess access till ${fmtDate(r['accessTill'])}',
      payload: 'receipt:${jsonEncode(_slim(r))}',
    );
    changes.value++;

    if (popup && Get.context != null) {
      Get.to(() => ReceiptScreen(receipt: r, justPaid: true));
    }
  }

  Map<String, dynamic> _slim(Map<String, dynamic> r) => {
        for (final k in [
          '_id', 'receiptNo', 'studentName', 'enrollmentNo', 'room', 'mode', 'planMonths', 'months',
          'planAmount', 'fine', 'totalAmount', 'utr', 'note', 'paidAt', 'accessTill', 'createdAt',
        ])
          if (r[k] != null) k: r[k],
      };

  Future<void> _refreshProfile() async {
    try {
      if (Get.isRegistered<ProfileController>()) {
        await Get.find<ProfileController>().fetchUserProfile(showLoading: false);
      }
    } catch (_) {}
  }

  // ------------------------------------------------------------------
  // PLAN THE NEXT 7 DAYS OF REMINDERS
  // ------------------------------------------------------------------

  Future<void> _planReminders(Map<String, dynamic> s) async {
    for (var id = _firstReminderId; id <= _lastReminderId; id++) {
      await _plugin.cancel(id);
    }

    final state = (s['state'] ?? '').toString();
    if (state == 'pending') return; // waiting for admin — don't nag

    final fineAfter = asInt(s['fineAfterDay'], 10);
    final perDay = asInt(s['finePerDay'], 20);
    final monthlyFee = asInt(s['monthlyFee'], 4000);
    final lastPlan = asInt(s['lastPlanMonths'], 1);
    final now = tz.TZDateTime.now(tz.local);
    final horizon = now.add(const Duration(days: _horizonDays));
    var id = _firstReminderId;

    tz.TZDateTime startDay;
    if (state == 'due' || state == 'late') {
      startDay = tz.TZDateTime(tz.local, now.year, now.month, now.day);
    } else {
      final expiry = DateTime.tryParse('${s['accessExpiresAt'] ?? ''}');
      if (expiry == null) return;
      final e = tz.TZDateTime.from(expiry, tz.local);

      // "Plan ends soon" — 3 days and 1 day before
      for (final before in [3, 1]) {
        final d = e.subtract(Duration(days: before));
        final when = tz.TZDateTime(tz.local, d.year, d.month, d.day, 10, 0);
        if (when.isAfter(now) && when.isBefore(horizon)) {
          await _schedule(
            id++,
            when,
            'Your mess plan ends ${before == 1 ? 'tomorrow' : 'in $before days'}',
            'Valid till ${DateFormat('d MMM').format(e)}. Pay for next month before the '
                '${ordinal(fineAfter)} to avoid the ₹$perDay/day late fine.',
          );
        }
      }
      final next = e.add(const Duration(days: 1));
      startDay = tz.TZDateTime(tz.local, next.year, next.month, next.day);
    }

    var first = true;
    for (var d = 0; d <= _horizonDays && id <= _lastReminderId; d++) {
      final base = startDay.add(Duration(days: d));
      final day = tz.TZDateTime(tz.local, base.year, base.month, base.day);
      if (day.isAfter(horizon)) break;
      final dom = day.day;
      final month = DateFormat('MMMM').format(day);
      final fine = dom > fineAfter ? (dom - fineAfter) * perDay : 0;

      for (final t in _times) {
        final when = tz.TZDateTime(tz.local, day.year, day.month, day.day, t[0], t[1]);
        if (!when.isAfter(now) || when.isAfter(horizon) || id > _lastReminderId) continue;

        String title;
        String body;
        if (first && state != 'due' && state != 'late') {
          title = lastPlan > 1 ? 'Your $lastPlan-month mess plan has ended' : 'Your mess plan has ended';
          body = 'Pay your $month mess bill (₹${fmtMoney(monthlyFee)}) to keep your meal access. '
              'Pay before the ${ordinal(fineAfter)} to avoid the late fine.';
        } else if (fine == 0) {
          final daysLeft = fineAfter - dom;
          title = daysLeft == 0 ? 'Last day to pay without fine!' : 'Pay your $month mess bill';
          body = '₹${fmtMoney(monthlyFee)} is due. '
              '${daysLeft == 0 ? 'From tomorrow ₹$perDay/day late fine is added.' : 'Pay before the ${ordinal(fineAfter + 1)} — after that ₹$perDay/day late fine.'}';
        } else {
          title = 'Late fine today: ₹${fmtMoney(fine)}';
          body = 'Your $month mess bill is unpaid. Pay ₹${fmtMoney(monthlyFee + fine)} now — '
              'the fine grows ₹$perDay every day.';
        }
        body += '\nAlready paid? Open the app to update.';

        await _schedule(id++, when, title, body);
        first = false;
      }
    }
  }

  Future<void> _schedule(int id, tz.TZDateTime when, String title, String body) async {
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        when,
        NotificationDetails(
          android: _reminderAndroid(body),
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: 'pay',
      );
    } catch (e) {
      debugPrint('Schedule reminder failed: $e');
    }
  }

  Future<void> _show(int id, String title, String body, {String? payload}) async {
    if (!_ready) return;
    try {
      await _plugin.show(
        id,
        title,
        body,
        NotificationDetails(android: _paymentAndroid(body), iOS: const DarwinNotificationDetails()),
        payload: payload,
      );
    } catch (e) {
      debugPrint('Show notification failed: $e');
    }
  }

  /// Hostel update (complaint accepted / repaired, SOS help coming)
  Future<void> showHostel(String title, String body, String payload) async {
    if (!_ready) return;
    try {
      await _plugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000 % 100000,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'hostel_updates',
            'Hostel updates',
            channelDescription: 'Room complaint updates and SOS replies',
            importance: Importance.max,
            priority: Priority.high,
            styleInformation: BigTextStyleInformation(body),
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: payload,
      );
    } catch (e) {
      debugPrint('Hostel notification failed: $e');
    }
  }

  /// Call on logout so the next student on this phone doesn't get reminders.
  Future<void> clearAll() async {
    if (!_ready) return;
    await _plugin.cancelAll();
    _box.remove('last_seen_receipt');
  }
}
