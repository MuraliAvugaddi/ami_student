import 'dart:typed_data';

import 'package:ami_student/Controllers/hostel_controller.dart';
import 'package:ami_student/Controllers/profile_controller.dart';
import 'package:ami_student/utils/hostel_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

// ============================================================
// RAISE A ROOM COMPLAINT
// Pick the problem → add a note / photo → send
// ============================================================

class RaiseComplaintScreen extends StatefulWidget {
  final String category;

  const RaiseComplaintScreen({super.key, required this.category});

  @override
  State<RaiseComplaintScreen> createState() => _RaiseComplaintScreenState();
}

class _RaiseComplaintScreenState extends State<RaiseComplaintScreen> {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color primaryColor = Color(0xFFFADD73);
  static const Color primaryDark = Color(0xFFD5A514);
  static const Color primaryLight = Color(0xFFFFF8DC);
  static const Color darkTextColor = Color(0xFF252A27);
  static const Color lightTextColor = Color(0xFF7C837F);
  static const Color backgroundColor = Color(0xFFFAFAF8);

  final HostelController controller = Get.isRegistered<HostelController>()
      ? Get.find<HostelController>()
      : Get.put(HostelController());
  final ProfileController profile = Get.find<ProfileController>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();

  String _selectedIssue = '';
  Uint8List? _photo;

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  String get _title => _selectedIssue == 'Other problem' || _selectedIssue.isEmpty
      ? _titleController.text.trim()
      : _selectedIssue;

  // ============================================================
  // PHOTO
  // ============================================================

  Future<void> _pickPhoto(ImageSource source) async {
    final XFile? file = await ImagePicker().pickImage(
      source: source,
      imageQuality: 70,
      maxWidth: 1280,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() => _photo = bytes);
  }

  void _showPhotoOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.photo_camera_rounded, color: primaryDark),
                title: Text("Take a photo", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                onTap: () {
                  Get.back();
                  _pickPhoto(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: primaryDark),
                title: Text("Choose from gallery", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                onTap: () {
                  Get.back();
                  _pickPhoto(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SUBMIT
  // ============================================================

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (_title.isEmpty) {
      Get.snackbar(
        "Tell us the problem",
        "Pick one option or write the problem in one line.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade700,
        colorText: Colors.white,
      );
      return;
    }

    final ok = await controller.raiseComplaint(
      category: widget.category,
      title: _title,
      description: _detailsController.text.trim(),
      photoBytes: _photo,
    );
    if (ok) Get.back(result: true);
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final color = HostelUi.categoryColor(widget.category);
    final issues = HostelUi.quickIssues(widget.category);
    final user = profile.user.value;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        surfaceTintColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: darkTextColor),
        title: Text(
          HostelUi.categoryName(widget.category),
          style: GoogleFonts.poppins(
            color: darkTextColor,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 6, 18, 30),
        children: [
          // ---------------- ROOM ----------------
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: color.withOpacity(0.22)),
            ),
            child: Row(
              children: [
                Icon(HostelUi.categoryIcon(widget.category), color: color, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.room.isEmpty ? "Your room" : "Room ${user.room}",
                        style: GoogleFonts.poppins(
                          color: darkTextColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        user.hostelblock.isEmpty
                            ? "Repair team will come to your room"
                            : "${user.hostelblock} · repair team will come here",
                        style: GoogleFonts.poppins(
                          color: lightTextColor,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // ---------------- WHAT IS THE PROBLEM ----------------
          Text(
            "What is the problem?",
            style: GoogleFonts.poppins(
              color: darkTextColor,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...issues.map((issue) => _issueChip(issue)),
              if (!issues.contains('Other problem')) _issueChip('Other problem'),
            ],
          ),
          if (_selectedIssue == 'Other problem' || _selectedIssue.isEmpty) ...[
            const SizedBox(height: 14),
            _field(
              controller: _titleController,
              hint: "Write the problem in one line",
              icon: Icons.edit_rounded,
              maxLength: 100,
            ),
          ],
          const SizedBox(height: 16),

          // ---------------- DETAILS ----------------
          _field(
            controller: _detailsController,
            hint: "More details (optional) — e.g. fan makes noise and stops",
            icon: Icons.notes_rounded,
            maxLines: 3,
            maxLength: 1000,
          ),
          const SizedBox(height: 16),

          // ---------------- PHOTO ----------------
          _buildPhotoBox(),
          const SizedBox(height: 26),

          Obx(
            () => SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: controller.isSending.value ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: darkTextColor,
                  disabledBackgroundColor: primaryColor.withOpacity(0.5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: controller.isSending.value
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.4, color: darkTextColor),
                      )
                    : Text(
                        "Send to repair team",
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Not fixed in 48 hours? It goes to the Warden automatically, and after 64 hours to the Director.",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: lightTextColor,
              fontSize: 11,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // WIDGETS
  // ============================================================

  Widget _issueChip(String issue) {
    final selected = _selectedIssue == issue;
    return GestureDetector(
      onTap: () => setState(() => _selectedIssue = selected ? '' : issue),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected ? primaryDark : Colors.black.withOpacity(0.08),
          ),
        ),
        child: Text(
          issue,
          style: GoogleFonts.poppins(
            color: darkTextColor,
            fontSize: 12.5,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    int? maxLength,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      style: GoogleFonts.poppins(fontSize: 13.5, color: darkTextColor),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(fontSize: 12.5, color: lightTextColor),
        prefixIcon: maxLines == 1 ? Icon(icon, color: primaryDark, size: 20) : null,
        counterText: '',
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.black.withOpacity(0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.black.withOpacity(0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryDark, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildPhotoBox() {
    if (_photo == null) {
      return InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: _showPhotoOptions,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: primaryLight,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: primaryDark.withOpacity(0.4)),
          ),
          child: Column(
            children: [
              const Icon(Icons.add_a_photo_rounded, color: primaryDark, size: 30),
              const SizedBox(height: 6),
              Text(
                "Add a photo (optional)",
                style: GoogleFonts.poppins(
                  color: darkTextColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "Helps the team bring the right tools",
                style: GoogleFonts.poppins(color: lightTextColor, fontSize: 11),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Image.memory(
            _photo!,
            height: 190,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Material(
            color: Colors.black54,
            shape: const CircleBorder(),
            child: IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white),
              onPressed: () => setState(() => _photo = null),
            ),
          ),
        ),
      ],
    );
  }
}
