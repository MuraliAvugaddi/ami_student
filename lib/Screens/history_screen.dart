import 'package:ami_student/widgets/history_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../Controllers/history_controller.dart';

// ============================================================
// CHEF BRAND COLORS
// ============================================================

const Color primaryColor = Color(0xFFFADD73);
const Color primaryDark = Color(0xFFD5A514);
const Color primaryLight = Color(0xFFFFF8DC);

const Color secondaryColor = Color(0xFFC6E4AD);
const Color secondaryLight = Color(0xFFF1F8EB);
const Color secondaryDark = Color(0xFF669447);

const Color darkTextColor = Color(0xFF252A27);
const Color lightTextColor = Color(0xFF7C837F);

const Color backgroundColor = Color(0xFFFAFAF8);
const Color cardColor = Colors.white;

// ============================================================
// HISTORY SCREEN
// ============================================================

class HistoryScreen extends StatelessWidget {
  HistoryScreen({super.key});

  final HistoryController hController = Get.put(
    HistoryController(),
  );

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> monthOptions = List.generate(4, (index) {
      final DateTime d = DateTime(
        DateTime.now().year,
        DateTime.now().month - index,
      );

      return {
        'label': DateFormat('MMM').format(d),
        'fullLabel': DateFormat('MMMM yyyy').format(d),
        'value': DateFormat('yyyy-MM').format(d),
      };
    });

    return Scaffold(
      backgroundColor: backgroundColor,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        toolbarHeight: 72,
        backgroundColor: backgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.only(
            left: 16,
            top: 8,
            bottom: 8,
          ),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => Get.back(),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: darkTextColor,
                size: 19,
              ),
            ),
          ),
        ),
        title: Text(
          "Meal History",
          style: GoogleFonts.poppins(
            color: darkTextColor,
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: Obx(() {
        return Column(
          children: [
            // ==================================================
            // MONTH SELECTOR
            // ==================================================

            _buildMonthSelector(monthOptions),

            const SizedBox(height: 6),

            // ==================================================
            // CONTENT
            // ==================================================

            Expanded(
              child: hController.isLoading.value &&
                      hController.historyList.isEmpty
                  ? _buildMainLoading()
                  : RefreshIndicator(
                      color: primaryDark,
                      backgroundColor: Colors.white,
                      onRefresh: () => hController.fetchInitialHistory(),
                      child: CustomScrollView(
                        controller: hController.scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          // ====================================
                          // SUMMARY CARD
                          // ====================================

                          SliverToBoxAdapter(
                            child: _buildSummaryCard(),
                          ),

                          // ====================================
                          // HISTORY TITLE
                          // ====================================

                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                18,
                                8,
                                18,
                                14,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    height: 36,
                                    width: 36,
                                    decoration: BoxDecoration(
                                      color: primaryLight,
                                      borderRadius: BorderRadius.circular(
                                        11,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.restaurant_menu_rounded,
                                      color: primaryDark,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    "Your Meals",
                                    style: GoogleFonts.poppins(
                                      color: darkTextColor,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (hController.historyList.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: primaryLight,
                                        borderRadius: BorderRadius.circular(
                                          20,
                                        ),
                                      ),
                                      child: Text(
                                        "${hController.historyList.length} meals",
                                        style: GoogleFonts.poppins(
                                          color: primaryDark,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),

                          // ====================================
                          // EMPTY OR HISTORY LIST
                          // ====================================

                          if (hController.historyList.isEmpty)
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: _buildEmptyState(),
                            )
                          else
                            SliverPadding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final item = hController.historyList[index];

                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 10,
                                      ),
                                      child: HistoryTile(
                                        mealType: item['mealType'],
                                        tokenNumber:
                                            item['tokenNumber'].toString(),
                                        date: DateTime.parse(
                                          item['generatedAt'],
                                        ).toLocal(),
                                      ),
                                    );
                                  },
                                  childCount: hController.historyList.length,
                                ),
                              ),
                            ),

                          // ====================================
                          // PAGINATION LOADER
                          // ====================================

                          SliverToBoxAdapter(
                            child: Obx(
                              () {
                                if (hController.isMoreLoading.value) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 25,
                                    ),
                                    child: Center(
                                      child: SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: primaryDark,
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                return const SizedBox(
                                  height: 35,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        );
      }),
    );
  }

  // ============================================================
  // MONTH SELECTOR
  // ============================================================

  Widget _buildMonthSelector(
    List<Map<String, String>> monthOptions,
  ) {
    return Container(
      height: 76,
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFF0F0EA),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: monthOptions.length,
        itemBuilder: (context, index) {
          final m = monthOptions[index];

          final bool isSelected = hController.selectedMonth.value == m['value'];

          return GestureDetector(
            onTap: () {
              hController.changeMonth(
                m['value']!,
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              width: 82,
              margin: const EdgeInsets.only(
                right: 5,
              ),
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : Colors.transparent,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    m['label']!,
                    style: GoogleFonts.poppins(
                      color: isSelected ? darkTextColor : lightTextColor,
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    m['value']!.substring(0, 4),
                    style: GoogleFonts.poppins(
                      color: isSelected
                          ? darkTextColor.withOpacity(
                              0.65,
                            )
                          : lightTextColor.withOpacity(
                              0.65,
                            ),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // SUMMARY CARD
  // ============================================================

  Widget _buildSummaryCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        16,
        20,
        16,
        24,
      ),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFADD73),
            Color(0xFFFFE99A),
            Color(0xFFFFF3C4),
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.25),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // TOP
          Row(
            children: [
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.60),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.history_rounded,
                  color: darkTextColor,
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Meal Summary",
                      style: GoogleFonts.poppins(
                        color: darkTextColor,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formattedSelectedMonth(),
                      style: GoogleFonts.poppins(
                        color: darkTextColor.withOpacity(0.60),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 16,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.55),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildStat(
                    icon: Icons.confirmation_number_outlined,
                    label: "Total Tokens",
                    value: "${hController.historyList.length}",
                  ),
                ),
                Container(
                  width: 1,
                  height: 48,
                  color: darkTextColor.withOpacity(0.10),
                ),
                Expanded(
                  child: _buildStat(
                    icon: Icons.calendar_month_outlined,
                    label: "Selected Month",
                    value: _shortSelectedMonth(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STAT
  // ============================================================

  Widget _buildStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: darkTextColor.withOpacity(0.65),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: darkTextColor,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: darkTextColor.withOpacity(0.55),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        30,
        30,
        30,
        80,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 100,
            width: 100,
            decoration: const BoxDecoration(
              color: primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.no_meals_outlined,
              color: primaryDark,
              size: 45,
            ),
          ),
          const SizedBox(height: 22),
          Text(
            "No meals found",
            style: GoogleFonts.poppins(
              color: darkTextColor,
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            "You don't have any meal history for ${_formattedSelectedMonth()}.",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: lightTextColor,
              fontSize: 13,
              height: 1.5,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: secondaryLight,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.swipe_rounded,
                  size: 16,
                  color: secondaryDark,
                ),
                SizedBox(width: 6),
                Text(
                  "Select another month",
                  style: TextStyle(
                    color: secondaryDark,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MAIN LOADING
  // ============================================================

  Widget _buildMainLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 65,
            width: 65,
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(
              color: primaryLight,
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              strokeWidth: 3,
              color: primaryDark,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Loading your meals...",
            style: GoogleFonts.poppins(
              color: lightTextColor,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FORMAT SELECTED MONTH
  // ============================================================

  String _formattedSelectedMonth() {
    try {
      final DateTime date = DateFormat(
        'yyyy-MM',
      ).parse(
        hController.selectedMonth.value,
      );

      return DateFormat(
        'MMMM yyyy',
      ).format(date);
    } catch (_) {
      return hController.selectedMonth.value;
    }
  }

  // ============================================================
  // SHORT MONTH
  // ============================================================

  String _shortSelectedMonth() {
    try {
      final DateTime date = DateFormat(
        'yyyy-MM',
      ).parse(
        hController.selectedMonth.value,
      );

      return DateFormat(
        'MMM yyyy',
      ).format(date);
    } catch (_) {
      return hController.selectedMonth.value;
    }
  }
}
