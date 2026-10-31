// =====================================================================
// Shared colours + formatters for the mess-fee screens.
// =====================================================================
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FeeColors {
  // Same palette as the Home screen
  static const primary = Color(0xFFFADD73);
  static const primaryDark = Color(0xFFD5A514);
  static const primaryLight = Color(0xFFFFF8DC);
  static const secondary = Color(0xFFC6E4AD);
  static const green = Color(0xFF669447);
  static const greenLight = Color(0xFFF1F8EB);
  static const red = Color(0xFFE53935);
  static const redLight = Color(0xFFFDECEC);
  static const amber = Color(0xFFB7791F);
  static const amberLight = Color(0xFFFFF6E5);
  static const blue = Color(0xFFB8860B); // "under review" uses the brand gold
  static const blueLight = Color(0xFFFFF8DC);
  static const text = Color(0xFF252A27);
  static const muted = Color(0xFF7C837F);
  static const border = Color(0xFFECECE6);
  static const bg = Color(0xFFFAFAF8);

  /// Home-screen header gradient
  static const headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFADD73), Color(0xFFFFE99A), Color(0xFFFFF3C4)],
  );
}

/// 4060 → "4,060"
String fmtMoney(num v) => NumberFormat.decimalPattern('en_IN').format(v.round());

/// ISO string / DateTime → "31 Oct 2026"
String fmtDate(dynamic v, {String pattern = 'd MMM yyyy'}) {
  if (v == null) return '';
  final d = v is DateTime ? v : DateTime.tryParse(v.toString());
  return d == null ? '' : DateFormat(pattern).format(d.toLocal());
}

/// ["October 2026","November 2026","December 2026"] → "Oct–Dec 2026"
String shortRange(List<String> months) {
  if (months.isEmpty) return '';
  if (months.length == 1) return months.first;
  final a = months.first.split(' ');
  final b = months.last.split(' ');
  final from = a.first.length >= 3 ? a.first.substring(0, 3) : a.first;
  final to = b.first.length >= 3 ? b.first.substring(0, 3) : b.first;
  return a.last == b.last ? '$from–$to ${b.last}' : '$from ${a.last} – $to ${b.last}';
}

/// 11 → "11th"
String ordinal(int n) {
  if (n >= 11 && n <= 13) return '${n}th';
  switch (n % 10) {
    case 1:
      return '${n}st';
    case 2:
      return '${n}nd';
    case 3:
      return '${n}rd';
    default:
      return '${n}th';
  }
}

/// 1 → Monthly, 3 → 3 Months, 6 → Half Semester
String planName(int months) {
  switch (months) {
    case 1:
      return 'Monthly';
    case 6:
      return 'Half Semester';
    default:
      return '$months Months';
  }
}

int asInt(dynamic v, [int def = 0]) => v is num ? v.toInt() : int.tryParse('${v ?? ''}') ?? def;
