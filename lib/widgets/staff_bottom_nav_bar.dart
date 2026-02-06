import 'package:flutter/material.dart';
import '../config/theme_config.dart';
import '../screens/booking/today_bookings_screen.dart';
import '../screens/lounge/loungedetails_page.dart';
import '../screens/staff/staff_dashboard_screen.dart';
import '../screens/staff/staff_profile_page.dart';

/// Custom bottom navigation bar for staff members
class StaffBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const StaffBottomNavBar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context: context,
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Home',
                index: 0,
                isActive: currentIndex == 0,
                onTap: () {
                  if (currentIndex != 0) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StaffDashboardScreen(),
                      ),
                      (route) => false,
                    );
                  }
                },
              ),
              _buildNavItem(
                context: context,
                icon: Icons.store_outlined,
                activeIcon: Icons.store,
                label: 'Lounge',
                index: 1,
                isActive: currentIndex == 1,
                onTap: () {
                  if (currentIndex != 1) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoungeDetailsPage(),
                      ),
                    );
                  }
                },
              ),
              _buildNavItem(
                context: context,
                icon: Icons.calendar_today_outlined,
                activeIcon: Icons.calendar_today,
                label: 'Bookings',
                index: 2,
                isActive: currentIndex == 2,
                onTap: () {
                  if (currentIndex != 2) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TodayBookingsScreen(isStaffMode: true),
                      ),
                    );
                  }
                },
              ),
              _buildNavItem(
                context: context,
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Profile',
                index: 3,
                isActive: currentIndex == 3,
                onTap: () {
                  if (currentIndex != 3) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StaffProfilePage(),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isActive ? activeIcon : icon,
                color: isActive ? AppColors.primary : Colors.grey.shade600,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: isActive ? AppColors.primary : Colors.grey.shade600,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
