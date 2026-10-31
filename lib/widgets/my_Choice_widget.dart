import 'package:ami_student/Screens/DayScholarOderScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class MyChoiceWidget extends StatelessWidget {
  const MyChoiceWidget({super.key});

  static const Color primaryColor = Color(0xFFFADD73);
  static const Color primaryDark = Color(0xFFD5A514);
  static const Color primaryLight = Color(0xFFFFF9E7);
  static const Color darkText = Color(0xFF222222);
  static const Color bodyText = Color(0xFF7B7B7B);
  static const Color secondaryDark = Color(0xFF669447);

  bool _isWithinTimeSlot(String mealType) {
    final now = DateTime.now();
    final currentTime = now.hour * 60 + now.minute;

    switch (mealType) {
      case "Breakfast":
        //  return currentTime >= (7 * 60 + 0) && currentTime <= (12 * 60 + 20);
        return currentTime >= (7 * 60 + 50) && currentTime <= (10 * 60 + 20);

      case "Lunch":
        return currentTime >= (11 * 60 + 50) && currentTime <= (14 * 60 + 20);

      case "Snacks":
        return currentTime >= (16 * 60 + 50) && currentTime <= (18 * 60 + 15);

      case "Dinner":
        return currentTime >= (19 * 60 + 50) && currentTime <= (21 * 60 + 40);

      default:
        return false;
    }
  }

  void _openOrderScreen(String mealType, double price) {
    if (!_isWithinTimeSlot(mealType)) {
      Get.snackbar(
        "Meal Time Closed",
        "Ordering for $mealType is currently closed based on its scheduled timings.",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.to(() => DayScholarOrderScreen(
          mealType: mealType,
          price: price,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  CupertinoIcons.bag_fill,
                  color: primaryDark,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Day Scholar Meals",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Order your meals for today",
                      style: GoogleFonts.poppins(
                        color: bodyText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _mealCard(
            title: "Breakfast",
            time: "8:00 AM - 9:00 AM",
            price: "₹60 + GST", // ✅ Updated display text
            image: "assets/images/breakfast.png",
            color: const Color(0xffFFF2F7),
            isOpen: _isWithinTimeSlot("Breakfast"),
            onTap: () =>
                _openOrderScreen("Breakfast", 60), // ✅ Updated price value
          ),

          const SizedBox(height: 14),

          _mealCard(
            title: "Lunch",
            time: "12:00 PM - 2:00 PM",
            price: "₹80 + GST", // ✅ Updated display text
            image: "assets/images/lunch.png",
            color: const Color(0xffEEF9FF),
            isOpen: _isWithinTimeSlot("Lunch"),
            onTap: () => _openOrderScreen("Lunch", 80), // ✅ Updated price value
          ),

          const SizedBox(height: 14),

          _mealCard(
            title: "Snacks",
            time: "5:00 PM - 6:00 PM",
            price: "₹50 + GST", // ✅ Updated display text
            image: "assets/images/snakes.png",
            color: const Color(0xffFFF8ED),
            isOpen: _isWithinTimeSlot("Snacks"),
            onTap: () =>
                _openOrderScreen("Snacks", 50), // ✅ Updated price value
          ),

          const SizedBox(height: 14),

          _mealCard(
            title: "Dinner",
            time: "8:00 PM - 9:00 PM",
            price: "₹80 + GST", // ✅ Updated display text
            image: "assets/images/dinner.png",
            color: const Color(0xffFFFBEA),
            isOpen: _isWithinTimeSlot("Dinner"),
            onTap: () =>
                _openOrderScreen("Dinner", 80), // ✅ Updated price value
          ),
        ],
      ),
    );
  }

  Widget _mealCard({
    required String title,
    required String time,
    required String price,
    required String image,
    required Color color,
    required bool isOpen,
    required VoidCallback onTap,
  }) {
    return Opacity(
      opacity: isOpen ? 1.0 : 0.6,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.only(left: 0, right: 0, top: 6, bottom: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  isOpen ? primaryDark.withOpacity(0.3) : Colors.grey.shade200,
            ),
            color: Colors.white,
          ),
          child: Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Image.asset(image),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: darkText,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isOpen
                                ? secondaryDark.withOpacity(0.1)
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            isOpen ? "Open" : "Closed",
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color:
                                  isOpen ? secondaryDark : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      time,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: bodyText,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: primaryLight,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          price,
                          style: GoogleFonts.poppins(
                            color: primaryDark,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isOpen ? primaryColor : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: isOpen ? Colors.black87 : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
