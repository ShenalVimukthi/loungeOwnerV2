import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/staff_bottom_nav_bar.dart';
import '../../screens/splash_screen.dart';
import '../../presentation/providers/auth_provider.dart';
import 'staff_edit_profile_page.dart';

class StaffProfilePage extends StatelessWidget {
  const StaffProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F5F1),

      /// APP BAR
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),

      /// BODY
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// PROFILE CARD
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  /// AVATAR
                  CircleAvatar(
                    radius: 38,
                    backgroundColor: Colors.blue.shade100,
                    child: const Icon(
                      Icons.person,
                      size: 38,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 12),

                  /// NAME
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      final user = authProvider.user;
                      return Text(
                        user?.firstName ?? 'Guest',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),

                  /// ROLE & STATUS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _InfoChip(
                        text: 'Staff Member',
                        bgColor: Colors.blue.shade100,
                        textColor: Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, _) {
                          final user = authProvider.user;
                          return _InfoChip(
                            text: user?.phoneVerified == true
                                ? 'Verified'
                                : 'Unverified',
                            bgColor: user?.phoneVerified == true
                                ? Colors.green.shade100
                                : Colors.orange.shade100,
                            textColor: user?.phoneVerified == true
                                ? Colors.green
                                : Colors.orange,
                            icon: user?.phoneVerified == true
                                ? Icons.check_circle
                                : Icons.pending,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// CONTACT INFORMATION
            Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                final user = authProvider.user;
                return _SectionCard(
                  title: 'Contact Information',
                  children: [
                    _InfoTile(
                      icon: Icons.phone,
                      title: 'Phone Number',
                      value: user?.phoneNumber ?? 'Not available',
                    ),
                    _InfoTile(
                      icon: Icons.person,
                      title: 'Full Name',
                      value: user?.firstName ?? 'Not available',
                    ),
                    if (user?.nic != null)
                      _InfoTile(
                        icon: Icons.badge,
                        title: 'NIC Number',
                        value: user!.nic!,
                      ),
                  ],
                );
              },
            ),

            const SizedBox(height: 16),

            /// EDIT PROFILE
            _ActionTile(
              icon: Icons.edit,
              title: 'Edit Profile',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StaffEditProfilePage(),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            /// LOGOUT BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final authProvider = Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  );
                  await authProvider.logout();
                  // Navigate to Splash and clear stack
                  if (!context.mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const SplashScreen()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      /// BOTTOM NAV
      bottomNavigationBar: const StaffBottomNavBar(currentIndex: 3),
    );
  }
}

/// ---------------- INFO CHIP ----------------
class _InfoChip extends StatelessWidget {
  final String text;
  final Color bgColor;
  final Color textColor;
  final IconData? icon;

  const _InfoChip({
    required this.text,
    required this.bgColor,
    required this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------- SECTION CARD ----------------
class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

/// ---------------- INFO TILE ----------------
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.blue.shade50,
            child: Icon(icon, size: 18, color: Colors.blue),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}

/// ---------------- ACTION TILE ----------------
class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.blue.shade50,
              child: Icon(icon, size: 18, color: Colors.blue),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Edit Profile',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
