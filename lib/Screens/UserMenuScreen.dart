import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ami_student/Controllers/user_menu_controller.dart';

const Color primaryColor = Color(0xFFFADD73);
const Color primaryDark = Color(0xFFD5A514);
const Color darkTextColor = Color(0xFF252A27);
const Color lightTextColor = Color(0xFF7C837F);
const Color backgroundColor = Color(0xFFFAFAF8);

class UserMenuScreen extends StatefulWidget {
  const UserMenuScreen({super.key});

  @override
  State<UserMenuScreen> createState() => _UserMenuScreenState();
}

class _UserMenuScreenState extends State<UserMenuScreen> {
  final UserMenuController controller = Get.put(UserMenuController());
  final ScrollController _dayScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // 🌟 Auto-scroll horizontal list to center/show today's active day chip
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_dayScrollController.hasClients) {
        double offset = controller.selectedDayIndex.value * 65.0;
        _dayScrollController.animateTo(
          offset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _dayScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Obx(() => Column(
              children: [
                const Text(
                  "Mess Menu",
                  style: TextStyle(
                    color: darkTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                if (controller.activeMenu.isNotEmpty)
                  Text(
                    controller.activeMenu['month'] ?? "",
                    style: const TextStyle(
                      color: darkTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
              ],
            )),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: primaryDark),
          );
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.restaurant_menu_rounded,
                  size: 50,
                  color: lightTextColor,
                ),
                const SizedBox(height: 12),
                Text(
                  controller.errorMessage.value,
                  style: const TextStyle(
                    color: darkTextColor,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.fetchActiveMenu(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryDark,
                  ),
                  child: const Text("Retry"),
                )
              ],
            ),
          );
        }

        return Column(
          children: [
            // Horizontal Day Selector
            Container(
              height: 65,
              padding: const EdgeInsets.symmetric(vertical: 10),
              color: Colors.white,
              child: ListView.builder(
                controller: _dayScrollController,
                scrollDirection: Axis.horizontal,
                itemCount: controller.days.length,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemBuilder: (context, index) {
                  return Obx(() {
                    bool isSelected =
                        controller.selectedDayIndex.value == index;
                    return GestureDetector(
                      onTap: () => controller.changeDay(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        decoration: BoxDecoration(
                          color:
                              isSelected ? primaryDark : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            controller.days[index],
                            style: TextStyle(
                              color: isSelected ? Colors.white : darkTextColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    );
                  });
                },
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildMealCard(
                    "Breakfast",
                    "08:00 AM - 10:00 AM",
                    Icons.wb_sunny_outlined,
                    controller.getMealItems('breakfast'),
                    const Color(0xFFFFF9E6),
                    Colors.orange,
                  ),
                  _buildMealCard(
                    "Lunch",
                    "12:30 PM - 02:30 PM",
                    Icons.wb_sunny_rounded,
                    controller.getMealItems('lunch'),
                    const Color(0xFFE8F5E9),
                    Colors.green,
                  ),
                  _buildMealCard(
                    "Snacks",
                    "05:00 PM - 06:00 PM",
                    Icons.bakery_dining_outlined,
                    controller.getMealItems('snacks'),
                    const Color(0xFFFFF3E0),
                    Colors.deepOrange,
                  ),
                  _buildMealCard(
                    "Dinner",
                    "08:00 PM - 09:30 PM",
                    Icons.nightlight_round,
                    controller.getMealItems('dinner'),
                    const Color(0xFFEFEFFB),
                    Colors.indigo,
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildMealCard(
    String title,
    String time,
    IconData icon,
    List<String> items,
    Color cardColor,
    Color iconColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0F0EA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: darkTextColor,
                    ),
                  ),
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 11,
                      color: lightTextColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 24),
          items.isEmpty
              ? const Text(
                  "No items configured",
                  style: TextStyle(color: lightTextColor, fontSize: 13),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: items
                      .map((item) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              borderRadius: BorderRadius.circular(10),
                              border:
                                  Border.all(color: const Color(0xFFEAEAE5)),
                            ),
                            child: Text(
                              item,
                              style: const TextStyle(
                                fontSize: 13,
                                color: darkTextColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ))
                      .toList(),
                ),
        ],
      ),
    );
  }
}
