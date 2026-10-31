import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../Controllers/MealSkipController.dart';

class MealSkippingscreen extends StatefulWidget {
  const MealSkippingscreen({super.key});

  @override
  State<MealSkippingscreen> createState() => _MealSkippingscreenState();
}

class _MealSkippingscreenState extends State<MealSkippingscreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MealSkipController controller = Get.put(MealSkipController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _showConfirmationDialog() {
    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.08),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        )
                      ],
                    ),
                    child: const Icon(
                      Icons.no_food_rounded,
                      size: 40,
                      color: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "Skip this meal?",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                      color: const Color(0xff1A1A1A),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: GoogleFonts.poppins(
                        color: Colors.black54,
                        fontSize: 15,
                        height: 1.6,
                      ),
                      children: [
                        const TextSpan(text: "You are about to skip "),
                        TextSpan(
                          text: controller.selectedMeal.value.toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                        const TextSpan(text: " on\n"),
                        TextSpan(
                          text: DateFormat('EEEE, MMM dd')
                              .format(controller.selectedDate.value),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xff1A1A1A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Get.back(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            "Not now",
                            style: GoogleFonts.poppins(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Get.back();
                            controller.submitSkip();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff1A1A1A),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            "Yes, Skip",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.info_outline,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        "You won't get a token for this meal.",
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F9FA),
      appBar: AppBar(
        title: Text("Meal Management",
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: const Color(0xffFADD73),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          indicatorColor: Colors.black,
          tabs: const [Tab(text: "Schedule Skip"), Tab(text: "My History")],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildScheduleTab(), _buildHistoryTab()],
      ),
    );
  }

  Widget _buildScheduleTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle("1. Select Date"),
          const SizedBox(height: 10),
          _datePickerCard(),
          const SizedBox(height: 25),
          _sectionTitle("2. Select Meal Type"),
          const SizedBox(height: 10),
          _mealTypeGrid(),
          const SizedBox(height: 40),
          Obx(() => SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () => _showConfirmationDialog(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text("Confirm Skipping",
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                ),
              )),
          const SizedBox(height: 25),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xffFADD73), width: 1),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_rounded, color: Colors.orange),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "IMPORTANT: Skips for tomorrow must be submitted before 11:00 PM tonight.",
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _datePickerCard() {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
            context: context,
            initialDate: controller.selectedDate.value,
            firstDate: DateTime.now().add(const Duration(days: 1)),
            lastDate: DateTime.now().add(const Duration(days: 30)));
        if (date != null) controller.selectedDate.value = date;
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xffFADD73), width: 2)),
        child: Row(
          children: [
            const Icon(Icons.calendar_month, color: Color(0xffFADD73)),
            const SizedBox(width: 15),
            Obx(() => Text(
                DateFormat('EEEE, dd MMMM yyyy')
                    .format(controller.selectedDate.value),
                style: GoogleFonts.poppins(
                    fontSize: 15, fontWeight: FontWeight.w600))),
          ],
        ),
      ),
    );
  }

  Widget _mealTypeGrid() {
    List<String> options = [
      "Breakfast",
      "Lunch",
      "Snacks",
      "Dinner",
      "Full Day"
    ];
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((m) {
        return Obx(() {
          bool isSel = controller.selectedMeal.value == m;
          return ChoiceChip(
            label: Text(m,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: isSel ? Colors.black : Colors.black54)),
            selected: isSel,
            onSelected: (v) => controller.selectedMeal.value = m,
            selectedColor: const Color(0xffFADD73),
            backgroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          );
        });
      }).toList(),
    );
  }

  // --- 2. HISTORY TAB WITH MONTH SELECTOR ---
  Widget _buildHistoryTab() {
    return Obx(() {
      if (controller.isLoading.value && controller.historyList.isEmpty) {
        return const Center(
            child: CircularProgressIndicator(color: Color(0xffFFC800)));
      }
      return RefreshIndicator(
        onRefresh: () => controller.fetchInitialSkips(),
        child: Column(
          children: [
            // Month Selector Scroll Row
            _buildMonthSelector(),

            // Summary Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xff1A1A1A),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5))
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Skipped Summary",
                          style: GoogleFonts.poppins(
                              color: Colors.white70, fontSize: 12)),
                      Text(controller.selectedHistoryMonth.value,
                          style: GoogleFonts.poppins(
                              color: const Color(0xffFADD73),
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _miniStat("B", controller.getHistoryCount("Breakfast")),
                      _miniStat("L", controller.getHistoryCount("Lunch")),
                      _miniStat("S", controller.getHistoryCount("Snacks")),
                      _miniStat("D", controller.getHistoryCount("Dinner")),
                      _miniStat("Total", controller.totalHistorySkips),
                    ],
                  ),
                ],
              ),
            ),

            // List or Empty view
            Expanded(
              child: controller.historyList.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      controller: controller.scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: controller.historyList.length +
                          (controller.isMoreLoading.value ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == controller.historyList.length) {
                          return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(
                                  child: CircularProgressIndicator(
                                      color: Color(0xffFFC800))));
                        }
                        return _buildSkipHistoryCard(
                            controller.historyList[index]);
                      },
                    ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildMonthSelector() {
    // Generate the last 6 months for selection
    final List<String> months = List.generate(6, (index) {
      final d = DateTime.now().subtract(Duration(days: index * 30));
      return DateFormat('MMMM yyyy').format(d);
    }).reversed.toList();

    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: months.length,
        itemBuilder: (context, index) {
          final m = months[index];
          bool isSelected = controller.selectedHistoryMonth.value == m;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(m,
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.black : Colors.grey[700])),
              selected: isSelected,
              selectedColor: const Color(0xffFADD73),
              backgroundColor: Colors.white,
              onSelected: (_) => controller.changeHistoryMonth(m),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? Colors.transparent : Colors.grey.shade300,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _miniStat(String label, int count) {
    return Column(
      children: [
        Text(label,
            style: GoogleFonts.poppins(
                color: const Color(0xffFADD73),
                fontWeight: FontWeight.bold,
                fontSize: 12)),
        const SizedBox(height: 4),
        Text("$count",
            style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSkipHistoryCard(dynamic skip) {
    IconData mealIcon;
    Color iconColor;
    Color bgColor;

    switch (skip['mealType']) {
      case 'Breakfast':
        mealIcon = Icons.wb_sunny_outlined;
        iconColor = Colors.orange;
        bgColor = Colors.orange.shade50;
        break;
      case 'Lunch':
        mealIcon = Icons.restaurant;
        iconColor = Colors.green;
        bgColor = Colors.green.shade50;
        break;
      case 'Snacks':
        mealIcon = Icons.bakery_dining_outlined;
        iconColor = Colors.blue;
        bgColor = Colors.blue.shade50;
        break;
      case 'Dinner':
        mealIcon = Icons.nightlight_round;
        iconColor = Colors.indigo;
        bgColor = Colors.indigo.shade50;
        break;
      default:
        mealIcon = Icons.event_available;
        iconColor = Colors.red;
        bgColor = Colors.red.shade50;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2))
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
          child: Icon(mealIcon, color: iconColor, size: 24),
        ),
        title: Text("${skip['mealType']} Skipped",
            style:
                GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15)),
        subtitle: Row(
          children: [
            const Icon(Icons.calendar_today_outlined,
                size: 12, color: Colors.grey),
            const SizedBox(width: 5),
            Text(skip['date'],
                style:
                    GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
        trailing: Text(skip['month'].toString().split(' ')[0],
            style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey[400])),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.15),
        Icon(Icons.no_meals_outlined, size: 80, color: Colors.grey[300]),
        const SizedBox(height: 16),
        Center(
            child: Text("No skipped meals found for this month.",
                style: GoogleFonts.poppins(color: Colors.grey[500]))),
      ],
    );
  }

  Widget _sectionTitle(String text) => Text(text,
      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold));
}
