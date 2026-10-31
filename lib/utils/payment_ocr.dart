// =====================================================================
// Reads a UPI payment screenshot on the phone (Google ML Kit, free,
// works offline) and pulls out UTR, amount, date and payee.
// The student can always correct the UTR before submitting, and the
// admin checks the screenshot before approving.
// =====================================================================
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class PaymentScanResult {
  final String rawText;
  final String? utr;
  final double? amount;
  final DateTime? paidOn;
  final bool payeeMatched;

  const PaymentScanResult({
    required this.rawText,
    this.utr,
    this.amount,
    this.paidOn,
    this.payeeMatched = false,
  });

  static const empty = PaymentScanResult(rawText: '');

  Map<String, dynamic> toJson() => {
        'utr': utr ?? '',
        'amount': amount,
        'paidOn': paidOn?.toIso8601String(),
        'payeeMatched': payeeMatched,
        'rawText': rawText,
      };
}

class PaymentOcr {
  static const _months = {
    'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
    'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12,
  };

  /// Runs OCR on the image file. Returns [PaymentScanResult.empty] on web
  /// or if reading fails — the student can still type the UTR manually.
  static Future<PaymentScanResult> scan(
    String imagePath, {
    required double expectedAmount,
    required String payeeKeyword,
    required String upiId,
  }) async {
    if (kIsWeb) return PaymentScanResult.empty;

    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final recognized =
          await recognizer.processImage(InputImage.fromFilePath(imagePath));
      return parse(
        recognized.text,
        expectedAmount: expectedAmount,
        payeeKeyword: payeeKeyword,
        upiId: upiId,
      );
    } catch (e) {
      debugPrint('OCR failed: $e');
      return PaymentScanResult.empty;
    } finally {
      await recognizer.close();
    }
  }

  /// Pure text parsing — separated so it is easy to test.
  static PaymentScanResult parse(
    String text, {
    required double expectedAmount,
    required String payeeKeyword,
    required String upiId,
  }) {
    final upper = text.toUpperCase();
    return PaymentScanResult(
      rawText: text,
      utr: _findUtr(text),
      amount: _findAmount(text, expectedAmount),
      paidOn: _findDate(text),
      payeeMatched: upper.contains(payeeKeyword.toUpperCase()) ||
          upper.replaceAll(' ', '').contains(
                upiId.split('@').first.toUpperCase().replaceAll(' ', ''),
              ),
    );
  }

  // ---------------- UTR ----------------
  // Works for PhonePe ("UTR: 699125422656"), GPay ("UPI transaction ID"),
  // Paytm ("UPI Ref No"), BHIM ("RRN") etc.
  static String? _findUtr(String text) {
    final lines = text.split('\n');
    final keyword = RegExp(
      r'(UTR|UPI\s*REF|UPI\s*TRANSACTION\s*ID|UPI\s*REF\.?\s*NO|REF\.?\s*NO|RRN|REFERENCE)',
      caseSensitive: false,
    );

    for (var i = 0; i < lines.length; i++) {
      if (!keyword.hasMatch(lines[i])) continue;
      // Same line, or the next line (many apps put the number below the label)
      for (final candidate in [lines[i], if (i + 1 < lines.length) lines[i + 1]]) {
        final digits = _twelveDigits(candidate);
        if (digits != null) return digits;
      }
    }

    // Fallback: any standalone 12-digit number in the screenshot
    final any = RegExp(r'(?<!\d)\d{12}(?!\d)').firstMatch(text.replaceAll(' ', ''));
    return any?.group(0);
  }

  static String? _twelveDigits(String line) {
    // "6991 2542 2656" or "699125422656"
    final m = RegExp(r'(?<!\d)(\d[\d ]{10,16}\d)(?!\d)').allMatches(line);
    for (final match in m) {
      final digits = match.group(1)!.replaceAll(' ', '');
      if (digits.length == 12) return digits;
    }
    return null;
  }

  // ---------------- Amount ----------------
  static double? _findAmount(String text, double expected) {
    final candidates = <double>[];
    // ₹ is often read as "%", "Z", "2" or "?" by OCR, so accept those too
    final withSymbol = RegExp(
      r'(?:₹|RS\.?|INR|%|Z|\?)\s?([0-9]{1,3}(?:,[0-9]{2,3})+|[0-9]{3,6})(?:\.([0-9]{1,2}))?',
      caseSensitive: false,
    );
    for (final m in withSymbol.allMatches(text)) {
      final v = double.tryParse('${m.group(1)!.replaceAll(',', '')}.${m.group(2) ?? '0'}');
      if (v != null && v > 0) candidates.add(v);
    }

    // Plain numbers like "4,000" or "4000.00" anywhere
    final plain = RegExp(r'(?<![\d.])([0-9]{1,3}(?:,[0-9]{2,3})+|[0-9]{3,6})(?:\.([0-9]{2}))?(?![\d])');
    for (final m in plain.allMatches(text)) {
      final v = double.tryParse(m.group(1)!.replaceAll(',', ''));
      if (v != null && v == expected) candidates.add(v);
    }

    if (candidates.isEmpty) return null;
    // Prefer the number that equals the plan amount
    for (final c in candidates) {
      if (c.round() == expected.round()) return c;
    }
    return candidates.first;
  }

  // ---------------- Date ----------------
  static DateTime? _findDate(String text) {
    // "05 May 2026", "5 May, 2026"
    final dMonY = RegExp(r'(\d{1,2})\s*([A-Za-z]{3,9})[,\s]+(\d{4})');
    for (final m in dMonY.allMatches(text)) {
      final month = _months[m.group(2)!.toLowerCase().substring(0, 3)];
      if (month != null) {
        return _safeDate(int.parse(m.group(3)!), month, int.parse(m.group(1)!));
      }
    }

    // "May 5, 2026"
    final monDY = RegExp(r'([A-Za-z]{3,9})\s+(\d{1,2}),?\s+(\d{4})');
    for (final m in monDY.allMatches(text)) {
      final month = _months[m.group(1)!.toLowerCase().substring(0, 3)];
      if (month != null) {
        return _safeDate(int.parse(m.group(3)!), month, int.parse(m.group(2)!));
      }
    }

    // "05/05/2026" or "05-05-2026" (Indian day/month/year)
    final numeric = RegExp(r'(\d{1,2})[/\-.](\d{1,2})[/\-.](\d{2,4})').firstMatch(text);
    if (numeric != null) {
      var year = int.parse(numeric.group(3)!);
      if (year < 100) year += 2000;
      return _safeDate(year, int.parse(numeric.group(2)!), int.parse(numeric.group(1)!));
    }

    // "2026-05-05"
    final iso = RegExp(r'(\d{4})-(\d{2})-(\d{2})').firstMatch(text);
    if (iso != null) {
      return _safeDate(int.parse(iso.group(1)!), int.parse(iso.group(2)!), int.parse(iso.group(3)!));
    }
    return null;
  }

  static DateTime? _safeDate(int y, int m, int d) {
    if (y < 2020 || y > 2100 || m < 1 || m > 12 || d < 1 || d > 31) return null;
    return DateTime(y, m, d, 12); // noon avoids timezone date shifts
  }
}
