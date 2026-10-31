import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final IconData icon;

  final bool isPassword;

  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;

  // ============================================================
  // NEW: KEYBOARD + FOCUS SUPPORT
  // ============================================================

  final FocusNode? focusNode;

  final TextInputAction? textInputAction;

  final ValueChanged<String>? onSubmitted;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.icon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,

    // NEW
    this.focusNode,

    // NEW
    this.textInputAction,

    // NEW
    this.onSubmitted,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  // ============================================================
  // PASSWORD VISIBILITY
  // ============================================================

  late bool _obscureText;

  @override
  void initState() {
    super.initState();

    _obscureText = widget.isPassword;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return TextField(
      // ========================================================
      // CONTROLLER
      // ========================================================

      controller: widget.controller,

      // ========================================================
      // NEW: FOCUS NODE
      // ========================================================

      focusNode: widget.focusNode,

      // ========================================================
      // KEYBOARD
      // ========================================================

      keyboardType: widget.keyboardType,

      textCapitalization: widget.textCapitalization,

      // ========================================================
      // NEW: NEXT / DONE BUTTON
      // ========================================================

      textInputAction: widget.textInputAction,

      // ========================================================
      // NEW: WHEN USER PRESSES NEXT / DONE
      // ========================================================

      onSubmitted: widget.onSubmitted,

      // ========================================================
      // PASSWORD
      // ========================================================

      obscureText: _obscureText,

      // Prevent autocorrect for passwords
      autocorrect: !widget.isPassword,

      enableSuggestions: !widget.isPassword,

      // ========================================================
      // CURSOR
      // ========================================================

      cursorColor: const Color(0xffFADD73),

      // ========================================================
      // STYLE
      // ========================================================

      style: GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: const Color(0xff252A27),
      ),

      // ========================================================
      // DECORATION
      // ========================================================

      decoration: InputDecoration(
        labelText: widget.labelText,

        hintText: widget.hintText,

        // ======================================================
        // LABEL
        // ======================================================

        labelStyle: GoogleFonts.poppins(
          color: const Color(0xff707070),
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),

        floatingLabelStyle: GoogleFonts.poppins(
          color: const Color(0xffD5A514),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),

        // ======================================================
        // HINT
        // ======================================================

        hintStyle: GoogleFonts.poppins(
          color: const Color(0xffA0A0A0),
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),

        // ======================================================
        // PREFIX ICON
        // ======================================================

        prefixIcon: Icon(
          widget.icon,
          color: const Color(0xff707070),
          size: 21,
        ),

        // ======================================================
        // PASSWORD EYE ICON
        // ======================================================

        suffixIcon: widget.isPassword
            ? IconButton(
                tooltip: _obscureText ? 'Show password' : 'Hide password',
                icon: Icon(
                  _obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: const Color(0xff707070),
                  size: 21,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,

        // ======================================================
        // BACKGROUND
        // ======================================================

        filled: true,

        fillColor: Colors.white,

        // ======================================================
        // NORMAL BORDER
        // ======================================================

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xffE5E5E0),
            width: 1,
          ),
        ),

        // ======================================================
        // FOCUSED BORDER
        // ======================================================

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xffFADD73),
            width: 2,
          ),
        ),

        // ======================================================
        // DEFAULT BORDER
        // ======================================================

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xffE5E5E0),
          ),
        ),

        // ======================================================
        // ERROR BORDER
        // ======================================================

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 1,
          ),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 2,
          ),
        ),

        // ======================================================
        // PADDING
        // ======================================================

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
      ),
    );
  }
}
