// =====================================================================
// PAY MESS FEE — 2 simple steps:
//   1. Pay by UPI (one tap opens PhonePe / GPay / Paytm with the amount)
//   2. Upload the success screenshot → UTR, amount, date read automatically
// Late fine (after the 10th) is added automatically by the server.
// =====================================================================
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:ami_student/services/payment_service.dart';
import 'package:ami_student/utils/fee_ui.dart';
import 'package:ami_student/utils/payment_ocr.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gal/gal.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class PayFeesScreen extends StatefulWidget {
  /// 1, 3 or 6 — plan to select when the screen opens
  final int initialPlanMonths;
  const PayFeesScreen({super.key, this.initialPlanMonths = 1});

  @override
  State<PayFeesScreen> createState() => _PayFeesScreenState();
}

class _PayFeesScreenState extends State<PayFeesScreen> {
  final PaymentService _service = PaymentService();
  final TextEditingController _utrController = TextEditingController();

  bool _loading = true;
  String? _error;
  Map<String, dynamic> _config = {};
  int _selectedPlan = 0;
  bool _showQr = false;
  bool _openedUpi = false;
  bool _savingQr = false;

  Uint8List? _imageBytes;
  bool _scanning = false;
  PaymentScanResult _scan = PaymentScanResult.empty;
  bool _submitting = false;

  // ------------------------------------------------------------------
  // DATA
  // ------------------------------------------------------------------

  List<Map<String, dynamic>> get _plans =>
      List<Map<String, dynamic>>.from((_config['plans'] ?? const []).map((e) => Map<String, dynamic>.from(e)));

  Map<String, dynamic>? get _plan =>
      _plans.isEmpty ? null : _plans[_selectedPlan < _plans.length ? _selectedPlan : 0];

  double get _planAmount => ((_plan?['amount'] ?? 0) as num).toDouble();
  double get _fine => ((_plan?['fine'] ?? _config['fine'] ?? 0) as num).toDouble();
  double get _total => _planAmount + _fine;

  List<String> get _planMonths => List<String>.from(_plan?['monthLabels'] ?? const []);
  List<String> get _pendingMonths => List<String>.from(_config['pendingMonths'] ?? const []);
  Map<String, dynamic> get _fee => Map<String, dynamic>.from(_config['fee'] ?? const {});

  String get _upiId => (_config['upiId'] ?? '').toString();
  String get _payee => (_config['payeeName'] ?? '').toString();

  /// Official QR image (from Vyapar / bank) if the admin set PAYMENT_QR_IMAGE_URL — most reliable.
  String get _officialQrUrl => (_config['qrImageUrl'] ?? '').toString();

  /// Plain merchant QR (no amount) — same as the printed QR at the mess counter.
  String get _plainQrData =>
      'upi://pay?pa=${_upiId.trim()}&pn=${Uri.encodeComponent(_payee)}&cu=INR';

  String get _upiLink {
    final note = 'Mess fee ${shortRange(_planMonths)}';
    // Built by hand: some UPI apps read "+" literally, so spaces must be %20
    String enc(String v) => Uri.encodeComponent(v);
    return 'upi://pay?pa=${_upiId.trim()}&pn=${enc(_payee)}'
        '&am=${_total.toStringAsFixed(2)}&cu=INR&tn=${enc(note)}';
  }

  bool get _utrValid => RegExp(r'^\d{12}$').hasMatch(_utrController.text.trim());
  bool get _canSubmit => _imageBytes != null && _utrValid && !_scanning && !_submitting;

  @override
  void initState() {
    super.initState();
    _utrController.addListener(() => setState(() {}));
    _load();
  }

  @override
  void dispose() {
    _utrController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final res = await _service.getConfig();
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (res['success'] == true) {
        _config = res;
        final i = _plans.indexWhere((p) => asInt(p['months']) == widget.initialPlanMonths);
        _selectedPlan = i < 0 ? 0 : i;
      } else {
        _error = res['message']?.toString() ?? 'Could not load payment details.';
      }
    });
  }

  // ------------------------------------------------------------------
  // ACTIONS
  // ------------------------------------------------------------------

  /// [scheme]: null = Android shows all UPI apps; or 'phonepe' / 'tez' (GPay) / 'paytmmp'
  Future<void> _openUpiApp([String? scheme]) async {
    var link = _upiLink;
    if (scheme == 'tez') link = link.replaceFirst('upi://', 'tez://upi/');
    if (scheme == 'phonepe' || scheme == 'paytmmp') link = link.replaceFirst('upi://', '$scheme://');
    final uri = Uri.parse(link);
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalNonBrowserApplication);
      if (!ok) throw Exception('no app');
      setState(() => _openedUpi = true);
    } catch (_) {
      setState(() => _showQr = true);
      _toast('App not found', 'Try another app, or use "Save QR" / "Copy UPI ID" below.', error: true);
    }
  }

  /// Saves the QR to the gallery → student opens GPay / PhonePe → Scan → picks it from gallery.
  Future<void> _saveQrToGallery() async {
    setState(() => _savingQr = true);
    try {
      Uint8List bytes;
      if (_officialQrUrl.isNotEmpty) {
        final res = await http.get(Uri.parse(_officialQrUrl));
        if (res.statusCode != 200) throw Exception('download failed');
        bytes = res.bodyBytes;
      } else {
        // White background + margin so every UPI app can read it
        const size = 1000.0;
        const margin = 90.0;
        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder);
        canvas.drawRect(const Rect.fromLTWH(0, 0, size, size), Paint()..color = Colors.white);
        canvas.translate(margin, margin);
        QrPainter(data: _plainQrData, version: QrVersions.auto, gapless: true)
            .paint(canvas, const Size(size - 2 * margin, size - 2 * margin));
        final image = await recorder.endRecording().toImage(size.toInt(), size.toInt());
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        bytes = data!.buffer.asUint8List();
      }
      if (!await Gal.hasAccess()) await Gal.requestAccess();
      await Gal.putImageBytes(bytes, name: 'ami_mess_fee_qr_${DateTime.now().millisecondsSinceEpoch}');
      _toast('QR saved to gallery ✓',
          'Open GPay / PhonePe / Paytm → Scan QR → tap the gallery icon → choose this QR → pay ₹${fmtMoney(_total)}.',
          long: true);
      setState(() => _openedUpi = true);
    } catch (e) {
      _toast('Could not save QR', 'Use "Copy UPI ID" instead, or scan the QR at the mess counter.', error: true);
    } finally {
      if (mounted) setState(() => _savingQr = false);
    }
  }

  void _copyUpiId() {
    Clipboard.setData(ClipboardData(text: _upiId));
    _toast('UPI ID copied ✓',
        'Open your UPI app → "Pay UPI ID / number" → paste → enter ₹${fmtMoney(_total)}.',
        long: true);
    setState(() => _openedUpi = true);
  }

  Future<void> _pickScreenshot() async {
    try {
      final XFile? file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
        maxWidth: 1600,
      );
      if (file == null) return;

      final bytes = await file.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _scanning = true;
        _scan = PaymentScanResult.empty;
      });

      final result = await PaymentOcr.scan(
        file.path,
        expectedAmount: _total,
        payeeKeyword: (_config['payeeKeyword'] ?? 'AMI HOSTLERS').toString(),
        upiId: _upiId,
      );

      if (!mounted) return;
      setState(() {
        _scan = result;
        _scanning = false;
        if (result.utr != null) _utrController.text = result.utr!;
      });
    } catch (e) {
      setState(() => _scanning = false);
      _toast('Could not open image', 'Please try again.', error: true);
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_canSubmit) return;

    final problems = _problems();
    if (problems.isNotEmpty) {
      final go = await Get.dialog<bool>(
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Please check', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 17)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...problems.map((p) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.error_outline_rounded, color: FeeColors.amber, size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text(p, style: GoogleFonts.poppins(fontSize: 13, height: 1.4))),
                      ],
                    ),
                  )),
              Text('Every payment is matched with the bank. Wrong screenshots are rejected.',
                  style: GoogleFonts.poppins(fontSize: 12, color: FeeColors.muted)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('Change screenshot', style: GoogleFonts.poppins(color: FeeColors.muted)),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                  backgroundColor: FeeColors.primary, foregroundColor: FeeColors.text, elevation: 0),
              child: Text('Submit anyway', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
      if (go != true) return;
    }

    setState(() => _submitting = true);
    final res = await _service.submitScreenshot(
      planMonths: asInt(_plan?['months'], 1),
      startMonth: _planMonths.isNotEmpty ? _planMonths.first : '',
      utr: _utrController.text.trim(),
      imageBase64: base64Encode(_imageBytes!),
      detected: _scan.toJson(),
    );
    if (!mounted) return;
    setState(() => _submitting = false);

    if (res['success'] == true) {
      await _showSubmittedDialog();
      Get.back(result: true);
    } else {
      _toast(
        res['code'] == 'DUPLICATE_UTR' ? 'UTR already used' : 'Not submitted',
        res['message']?.toString() ?? 'Please try again.',
        error: true,
        long: true,
      );
    }
  }

  List<String> _problems() {
    if (kIsWeb || _scan.rawText.isEmpty) return const [];
    final list = <String>[];
    if (_scan.amount == null) {
      list.add('We could not read the amount. Make sure ₹${fmtMoney(_total)} is visible.');
    } else if (_scan.amount!.round() < _total.round()) {
      list.add('Screenshot shows ₹${fmtMoney(_scan.amount!)} but you need to pay ₹${fmtMoney(_total)}.');
    }
    if (!_scan.payeeMatched) list.add('Payment does not look like it was made to $_payee.');
    if (_scan.paidOn != null) {
      final days = DateTime.now().difference(_scan.paidOn!).inDays;
      final maxDays = asInt(_config['maxScreenshotAgeDays'], 3);
      if (days > maxDays) list.add('Screenshot is $days days old. Please upload your latest payment.');
    }
    if (_scan.utr != null && _scan.utr != _utrController.text.trim()) {
      list.add('The UTR you typed is different from the one in the screenshot.');
    }
    return list;
  }

  Future<void> _showSubmittedDialog() => Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(color: FeeColors.blueLight, shape: BoxShape.circle),
                  child: const Icon(Icons.hourglass_top_rounded, color: FeeColors.blue, size: 32),
                ),
                const SizedBox(height: 16),
                Text('Submitted!', style: GoogleFonts.poppins(fontSize: 19, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(
                  "We'll notify you the moment the mess office approves it. You'll get your receipt in the app.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 13, color: FeeColors.muted, height: 1.5),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: FeeColors.primary,
                      foregroundColor: FeeColors.text,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text('OK', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  void _toast(String title, String msg, {bool error = false, bool long = false}) {
    Get.snackbar(
      title,
      msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: error ? FeeColors.red : FeeColors.text,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 14,
      duration: Duration(seconds: long ? 6 : 3),
    );
  }

  // ------------------------------------------------------------------
  // UI
  // ------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FeeColors.bg,
      appBar: AppBar(
        backgroundColor: FeeColors.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: FeeColors.text),
        title: Text('Pay Mess Fee',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 18, color: FeeColors.text)),
      ),
      bottomNavigationBar: _loading || _error != null ? null : _bottomBar(),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: FeeColors.primaryDark))
          : _error != null
              ? _errorView()
              : RefreshIndicator(
                  color: FeeColors.primaryDark,
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    children: [
                      if (_pendingMonths.isNotEmpty) ...[
                        _infoBanner(
                          Icons.hourglass_top_rounded,
                          'Your payment for ${shortRange(_pendingMonths)} is under review. '
                              'You are now paying in advance.',
                          FeeColors.blue,
                          FeeColors.blueLight,
                        ),
                        const SizedBox(height: 12),
                      ],
                      _planSelector(),
                      const SizedBox(height: 12),
                      _amountCard(),
                      const SizedBox(height: 16),
                      _stepCard(
                        n: 1,
                        title: 'Pay ₹${fmtMoney(_total)}',
                        done: _openedUpi,
                        child: _payStep(),
                      ),
                      const SizedBox(height: 12),
                      _stepCard(
                        n: 2,
                        title: 'Upload payment screenshot',
                        done: _imageBytes != null && _utrValid,
                        child: _uploadStep(),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _errorView() => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 48, color: FeeColors.muted),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center, style: GoogleFonts.poppins(color: FeeColors.muted)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _load,
                style: ElevatedButton.styleFrom(
                    backgroundColor: FeeColors.primary, foregroundColor: FeeColors.text, elevation: 0),
                child: Text('Try again', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      );

  Widget _infoBanner(IconData icon, String text, Color fg, Color bg) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
        child: Row(
          children: [
            Icon(icon, color: fg, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(text,
                  style: GoogleFonts.poppins(fontSize: 12.5, color: fg, fontWeight: FontWeight.w600, height: 1.4)),
            ),
          ],
        ),
      );

  // ---------- Plan chips ----------
  Widget _planSelector() {
    return Row(
      children: List.generate(_plans.length, (i) {
        final p = _plans[i];
        final selected = i == _selectedPlan;
        final months = asInt(p['months'], 1);
        final save = asInt(p['fullPrice']) - asInt(p['amount']);
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == _plans.length - 1 ? 0 : 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => setState(() => _selectedPlan = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                decoration: BoxDecoration(
                  color: selected ? FeeColors.primaryLight : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selected ? FeeColors.primaryDark : FeeColors.border,
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(planName(months),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w700)),
                    Text('₹${fmtMoney(asInt(p['amount']))}',
                        style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(
                      save > 0 ? 'Save ₹${fmtMoney(save)}' : '$months month${months == 1 ? '' : 's'}',
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
          ),
        );
      }),
    );
  }

  // ---------- Amount ----------
  Widget _amountCard() {
    final fineAfter = asInt(_fee['fineAfterDay'], 10);
    final perDay = asInt(_fee['finePerDay'], 20);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: FeeColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_month_rounded, size: 18, color: FeeColors.primaryDark),
              const SizedBox(width: 8),
              Expanded(
                child: Text(_planMonths.join(', '),
                    style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _money('Mess fee', _planAmount),
          if (_fine > 0) ...[
            const SizedBox(height: 6),
            _money('Late fine', _fine, color: FeeColors.red),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('₹$perDay per day after the ${ordinal(fineAfter)}',
                  style: GoogleFonts.poppins(fontSize: 10.5, color: FeeColors.red)),
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: FeeColors.border),
          ),
          Row(
            children: [
              Text('Total to pay', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14)),
              const Spacer(),
              Text('₹${fmtMoney(_total)}',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w800, fontSize: 22)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _money(String label, double v, {Color? color}) => Row(
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 13, color: color ?? FeeColors.muted)),
          const Spacer(),
          Text('₹${fmtMoney(v)}',
              style: GoogleFonts.poppins(
                  fontSize: 13.5, fontWeight: FontWeight.w700, color: color ?? FeeColors.text)),
        ],
      );

  // ---------- Step card ----------
  Widget _stepCard({required int n, required String title, required bool done, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: done ? FeeColors.green.withOpacity(0.4) : FeeColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: done ? FeeColors.green : FeeColors.primary,
                  shape: BoxShape.circle,
                ),
                child: done
                    ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                    : Text('$n', style: GoogleFonts.poppins(fontWeight: FontWeight.w800, fontSize: 13)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  // ---------- Step 1: pay ----------
  Widget _payStep() {
    Widget step(String n, String text) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$n. ', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700)),
              Expanded(child: Text(text, style: GoogleFonts.poppins(fontSize: 12, height: 1.4))),
            ],
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1) Direct pay (fastest) — opens the UPI app with amount filled
        if (!kIsWeb) ...[
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () => _openUpiApp(),
              icon: const Icon(Icons.bolt_rounded),
              label: Text('Pay ₹${fmtMoney(_total)} with UPI app',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14)),
              style: ElevatedButton.styleFrom(
                backgroundColor: FeeColors.primary,
                foregroundColor: FeeColors.text,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final app in const [
                ['PhonePe', 'phonepe'],
                ['GPay', 'tez'],
                ['Paytm', 'paytmmp'],
              ]) ...[
                if (app[0] != 'PhonePe') const SizedBox(width: 6),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _openUpiApp(app[1]),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: FeeColors.text,
                      side: const BorderSide(color: FeeColors.border),
                      minimumSize: const Size(0, 38),
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(app[0], style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Text('App says "Can\'t send a payment to this recipient"? Use one of these:',
              style: GoogleFonts.poppins(fontSize: 11.5, color: FeeColors.muted, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
        ],

        // 2) Backup ways that always work with business UPI IDs
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _savingQr || kIsWeb ? null : _saveQrToGallery,
                  icon: _savingQr
                      ? const SizedBox(
                          width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: FeeColors.text))
                      : const Icon(Icons.download_rounded, size: 19),
                  label: Text('Save QR', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 13.5)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FeeColors.primaryLight,
                    foregroundColor: FeeColors.text,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: _copyUpiId,
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  label: Text('Copy UPI ID', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 13.5)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: FeeColors.text,
                    side: const BorderSide(color: FeeColors.primaryDark),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: FeeColors.bg, borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              step('1', 'Save QR → in your UPI app tap Scan → gallery icon → choose the QR.'),
              step('2', 'Or Copy UPI ID → "Pay UPI ID" → paste.'),
              step('3', 'Enter ₹${fmtMoney(_total)}, pay, and take a screenshot of the success page.'),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Text('UPI ID: $_upiId',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(fontSize: 11, color: FeeColors.muted)),
            ),
            TextButton(
              onPressed: () => setState(() => _showQr = !_showQr),
              child: Text(_showQr ? 'Hide QR' : 'Show QR',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: FeeColors.primaryDark)),
            ),
          ],
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          crossFadeState: _showQr || kIsWeb ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          firstChild: const SizedBox(width: double.infinity),
          secondChild: Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: FeeColors.border),
                  ),
                  child: _officialQrUrl.isNotEmpty
                      ? Image.network(_officialQrUrl, width: 200, height: 200, fit: BoxFit.contain)
                      : QrImageView(data: _plainQrData, size: 190, backgroundColor: Colors.white),
                ),
                const SizedBox(height: 6),
                Text('Scan from another phone · $_payee',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 11, color: FeeColors.muted)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ---------- Step 2: screenshot ----------
  Widget _uploadStep() {
    if (_imageBytes == null) {
      return InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: _pickScreenshot,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 22),
          decoration: BoxDecoration(
            color: FeeColors.primaryLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: FeeColors.primaryDark.withOpacity(0.5)),
          ),
          child: Column(
            children: [
              const Icon(Icons.add_photo_alternate_rounded, size: 34, color: FeeColors.primaryDark),
              const SizedBox(height: 6),
              Text('Choose screenshot', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
              Text('UTR, amount and date are read automatically',
                  style: GoogleFonts.poppins(fontSize: 11, color: FeeColors.muted)),
            ],
          ),
        ),
      );
    }

    final readOk = !_scanning && _scan.rawText.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => Get.dialog(Dialog(
                backgroundColor: Colors.transparent,
                child: InteractiveViewer(child: Image.memory(_imageBytes!)),
              )),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.memory(_imageBytes!, width: 56, height: 96, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _scanning
                  ? Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Row(
                        children: [
                          const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: FeeColors.primaryDark)),
                          const SizedBox(width: 10),
                          Text('Reading screenshot…', style: GoogleFonts.poppins(fontSize: 12.5)),
                        ],
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (readOk) ...[
                          _check(_scan.amount != null && _scan.amount!.round() >= _total.round(),
                              _scan.amount == null ? 'Amount not found' : 'Amount ₹${fmtMoney(_scan.amount!)}'),
                          _check(_scan.payeeMatched, _scan.payeeMatched ? 'Paid to Ami Hostlers' : 'Payee not matched'),
                          _check(_scan.paidOn != null,
                              _scan.paidOn != null ? 'Date ${fmtDate(_scan.paidOn)}' : 'Date not found'),
                          _check(_scan.utr != null, _scan.utr != null ? 'UTR found' : 'Type UTR below'),
                        ] else
                          Text('Type the 12-digit UTR from your screenshot below.',
                              style: GoogleFonts.poppins(fontSize: 12, color: FeeColors.muted)),
                        TextButton.icon(
                          onPressed: _pickScreenshot,
                          style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 30)),
                          icon: const Icon(Icons.refresh_rounded, size: 16, color: FeeColors.primaryDark),
                          label: Text('Change',
                              style: GoogleFonts.poppins(fontSize: 12, color: FeeColors.primaryDark)),
                        ),
                      ],
                    ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _utrController,
          keyboardType: TextInputType.number,
          maxLength: 12,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, letterSpacing: 1.2),
          decoration: InputDecoration(
            labelText: 'UTR / UPI Ref. No. (12 digits)',
            labelStyle: GoogleFonts.poppins(fontSize: 12.5),
            counterText: '',
            suffixIcon: _utrValid ? const Icon(Icons.check_circle_rounded, color: FeeColors.green) : null,
            filled: true,
            fillColor: FeeColors.bg,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: FeeColors.border)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: FeeColors.border)),
          ),
        ),
      ],
    );
  }

  Widget _check(bool ok, String label) => Padding(
        padding: const EdgeInsets.only(bottom: 3),
        child: Row(
          children: [
            Icon(ok ? Icons.check_circle_rounded : Icons.error_rounded,
                size: 15, color: ok ? FeeColors.green : FeeColors.amber),
            const SizedBox(width: 6),
            Flexible(child: Text(label, style: GoogleFonts.poppins(fontSize: 12))),
          ],
        ),
      );

  // ---------- Sticky submit ----------
  Widget _bottomBar() => SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: FeeColors.border)),
          ),
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _canSubmit ? _submit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: FeeColors.primary,
                foregroundColor: FeeColors.text,
                disabledBackgroundColor: const Color(0xFFF0F0EA),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: FeeColors.text))
                  : Text(
                      _imageBytes == null ? 'Upload screenshot to continue' : 'Submit payment',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
            ),
          ),
        ),
      );
}

/// Opens the pay screen. Returns true if a screenshot was submitted.
Future<bool> openPayFeesScreen({int planMonths = 1}) async {
  final r = await Get.to(() => PayFeesScreen(initialPlanMonths: planMonths));
  return r == true;
}
