import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  // ============================================================
  // COLORS
  // ============================================================

  static const Color primaryColor = Color(0xFFFADD73);
  static const Color primaryLight = Color(0xFFFFF8DC);

  static const Color darkTextColor = Color(0xFF252A27);
  static const Color inactiveColor = Color(0xFF8A918D);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.black.withOpacity(0.05),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            8,
            7,
            8,
            7,
          ),
          child: Row(
            children: [
              // =================================================
              // HOME
              // =================================================

              Expanded(
                child: _buildNavItem(
                  selectedIcon: Icons.home_rounded,
                  unselectedIcon: Icons.home_outlined,
                  label: 'Home',
                  index: 0,
                ),
              ),

              // =================================================
              // À LA CARTE
              // =================================================

              Expanded(
                child: _buildNavItem(
                  selectedIcon: Icons.restaurant_menu_rounded,
                  unselectedIcon: Icons.restaurant_menu_outlined,
                  label: 'À La Carte',
                  index: 1,
                ),
              ),

              // =================================================
              // HOSTEL (SOS + room complaints)
              // =================================================

              Expanded(
                child: _buildNavItem(
                  selectedIcon: Icons.apartment_rounded,
                  unselectedIcon: Icons.apartment_outlined,
                  label: 'Hostel',
                  index: 2,
                ),
              ),

              // =================================================
              // SUBSCRIPTION
              // =================================================

              Expanded(
                child: _buildNavItem(
                  selectedIcon: Icons.workspace_premium_rounded,
                  unselectedIcon: Icons.workspace_premium_outlined,
                  label: 'Subscription',
                  index: 3,
                ),
              ),

              // =================================================
              // PROFILE
              // =================================================

              Expanded(
                child: _buildNavItem(
                  selectedIcon: Icons.person_rounded,
                  unselectedIcon: Icons.person_outline_rounded,
                  label: 'Profile',
                  index: 4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // NAVIGATION ITEM
  // ============================================================

  Widget _buildNavItem({
    required IconData selectedIcon,
    required IconData unselectedIcon,
    required String label,
    required int index,
  }) {
    final bool isSelected = selectedIndex == index;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          onItemTapped(index);
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          height: 58,
          margin: const EdgeInsets.symmetric(
            horizontal: 2,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 2,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? primaryLight
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // =================================================
              // ICON
              // =================================================

              AnimatedContainer(
                duration: const Duration(
                  milliseconds: 220,
                ),
                curve: Curves.easeOutCubic,
                height: 28,
                width: 40,
                decoration: BoxDecoration(
                  color: isSelected
                      ? primaryColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(
                      milliseconds: 180,
                    ),
                    child: Icon(
                      isSelected
                          ? selectedIcon
                          : unselectedIcon,
                      key: ValueKey(
                        '${index}_$isSelected',
                      ),
                      size: isSelected ? 20 : 21,
                      color: isSelected
                          ? darkTextColor
                          : inactiveColor,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 3),

              // =================================================
              // LABEL
              // =================================================

              AnimatedDefaultTextStyle(
                duration: const Duration(
                  milliseconds: 200,
                ),
                style: GoogleFonts.poppins(
                  fontSize: 8.5,
                  fontWeight: isSelected
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: isSelected
                      ? darkTextColor
                      : inactiveColor,
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}