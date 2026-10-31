import 'package:ami_student/Controllers/hostel_controller.dart';
import 'package:ami_student/utils/hostel_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

// ============================================================
// ONE COMPLAINT — progress, who is fixing it, confirm repair
// ============================================================

class ComplaintDetailsScreen extends StatefulWidget {
  final String complaintId;

  const ComplaintDetailsScreen({super.key, required this.complaintId});

  @override
  State<ComplaintDetailsScreen> createState() => _ComplaintDetailsScreenState();
}

class _ComplaintDetailsScreenState extends State<ComplaintDetailsScreen> {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color primaryColor = Color(0xFFFADD73);
  static const Color primaryDark = Color(0xFFD5A514);
  static const Color primaryLight = Color(0xFFFFF8DC);
  static const Color secondaryDark = Color(0xFF669447);
  static const Color secondaryLight = Color(0xFFF1F8EB);
  static const Color darkTextColor = Color(0xFF252A27);
  static const Color lightTextColor = Color(0xFF7C837F);
  static const Color backgroundColor = Color(0xFFFAFAF8);

  final HostelController controller = Get.isRegistered<HostelController>()
      ? Get.find<HostelController>()
      : Get.put(HostelController());

  Map<String, dynamic>? _complaint;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final c = await controller.getComplaint(widget.complaintId);
    if (!mounted) return;
    setState(() {
      _complaint = c;
      _loading = false;
    });
  }

  Future<void> _call(String phone) async {
    if (phone.isEmpty) return;
    await launchUrl(Uri(scheme: 'tel', path: phone));
  }

  // ============================================================
  // CONFIRM
  // ============================================================

  void _askRating() {
    int rating = 5;
    final commentController = TextEditingController();

    Get.dialog(
      StatefulBuilder(
        builder: (context, setDialog) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 26),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 70,
                  width: 70,
                  decoration: const BoxDecoration(color: secondaryLight, shape: BoxShape.circle),
                  child: const Icon(Icons.thumb_up_alt_rounded, color: secondaryDark, size: 34),
                ),
                const SizedBox(height: 14),
                Text(
                  "How was the repair?",
                  style: GoogleFonts.poppins(
                    color: darkTextColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    return IconButton(
                      onPressed: () => setDialog(() => rating = i + 1),
                      icon: Icon(
                        i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: primaryDark,
                        size: 34,
                      ),
                    );
                  }),
                ),
                TextField(
                  controller: commentController,
                  maxLength: 300,
                  style: GoogleFonts.poppins(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: "Any comment? (optional)",
                    hintStyle: GoogleFonts.poppins(fontSize: 12.5, color: lightTextColor),
                    counterText: '',
                    filled: true,
                    fillColor: backgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      Get.back();
                      final updated = await controller.confirmComplaint(
                        widget.complaintId,
                        fixed: true,
                        rating: rating,
                        comment: commentController.text.trim(),
                      );
                      if (updated != null && mounted) setState(() => _complaint = updated);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: darkTextColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      "Submit",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _askNotFixed() {
    final reasonController = TextEditingController();
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          "Still not fixed?",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        content: TextField(
          controller: reasonController,
          maxLines: 3,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: InputDecoration(
            hintText: "Tell the team what is still wrong",
            hintStyle: GoogleFonts.poppins(fontSize: 12.5),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              Get.back();
              final updated = await controller.confirmComplaint(
                widget.complaintId,
                fixed: false,
                comment: reasonController.text.trim(),
              );
              if (updated != null && mounted) setState(() => _complaint = updated);
            },
            child: Text(
              "Reopen",
              style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        surfaceTintColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: darkTextColor),
        title: Text(
          _complaint == null ? "Complaint" : '${_complaint!['code']}',
          style: GoogleFonts.poppins(
            color: darkTextColor,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: primaryDark))
          : _complaint == null
              ? Center(
                  child: Text(
                    "Complaint not found",
                    style: GoogleFonts.poppins(color: lightTextColor),
                  ),
                )
              : RefreshIndicator(
                  color: primaryDark,
                  onRefresh: _load,
                  child: _buildBody(_complaint!),
                ),
    );
  }

  Widget _buildBody(Map<String, dynamic> c) {
    final category = '${c['category']}';
    final status = '${c['status']}';
    final color = HostelUi.categoryColor(category);
    final worker = c['assignedTo'] is Map ? Map<String, dynamic>.from(c['assignedTo']) : <String, dynamic>{};
    final timeline = (c['timeline'] is List ? c['timeline'] as List : const [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList()
        .reversed
        .toList();

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 30),
      children: [
        // ---------------- TITLE CARD ----------------
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    height: 46,
                    width: 46,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(HostelUi.categoryIcon(category), color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${c['title']}',
                          style: GoogleFonts.poppins(
                            color: darkTextColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${HostelUi.categoryName(category)} · Room ${c['room']} · ${fmtDateTime(c['createdAt'])}',
                          style: GoogleFonts.poppins(color: lightTextColor, fontSize: 11.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if ('${c['description'] ?? ''}'.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  '${c['description']}',
                  style: GoogleFonts.poppins(color: darkTextColor, fontSize: 13, height: 1.5),
                ),
              ],
              if ('${c['photoUrl'] ?? ''}'.isNotEmpty) ...[
                const SizedBox(height: 12),
                _photo('${c['photoUrl']}'),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ---------------- PROGRESS ----------------
        _card(child: _buildProgress(status, '${c['level']}')),
        const SizedBox(height: 12),

        // ---------------- WORKER ----------------
        if (worker.isNotEmpty)
          _card(
            child: Row(
              children: [
                Container(
                  height: 44,
                  width: 44,
                  decoration: const BoxDecoration(color: primaryLight, shape: BoxShape.circle),
                  child: const Icon(Icons.engineering_rounded, color: primaryDark),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${worker['name']}',
                        style: GoogleFonts.poppins(
                          color: darkTextColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        "Fixing your ${HostelUi.categoryName(category).toLowerCase()} problem",
                        style: GoogleFonts.poppins(color: lightTextColor, fontSize: 11.5),
                      ),
                    ],
                  ),
                ),
                if ('${worker['phone'] ?? ''}'.isNotEmpty)
                  IconButton.filled(
                    style: IconButton.styleFrom(backgroundColor: secondaryLight),
                    onPressed: () => _call('${worker['phone']}'),
                    icon: const Icon(Icons.call_rounded, color: secondaryDark),
                  ),
              ],
            ),
          ),
        if (worker.isNotEmpty) const SizedBox(height: 12),

        // ---------------- REPAIR NOTE ----------------
        if ('${c['repairNote'] ?? ''}'.isNotEmpty)
          _card(
            color: secondaryLight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "What was repaired",
                  style: GoogleFonts.poppins(
                    color: secondaryDark,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${c['repairNote']}',
                  style: GoogleFonts.poppins(color: darkTextColor, fontSize: 13.5, height: 1.5),
                ),
                if ('${c['repairPhotoUrl'] ?? ''}'.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _photo('${c['repairPhotoUrl']}'),
                ],
              ],
            ),
          ),
        if ('${c['repairNote'] ?? ''}'.isNotEmpty) const SizedBox(height: 12),

        // ---------------- CONFIRM ----------------
        if (status == 'repaired') ...[
          Text(
            "Is it fixed now?",
            style: GoogleFonts.poppins(
              color: darkTextColor,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton(
                    onPressed: _askNotFixed,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade600,
                      side: BorderSide(color: Colors.red.shade300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      "Not fixed",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _askRating,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: darkTextColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      "Yes, fixed",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],

        if (c['rating'] != null)
          _card(
            child: Row(
              children: [
                Text(
                  "Your rating",
                  style: GoogleFonts.poppins(color: lightTextColor, fontSize: 12.5),
                ),
                const Spacer(),
                ...List.generate(
                  5,
                  (i) => Icon(
                    i < (c['rating'] as num).toInt() ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: primaryDark,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        if (c['rating'] != null) const SizedBox(height: 12),

        // ---------------- TIMELINE ----------------
        Text(
          "Updates",
          style: GoogleFonts.poppins(
            color: darkTextColor,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        ...timeline.map(_timelineRow),
      ],
    );
  }

  // ============================================================
  // PROGRESS STEPS
  // ============================================================

  Widget _buildProgress(String status, String level) {
    const steps = ['Raised', 'Accepted', 'Repaired', 'Closed'];
    int done = 0;
    if (status == 'in_progress' || status == 'reopened') done = 1;
    if (status == 'repaired') done = 2;
    if (status == 'closed') done = 3;

    final levelText = HostelUi.levelName(level);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(steps.length, (i) {
            final on = i <= done;
            return Expanded(
              child: Column(
                children: [
                  Container(
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: on ? secondaryDark : const Color(0xFFEDEDE6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    steps[i],
                    style: GoogleFonts.poppins(
                      color: on ? secondaryDark : lightTextColor,
                      fontSize: 10.5,
                      fontWeight: on ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
        if (status == 'reopened' || levelText.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            status == 'reopened'
                ? "You said it is still not fixed. The team will come again."
                : "Not repaired in time — now handled by the ${level == 'director' ? 'Director' : 'Warden'}.",
            style: GoogleFonts.poppins(
              color: const Color(0xFF7656A6),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  Widget _timelineRow(Map<String, dynamic> t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 5),
            height: 10,
            width: 10,
            decoration: const BoxDecoration(color: primaryDark, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${t['note'] ?? t['action']}',
                  style: GoogleFonts.poppins(color: darkTextColor, fontSize: 13, height: 1.4),
                ),
                Text(
                  '${t['byName']} · ${fmtDateTime(t['at'])}',
                  style: GoogleFonts.poppins(color: lightTextColor, fontSize: 10.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  Widget _card({required Widget child, Color color = Colors.white}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: child,
    );
  }

  Widget _photo(String url) {
    return GestureDetector(
      onTap: () => Get.dialog(
        Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(12),
          child: InteractiveViewer(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(url),
            ),
          ),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.network(
          url,
          height: 170,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            height: 80,
            color: const Color(0xFFF1F1EC),
            child: const Icon(Icons.broken_image_outlined, color: lightTextColor),
          ),
        ),
      ),
    );
  }
}
