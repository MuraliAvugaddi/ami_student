// =====================================================================
// Shared labels, icons and colours for the hostel screens
// (room complaints + SOS). Same palette as the mess screens.
// =====================================================================
import 'package:ami_student/utils/fee_ui.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HostelUi {
  // ------------------------------------------------------------
  // COMPLAINT CATEGORIES
  // ------------------------------------------------------------

  static const List<String> categories = [
    'electrical',
    'plumbing',
    'carpentry',
    'cleaning',
    'other',
  ];

  static String categoryName(String c) {
    switch (c) {
      case 'electrical':
        return 'Electrical';
      case 'plumbing':
        return 'Plumbing';
      case 'carpentry':
        return 'Carpentry';
      case 'cleaning':
        return 'Room cleaning';
      default:
        return 'Other';
    }
  }

  static String categoryHint(String c) {
    switch (c) {
      case 'electrical':
        return 'Fan, light, switch, socket';
      case 'plumbing':
        return 'Tap, flush, leakage, geyser';
      case 'carpentry':
        return 'Door, window, bed, cupboard';
      case 'cleaning':
        return 'Room, bathroom, dustbin';
      default:
        return 'Anything else';
    }
  }

  static IconData categoryIcon(String c) {
    switch (c) {
      case 'electrical':
        return Icons.electrical_services_rounded;
      case 'plumbing':
        return Icons.plumbing_rounded;
      case 'carpentry':
        return Icons.door_front_door_rounded;
      case 'cleaning':
        return Icons.cleaning_services_rounded;
      default:
        return Icons.build_rounded;
    }
  }

  static Color categoryColor(String c) {
    switch (c) {
      case 'electrical':
        return const Color(0xFFD5A514);
      case 'plumbing':
        return const Color(0xFF2F6FDB);
      case 'carpentry':
        return const Color(0xFF8D6E63);
      case 'cleaning':
        return FeeColors.green;
      default:
        return const Color(0xFF7656A6);
    }
  }

  /// Quick one-tap problems for each type
  static List<String> quickIssues(String c) {
    switch (c) {
      case 'electrical':
        return ['Fan not working', 'Light not working', 'Switch broken', 'No power in room', 'Socket not working'];
      case 'plumbing':
        return ['Tap leaking', 'Flush not working', 'No water', 'Bathroom blocked', 'Geyser not working'];
      case 'carpentry':
        return ['Door lock broken', 'Window not closing', 'Bed broken', 'Cupboard door broken', 'Chair / table broken'];
      case 'cleaning':
        return ['Room not cleaned', 'Bathroom dirty', 'Dustbin full', 'Bad smell'];
      default:
        return ['Wi-Fi not working', 'Pest / insects', 'Other problem'];
    }
  }

  // ------------------------------------------------------------
  // STATUS
  // ------------------------------------------------------------

  static String statusName(String s) {
    switch (s) {
      case 'open':
        return 'Waiting';
      case 'in_progress':
        return 'Being fixed';
      case 'repaired':
        return 'Repaired · confirm';
      case 'closed':
        return 'Closed';
      case 'reopened':
        return 'Reopened';
      default:
        return s;
    }
  }

  /// (text colour, background colour)
  static (Color, Color) statusColors(String s) {
    switch (s) {
      case 'open':
        return (FeeColors.amber, FeeColors.amberLight);
      case 'in_progress':
        return (FeeColors.primaryDark, FeeColors.primaryLight);
      case 'repaired':
        return (FeeColors.green, FeeColors.greenLight);
      case 'reopened':
        return (FeeColors.red, FeeColors.redLight);
      default:
        return (FeeColors.muted, const Color(0xFFF1F1EC));
    }
  }

  static String levelName(String level) {
    switch (level) {
      case 'warden':
        return 'With Warden';
      case 'director':
        return 'With Director';
      default:
        return '';
    }
  }

  // ------------------------------------------------------------
  // SOS TYPES
  // ------------------------------------------------------------

  static const List<String> sosTypes = ['medical', 'snake', 'danger', 'fire', 'fight', 'other'];

  static String sosName(String t) {
    switch (t) {
      case 'medical':
        return 'Medical';
      case 'snake':
        return 'Snake / animal';
      case 'danger':
        return 'Someone in danger';
      case 'fire':
        return 'Fire / smoke';
      case 'fight':
        return 'Fight';
      default:
        return 'Other emergency';
    }
  }

  static IconData sosIcon(String t) {
    switch (t) {
      case 'medical':
        return Icons.medical_services_rounded;
      case 'snake':
        return Icons.pest_control_rounded;
      case 'danger':
        return Icons.health_and_safety_rounded;
      case 'fire':
        return Icons.local_fire_department_rounded;
      case 'fight':
        return Icons.sports_kabaddi_rounded;
      default:
        return Icons.warning_amber_rounded;
    }
  }
}

/// "just now", "5 min ago", "3 h ago", "2 days ago"
String timeAgo(dynamic v) {
  final d = v is DateTime ? v : DateTime.tryParse('${v ?? ''}');
  if (d == null) return '';
  final diff = DateTime.now().difference(d.toLocal());
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours} h ago';
  if (diff.inDays < 7) return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
  return DateFormat('d MMM').format(d.toLocal());
}

/// "26 Oct, 4:10 PM"
String fmtDateTime(dynamic v) {
  final d = v is DateTime ? v : DateTime.tryParse('${v ?? ''}');
  return d == null ? '' : DateFormat('d MMM, h:mm a').format(d.toLocal());
}
