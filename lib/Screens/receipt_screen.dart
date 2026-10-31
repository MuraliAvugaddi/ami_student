// =====================================================================
// MESS FEE RECEIPT — with "AMI HOSTLERS JAIPUR" round seal
// and a PAID stamp. Shown after UPI approval or cash payment.
// =====================================================================
import 'dart:math' as math;

import 'package:ami_student/services/payment_service.dart';
import 'package:ami_student/utils/fee_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

// ---------------------------------------------------------------------
// ONE RECEIPT
// ---------------------------------------------------------------------
class ReceiptScreen extends StatelessWidget {
  final Map<String, dynamic> receipt;
  final bool justPaid;

  const ReceiptScreen({super.key, required this.receipt, this.justPaid = false});

  @override
  Widget build(BuildContext context) {
    final r = receipt;
    final months = List<String>.from(r['months'] ?? const []);
    final isCash = r['mode'] == 'cash';
    final fine = (r['fine'] ?? 0) as num;
    final planAmount = (r['planAmount'] ?? 0) as num;
    final total = (r['totalAmount'] ?? 0) as num;
    final utr = (r['utr'] ?? '').toString();
    final planMonths = asInt(r['planMonths'], 1);

    return Scaffold(
      backgroundColor: FeeColors.bg,
      appBar: AppBar(
        backgroundColor: FeeColors.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: FeeColors.text),
        title: Text('Receipt',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: FeeColors.text, fontSize: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
        children: [
          if (justPaid) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: FeeColors.greenLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: FeeColors.green, size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isCash
                          ? 'Cash payment received. Your mess access is active.'
                          : 'Payment approved. Your mess access is active.',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600, color: FeeColors.green, fontSize: 13.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // ---------------- Receipt paper ----------------
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: FeeColors.border),
              boxShadow: const [
                BoxShadow(color: Color(0x0F000000), blurRadius: 24, offset: Offset(0, 8)),
              ],
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                      decoration: BoxDecoration(
                        gradient: isCash
                            ? const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF669447), Color(0xFF8DB86B)],
                              )
                            : FeeColors.headerGradient,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(isCash ? Icons.payments_rounded : Icons.restaurant_rounded,
                                color: isCash ? FeeColors.green : FeeColors.primaryDark),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('AMI HOSTLERS JAIPUR',
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13.5,
                                        color: isCash ? Colors.white : FeeColors.text)),
                                Text(isCash ? 'CASH RECEIPT · Paid at mess office' : 'UPI RECEIPT · Mess fee',
                                    style: GoogleFonts.poppins(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                        color: isCash ? Colors.white : FeeColors.text)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isCash)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        color: FeeColors.greenLight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.currency_rupee_rounded, size: 15, color: FeeColors.green),
                            const SizedBox(width: 4),
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text('PAID IN CASH · RECEIVED AT MESS OFFICE',
                                    maxLines: 1,
                                    style: GoogleFonts.poppins(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.6,
                                        color: FeeColors.green)),
                              ),
                            ),
                          ],
                        ),
                      ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: _kv('Receipt No', '${r['receiptNo'] ?? '-'}', bold: true),
                          ),
                          Expanded(
                            child: _kv('Date', fmtDate(r['paidAt'] ?? r['createdAt'], pattern: 'd MMM yyyy, h:mm a'),
                                end: true),
                          ),
                        ],
                      ),
                    ),
                    _dashed(),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 10, 18, 4),
                      child: Column(
                        children: [
                          _row('Student', '${r['studentName'] ?? ''}'),
                          if ('${r['enrollmentNo'] ?? ''}'.isNotEmpty) _row('Enrollment', '${r['enrollmentNo']}'),
                          if ('${r['room'] ?? ''}'.isNotEmpty) _row('Room', '${r['room']}'),
                          _row('Plan', planMonths == 1 ? 'Monthly' : '${planName(planMonths)} ($planMonths months)'),
                          _row('Months', months.join(', ')),
                          _row('Paid by', isCash ? '💵 Cash at mess office' : 'UPI (online)'),
                          if (utr.isNotEmpty) _row('UTR', utr, copy: true),
                          if ('${r['note'] ?? ''}'.isNotEmpty) _row(isCash ? 'Received' : 'Note', '${r['note']}'),
                          if (r['accessTill'] != null) _row('Access till', fmtDate(r['accessTill'])),
                        ],
                      ),
                    ),
                    _dashed(),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
                      child: Column(
                        children: [
                          _row('Mess fee', '₹${fmtMoney(planAmount)}'),
                          if (fine > 0) _row('Late fine', '₹${fmtMoney(fine)}'),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text('Total paid',
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15)),
                              const Spacer(),
                              Text('₹${fmtMoney(total)}',
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w800, fontSize: 22, color: FeeColors.green)),
                            ],
                          ),
                          const SizedBox(height: 118),
                        ],
                      ),
                    ),
                  ],
                ),

                // Big faint watermark so a cash receipt can never be mistaken for UPI
                Positioned.fill(
                  child: IgnorePointer(
                    child: Center(
                      child: Transform.rotate(
                        angle: -0.5,
                        child: Text(isCash ? 'CASH' : 'UPI',
                            style: GoogleFonts.poppins(
                                fontSize: 110,
                                fontWeight: FontWeight.w900,
                                color: (isCash ? FeeColors.green : FeeColors.primaryDark).withOpacity(0.06))),
                      ),
                    ),
                  ),
                ),

                // Round seal (bottom-left) + PAID stamp (bottom-right)
                Positioned(left: 14, bottom: 12, child: _RoundSeal(size: 92, cash: isCash)),
                Positioned(
                  right: 18,
                  bottom: 26,
                  child: Transform.rotate(angle: -0.22, child: _paidStamp(isCash)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'This is a computer-generated receipt from Ami Hostlers Jaipur. '
            'Take a screenshot to keep a copy.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 11, color: FeeColors.muted),
          ),
          if (justPaid) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: FeeColors.primary,
                  foregroundColor: FeeColors.text,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('Done', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _kv(String k, String v, {bool bold = false, bool end = false}) => Column(
        crossAxisAlignment: end ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(k, style: GoogleFonts.poppins(fontSize: 10.5, color: FeeColors.muted)),
          Text(v,
              textAlign: end ? TextAlign.end : TextAlign.start,
              style: GoogleFonts.poppins(
                  fontSize: 12.5, fontWeight: bold ? FontWeight.w800 : FontWeight.w600, color: FeeColors.text)),
        ],
      );

  Widget _row(String k, String v, {bool copy = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 92,
              child: Text(k, style: GoogleFonts.poppins(fontSize: 12.5, color: FeeColors.muted)),
            ),
            Expanded(
              child: copy
                  ? InkWell(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: v));
                        Get.snackbar('Copied', 'UTR copied',
                            snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(12));
                      },
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(v,
                                style: GoogleFonts.poppins(
                                    fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.6)),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.copy_rounded, size: 14, color: FeeColors.muted),
                        ],
                      ),
                    )
                  : Text(v, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );

  Widget _dashed() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: LayoutBuilder(
          builder: (_, c) => Row(
            children: List.generate(
              (c.maxWidth / 9).floor(),
              (_) => Container(
                width: 5,
                height: 1.2,
                margin: const EdgeInsets.only(right: 4),
                color: const Color(0xFFDADAD2),
              ),
            ),
          ),
        ),
      );

  Widget _paidStamp(bool isCash) {
    final c = isCash ? const Color(0xFF3F7A25) : const Color(0xFF2B4FB3);
    return Opacity(
      opacity: 0.85,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: c, width: 3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('PAID',
                style: GoogleFonts.poppins(
                    color: c, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 4, height: 1.1)),
            Text(isCash ? 'IN CASH 💵' : 'VIA UPI',
                style: GoogleFonts.poppins(color: c, fontSize: 9.5, fontWeight: FontWeight.w800, letterSpacing: 2)),
          ],
        ),
      ),
    );
  }
}

/// Round "AMI HOSTLERS JAIPUR" seal, like an office rubber stamp.
class _RoundSeal extends StatelessWidget {
  final double size;
  final bool cash;
  const _RoundSeal({required this.size, this.cash = false});

  @override
  Widget build(BuildContext context) => Opacity(
        opacity: 0.8,
        child: Transform.rotate(
          angle: -0.18,
          child: CustomPaint(size: Size.square(size), painter: _SealPainter(cash: cash)),
        ),
      );
}

class _SealPainter extends CustomPainter {
  final bool cash;
  _SealPainter({this.cash = false});
  Color get _color => cash ? const Color(0xFF3F7A25) : const Color(0xFF2B4FB3);

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    final ring = Paint()
      ..color = _color
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(c, r - 1.5, ring..strokeWidth = 2.6);
    canvas.drawCircle(c, r * 0.62, ring..strokeWidth = 1.4);

    // Text around the circle
    final text = cash ? '• AMI HOSTLERS JAIPUR • CASH RECEIVED ' : '• AMI HOSTLERS • JAIPUR ';
    final style = TextStyle(color: _color, fontSize: size.width * 0.085, fontWeight: FontWeight.w800);
    final radius = r * 0.81;
    final step = 2 * math.pi / text.length;
    for (var i = 0; i < text.length; i++) {
      final angle = -math.pi / 2 + i * step;
      final tp = TextPainter(text: TextSpan(text: text[i], style: style), textDirection: TextDirection.ltr)
        ..layout();
      canvas.save();
      canvas.translate(c.dx + radius * math.cos(angle), c.dy + radius * math.sin(angle));
      canvas.rotate(angle + math.pi / 2);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }

    // Centre
    final centre = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      text: TextSpan(children: [
        TextSpan(
            text: 'PAID\n',
            style: TextStyle(color: _color, fontSize: size.width * 0.16, fontWeight: FontWeight.w900)),
        TextSpan(
            text: cash ? 'CASH' : 'MESS FEE',
            style: TextStyle(color: _color, fontSize: size.width * 0.075, fontWeight: FontWeight.w700)),
      ]),
    )..layout(maxWidth: size.width);
    centre.paint(canvas, c - Offset(centre.width / 2, centre.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------
// ALL RECEIPTS
// ---------------------------------------------------------------------
class ReceiptsListScreen extends StatefulWidget {
  const ReceiptsListScreen({super.key});

  @override
  State<ReceiptsListScreen> createState() => _ReceiptsListScreenState();
}

class _ReceiptsListScreenState extends State<ReceiptsListScreen> {
  final _api = PaymentService();
  bool _loading = true;
  List<Map<String, dynamic>> _receipts = [];
  List<Map<String, dynamic>> _older = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final results = await Future.wait([_api.getReceiptList(), _api.getMyReceipts()]);
    if (!mounted) return;
    final receipts = List<Map<String, dynamic>>.from(
        (results[0]['receipts'] ?? const []).map((e) => Map<String, dynamic>.from(e)));
    final withReceipt = receipts.map((r) => r['receiptNo']).toSet();
    final older = List<Map<String, dynamic>>.from(
            (results[1]['receipts'] ?? const []).map((e) => Map<String, dynamic>.from(e)))
        .where((p) => '${p['receiptNo'] ?? ''}'.isEmpty || !withReceipt.contains(p['receiptNo']))
        .toList();
    setState(() {
      _receipts = receipts;
      _older = older;
      _loading = false;
    });
  }

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
        title: Text('My Receipts',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: FeeColors.text, fontSize: 18)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: FeeColors.primaryDark))
          : RefreshIndicator(
              color: FeeColors.primaryDark,
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                children: [
                  if (_receipts.isEmpty && _older.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 80),
                      child: Column(
                        children: [
                          const Icon(Icons.receipt_long_rounded, size: 56, color: Color(0xFFD6D6CF)),
                          const SizedBox(height: 10),
                          Text('No receipts yet',
                              style: GoogleFonts.poppins(color: FeeColors.muted, fontSize: 14)),
                        ],
                      ),
                    ),
                  ..._receipts.map((r) => ReceiptTile(receipt: r)),
                  if (_older.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text('Earlier payments',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14)),
                    const SizedBox(height: 6),
                    ..._older.map((p) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.history_rounded, color: FeeColors.muted),
                          title: Text('${p['month'] ?? ''}',
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13.5)),
                          subtitle: Text(
                            '₹${fmtMoney((p['amount'] ?? 0) as num)} · ${p['method'] == 'offline' ? 'Cash' : 'Online'}'
                            '${'${p['transactionId'] ?? ''}'.isNotEmpty ? ' · ${p['transactionId']}' : ''}',
                            style: GoogleFonts.poppins(fontSize: 11.5, color: FeeColors.muted),
                          ),
                        )),
                  ],
                ],
              ),
            ),
    );
  }
}

/// Compact receipt row — used in the list and on the Mess Plan screen.
class ReceiptTile extends StatelessWidget {
  final Map<String, dynamic> receipt;
  const ReceiptTile({super.key, required this.receipt});

  @override
  Widget build(BuildContext context) {
    final r = receipt;
    final months = List<String>.from(r['months'] ?? const []);
    final isCash = r['mode'] == 'cash';
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Get.to(() => ReceiptScreen(receipt: r)),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isCash ? FeeColors.greenLight : null,
              border: Border.all(color: isCash ? FeeColors.secondary : FeeColors.border, width: isCash ? 1.4 : 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isCash ? Colors.white : FeeColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(isCash ? Icons.payments_rounded : Icons.qr_code_2_rounded,
                      color: isCash ? FeeColors.green : FeeColors.primaryDark),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(shortRange(months),
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14)),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: isCash ? FeeColors.green : FeeColors.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(isCash ? 'CASH' : 'UPI',
                                style: GoogleFonts.poppins(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: isCash ? Colors.white : FeeColors.text)),
                          ),
                        ],
                      ),
                      Text(
                        '${isCash ? 'Cash' : 'UPI'} · ${fmtDate(r['paidAt'] ?? r['createdAt'])} · ${r['receiptNo'] ?? ''}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(fontSize: 11.5, color: FeeColors.muted),
                      ),
                    ],
                  ),
                ),
                Text('₹${fmtMoney((r['totalAmount'] ?? 0) as num)}',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w800, fontSize: 15)),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right_rounded, color: FeeColors.muted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}