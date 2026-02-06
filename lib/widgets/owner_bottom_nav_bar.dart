import 'package:flutter/material.dart';
import '../config/theme_config.dart';
import '../screens/booking/today_bookings_screen.dart';

/// Custom bottom navigation bar for lounge owners
class OwnerBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final String? verificationStatus;

  const OwnerBottomNavBar({
    super.key,
    required this.currentIndex,
    this.verificationStatus,
  });

  @override
  Widget build(BuildContext context) {
    final isApproved = verificationStatus == 'approved';

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
                isEnabled: true, // Always enabled
                onTap: () {
                  if (currentIndex != 0) {
                    Navigator.pushReplacementNamed(context, '/home');
                  }
                },
              ),
              _buildNavItem(
                context: context,
                icon: Icons.store_outlined,
                activeIcon: Icons.store,
                label: 'Lounges',
                index: 1,
                isActive: currentIndex == 1,
                isEnabled: isApproved, // Only enabled when approved
                onTap: () {
                  if (!isApproved) {
                    _showLockedMessage(context);
                    return;
                  }
                  if (currentIndex != 1) {
                    Navigator.pushReplacementNamed(context, '/lounges');
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
                isEnabled: isApproved, // Only enabled when approved
                onTap: () {
                  if (!isApproved) {
                    _showLockedMessage(context);
                    return;
                  }
                  if (currentIndex != 2) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const TodayBookingsScreen(isStaffMode: false),
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
                isEnabled: true, // Always enabled
                onTap: () {
                  if (currentIndex != 3) {
                    Navigator.pushNamed(context, '/profile');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLockedMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'This feature is locked. Please wait for admin approval.',
        ),
        backgroundColor: AppColors.warning,
        duration: Duration(seconds: 2),
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
    required bool isEnabled,
    required VoidCallback onTap,
  }) {
    final effectiveColor = !isEnabled
        ? Colors.grey.shade400
        : (isActive ? AppColors.primary : Colors.grey.shade600);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Opacity(
          opacity: isEnabled ? 1.0 : 0.5,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        isActive ? activeIcon : icon,
                        color: effectiveColor,
                        size: 24,
                      ),
                      if (!isEnabled)
                        Positioned(
                          right: -4,
                          top: -4,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.lock,
                              size: 10,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: effectiveColor,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
