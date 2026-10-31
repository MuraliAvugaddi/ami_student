// =====================================================================
// MESS PLAN (Subscription tab)
// One glance: Am I active? Till when? Do I owe a fine? → one tap to pay.
// Updates by itself when the admin approves (socket + auto-check).
// =====================================================================
import 'dart:async';

import 'package:ami_student/Controllers/profile_controller.dart';
import 'package:ami_student/Screens/pay_fees_screen.dart';
import 'package:ami_student/Screens/receipt_screen.dart';
import 'package:ami_student/services/fee_reminder_service.dart';
import 'package:ami_student/services/payment_service.dart';
import 'package:ami_student/utils/fee_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final ProfileController controller = Get.find<ProfileController>();
  final PaymentService _api = PaymentService();

  bool _loading = true;
  Map<String, dynamic> _config = {};
  List<Map<String, dynamic>> _receipts = [];
  Timer? _poll;
  Worker? _changesWorker;

  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  String get _bannerAdUnitId => defaultTargetPlatform == TargetPlatform.android
      ? 'ca-app-pub-6236176751859838/9488589732'
      : 'ca-app-pub-3940256099942544/2934735716';

  Map<String, dynamic> get _fee => Map<String, dynamic>.from(_config['fee'] ?? const {});
  String get _state => (_fee['state'] ?? (controller.isSubscriptionActive ? 'active' : 'due')).toString();
  List<Map<String, dynamic>> get _plans =>
      List<Map<String, dynamic>>.from((_config['plans'] ?? const []).map((e) => Map<String, dynamic>.from(e)));
  List<Map<String, dynamic>> get _submissions =>
      List<Map<String, dynamic>>.from((_config['submissions'] ?? const []).map((e) => Map<String, dynamic>.from(e)));

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
    _load();
    // Reload instantly when a payment is approved / rejected (socket)
    _changesWorker = ever(FeeReminderService.instance.changes, (_) => _load(silent: true));
  }

  @override
  void dispose() {
    _poll?.cancel();
    _changesWorker?.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent && mounted) setState(() => _loading = _config.isEmpty);
    final results = await Future.wait([_api.getConfig(), _api.getReceiptList()]);
    if (!mounted) return;
    final wasPending = _state == 'pending';
    setState(() {
      if (results[0]['success'] == true) _config = results[0];
      if (results[1]['success'] == true) {
        _receipts = List<Map<String, dynamic>>.from(
            (results[1]['receipts'] ?? const []).map((e) => Map<String, dynamic>.from(e)));
      }
      _loading = false;
    });

    // Waiting for admin → check every 15 s so approval shows without refreshing
    _poll?.cancel();
    if (_state == 'pending') {
      _poll = Timer.periodic(const Duration(seconds: 15), (_) => _load(silent: true));
    } else if (wasPending) {
      controller.fetchUserProfile(showLoading: false);
      FeeReminderService.instance.sync();
    }
  }

  Future<void> _pay({int planMonths = 1}) async {
    final submitted = await openPayFeesScreen(planMonths: planMonths);
    if (submitted) {
      await _load(silent: true);
      FeeReminderService.instance.sync();
    }
  }

  void _loadBannerAd() {
    if (kIsWeb) return;
    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) setState(() => _isBannerAdLoaded = true);
        },
        onAdFailedToLoad: (ad, error) => ad.dispose(),
      ),
    )..load();
  }

  // ------------------------------------------------------------------
  // UI
  // ------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FeeColors.bg,
      appBar: AppBar(
        toolbarHeight: 64,
        backgroundColor: FeeColors.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: FeeColors.text),
        title: Text('Mess Plan',
            style: GoogleFonts.poppins(color: FeeColors.text, fontSize: 21, fontWeight: FontWeight.w800)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Material(
              color: FeeColors.primaryLight,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => Get.to(() => const ReceiptsListScreen()),
                child: const SizedBox(
                  height: 44,
                  width: 44,
                  child: Icon(Icons.receipt_long_rounded, color: FeeColors.primaryDark, size: 21),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: FeeColors.primaryDark))
                : RefreshIndicator(
                    color: FeeColors.primaryDark,
                    onRefresh: () async {
                      await Future.wait([_load(silent: true), controller.fetchUserProfile(showLoading: false)]);
                    },
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      children: [
                        _hero(),
                        const SizedBox(height: 12),
                        if (_lastRejected() != null) ...[
                          _rejectedCard(_lastRejected()!),
                          const SizedBox(height: 12),
                        ],
                        _sectionTitle('Choose a plan'),
                        const SizedBox(height: 8),
                        _plansRow(),
                        const SizedBox(height: 14),
                        _mainButton(),
                        const SizedBox(height: 20),
                        if (_receipts.isNotEmpty) ...[
                          Row(
                            children: [
                              _sectionTitle('Receipts'),
                              const Spacer(),
                              TextButton(
                                onPressed: () => Get.to(() => const ReceiptsListScreen()),
                                child: Text('View all',
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w700, color: FeeColors.primaryDark)),
                              ),
                            ],
                          ),
                          ..._receipts.take(3).map((r) => ReceiptTile(receipt: r)),
                          const SizedBox(height: 10),
                        ],
                        _fineNote(),
                      ],
                    ),
                  ),
          ),
          if (!kIsWeb)
            SizedBox(
              height: 50,
              width: double.infinity,
              child: _isBannerAdLoaded && _bannerAd != null ? AdWidget(ad: _bannerAd!) : const SizedBox(),
            ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) =>
      Text(t, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w800, color: FeeColors.text));

  // ---------- Big status card (same style as Home header) ----------
  Widget _hero() {
    final state = _state;
    final expiry = _fee['accessExpiresAt'] ?? controller.user.value.accessExpiresAt?.toIso8601String();
    final daysLeft = asInt(_fee['daysLeft']);
    final fine = asInt(_fee['fine']);
    final monthly = asInt(_fee['monthlyFee'], 4000);
    final fineAfter = asInt(_fee['fineAfterDay'], 10);
    final perDay = asInt(_fee['finePerDay'], 20);
    final month = (_fee['currentMonth'] ?? '').toString();
    final lastPlan = asInt(_fee['lastPlanMonths'], 1);

    late Color pillFg, pillBg;
    late IconData pillIcon;
    late String pill, big, sub;
    Color bigColor = FeeColors.text;
    Widget? extra;

    switch (state) {
      case 'active':
      case 'expiring':
        final ending = state == 'expiring';
        pillFg = ending ? FeeColors.amber : FeeColors.green;
        pillBg = ending ? FeeColors.amberLight : FeeColors.greenLight;
        pillIcon = ending ? Icons.timelapse_rounded : Icons.check_circle_rounded;
        pill = ending ? 'Plan ending soon' : 'Mess subscription active';
        big = daysLeft == 1 ? '1 day left' : '$daysLeft days left';
        sub = 'Valid till ${fmtDate(expiry)}${lastPlan > 1 ? ' · ${planName(lastPlan)}' : ''}';
        final total = lastPlan * 30;
        extra = ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: (daysLeft / (total < 1 ? 1 : total)).clamp(0.0, 1.0).toDouble(),
            minHeight: 7,
            backgroundColor: Colors.white.withOpacity(0.65),
            color: ending ? FeeColors.amber : FeeColors.green,
          ),
        );
        break;
      case 'pending':
        pillFg = FeeColors.primaryDark;
        pillBg = Colors.white.withOpacity(0.7);
        pillIcon = Icons.hourglass_top_rounded;
        pill = 'Payment under review';
        big = 'Almost done!';
        sub = "The mess office is checking your payment. We'll notify you the moment it is approved.";
        extra = Row(
          children: [
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 2, color: FeeColors.text),
            ),
            const SizedBox(width: 8),
            Text('Checking automatically…',
                style: GoogleFonts.poppins(fontSize: 11.5, color: FeeColors.text, fontWeight: FontWeight.w600)),
          ],
        );
        break;
      case 'late':
        pillFg = FeeColors.red;
        pillBg = FeeColors.redLight;
        pillIcon = Icons.error_outline_rounded;
        pill = '$month unpaid';
        big = 'Late fine ₹${fmtMoney(fine)}';
        bigColor = FeeColors.red;
        sub = '₹$perDay is added every day after the ${ordinal(fineAfter)}. '
            'Pay ₹${fmtMoney(monthly + fine)} today to stop it growing.';
        break;
      default: // due
        pillFg = FeeColors.red;
        pillBg = FeeColors.redLight;
        pillIcon = Icons.notifications_active_rounded;
        pill = 'Subscription expired';
        big = '₹${fmtMoney(monthly)} due';
        final left = fineAfter - DateTime.now().day;
        sub = left <= 0
            ? 'Today is the last day without fine. From tomorrow ₹$perDay/day.'
            : 'Pay for $month before the ${ordinal(fineAfter + 1)} to avoid the ₹$perDay/day late fine.';
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        gradient: FeeColors.headerGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: FeeColors.primary.withOpacity(0.28), blurRadius: 24, offset: const Offset(0, 9)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: pillBg, borderRadius: BorderRadius.circular(30)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(pillIcon, color: pillFg, size: 16),
                const SizedBox(width: 6),
                Text(pill, style: GoogleFonts.poppins(color: pillFg, fontSize: 11, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(big, style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w800, color: bigColor)),
          const SizedBox(height: 2),
          Text(sub, style: GoogleFonts.poppins(fontSize: 12.5, color: FeeColors.text.withOpacity(0.75), height: 1.45)),
          if (extra != null) ...[const SizedBox(height: 12), extra],
        ],
      ),
    );
  }

  // ---------- Rejected screenshot ----------
  Map<String, dynamic>? _lastRejected() {
    if (_submissions.isEmpty) return null;
    final latest = _submissions.first;
    if (latest['status'] != 'rejected') return null;
    final created = DateTime.tryParse('${latest['createdAt'] ?? ''}');
    if (created == null || DateTime.now().difference(created).inDays > 7) return null;
    if (_state == 'active' || _state == 'expiring' || _state == 'pending') return null;
    return latest;
  }

  Widget _rejectedCard(Map<String, dynamic> s) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: FeeColors.redLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: FeeColors.red.withOpacity(0.25)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.cancel_rounded, color: FeeColors.red),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Last screenshot was rejected',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: FeeColors.red, fontSize: 13.5)),
                  Text('${s['rejectReason'] ?? ''}',
                      style: GoogleFonts.poppins(fontSize: 12, color: FeeColors.text, height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      );

  // ---------- Main button ----------
  Widget _mainButton() {
    final state = _state;
    if (state == 'pending') return const SizedBox.shrink();
    final active = state == 'active' || state == 'expiring';
    final first = _plans.isNotEmpty ? _plans.first : <String, dynamic>{};
    final total = asInt(first['total'] ?? first['amount'], 4000);

    return SizedBox(
      height: 56,
      child: active
          ? OutlinedButton.icon(
              onPressed: () => _pay(),
              icon: const Icon(Icons.event_repeat_rounded),
              label: Text('Pay next month in advance',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14.5)),
              style: OutlinedButton.styleFrom(
                foregroundColor: FeeColors.text,
                side: const BorderSide(color: FeeColors.primaryDark, width: 1.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
            )
          : ElevatedButton(
              onPressed: () => _pay(),
              style: ElevatedButton.styleFrom(
                backgroundColor: FeeColors.primary,
                foregroundColor: FeeColors.text,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Pay ₹${fmtMoney(total)} now',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
            ),
    );
  }

  // ---------- Plans: all 3 side by side, always visible ----------
  Widget _plansRow() {
    final locked = _state == 'pending';
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < _plans.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(child: _planBox(_plans[i], locked: locked)),
          ],
        ],
      ),
    );
  }

  Widget _planBox(Map<String, dynamic> p, {bool locked = false}) {
    final months = asInt(p['months'], 1);
    final amount = asInt(p['amount']);
    final save = asInt(p['fullPrice']) - amount;
    final best = months == 6;
    return Material(
      color: best ? FeeColors.primaryLight : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: locked && months == 1 ? null : () => _pay(planMonths: months),
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: best ? FeeColors.primaryDark : FeeColors.border, width: best ? 1.5 : 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(planName(months),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 12.5, height: 1.2)),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text('₹${fmtMoney(amount)}',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w800, fontSize: 17)),
              ),
              const SizedBox(height: 2),
              Text(
                save > 0 ? 'Save ₹${fmtMoney(save)}' : (months == 1 ? 'per month' : '$months months'),
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: save > 0 ? FeeColors.green : FeeColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fineNote() {
    final fineAfter = asInt(_fee['fineAfterDay'], 10);
    final perDay = asInt(_fee['finePerDay'], 20);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, size: 18, color: FeeColors.muted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Pay by the ${ordinal(fineAfter)} of every month. After that a late fine of ₹$perDay per day is added. '
              'Paying in cash? Pay at the mess office — your receipt appears here automatically.',
              style: GoogleFonts.poppins(fontSize: 11.5, color: FeeColors.muted, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}