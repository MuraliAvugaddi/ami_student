import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class HistoryTile extends StatelessWidget {
  final String mealType;
  final String tokenNumber;
  final DateTime date;

  const HistoryTile({
    super.key,
    required this.mealType,
    required this.tokenNumber,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    // UI Logic for meal-specific icons and colors
    IconData mealIcon;
    Color accentColor;

    switch (mealType) {
      case 'Breakfast':
        mealIcon = Icons.wb_sunny_outlined;
        accentColor = Colors.orange;
        break;
      case 'Lunch':
        mealIcon = Icons.lunch_dining_outlined;
        accentColor = Colors.green;
        break;
      case 'Snacks':
        mealIcon = Icons.coffee_outlined;
        accentColor = Colors.brown;
        break;
      case 'Dinner':
        mealIcon = Icons.nightlight_round_outlined;
        accentColor = Colors.indigo;
        break;
      default:
        mealIcon = Icons.fastfood_outlined;
        accentColor = Colors.amber;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
           color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(15)),
            child: Icon(mealIcon, color: accentColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mealType,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold, fontSize: 18)),
                Text(DateFormat('EEEE, d MMM | hh:mm a').format(date),
                    style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("#$tokenNumber",
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                      color: Colors.black87)),
              const Text("Token No.",
                  style: TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}
