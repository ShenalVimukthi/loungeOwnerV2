import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import '../../config/constants.dart';
import '../../config/theme_config.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../presentation/providers/lounge_staff_provider.dart';

/// Pending Approval Screen for Lounge Staff
/// Shown after staff completes registration with OTP
/// Displays approval status and allows checking status or logging out
class StaffPendingApprovalScreen extends StatefulWidget {
  const StaffPendingApprovalScreen({
    super.key,
  });

  @override
  State<StaffPendingApprovalScreen> createState() =>
      _StaffPendingApprovalScreenState();
}

class _StaffPendingApprovalScreenState
    extends State<StaffPendingApprovalScreen> {
  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final provider = Provider.of<LoungeStaffProvider>(context, listen: false);
    await provider.getMyStaffProfile();
  }

  Future<void> _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.logout();

    if (success && mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/role-selection',
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent back button
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Pending Icon with animation
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 800),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: 0.5 + (value * 0.5),
                        child: Opacity(
                          opacity: value,
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.warning.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.hourglass_top,
                        size: 60,
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Title
                  Text(
                    'Pending Approval',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    'Your registration has been submitted successfully.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The lounge owner will review your application and notify you once approved.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 32),

                  // Status Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.divider,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Consumer<LoungeStaffProvider>(
                          builder: (context, provider, _) {
                            final staff = provider.selectedStaff;
                            final status = staff?.approvalStatus ?? 'pending';
                            final statusText = status == 'approved'
                                ? 'Approved'
                                : status == 'declined'
                                    ? 'Declined'
                                    : 'Pending Review';
                            final statusColor = status == 'approved'
                                ? AppColors.success
                                : status == 'declined'
                                    ? AppColors.error
                                    : AppColors.warning;

                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.pending_actions,
                                        color: statusColor,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Status',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            statusText,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: statusColor,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                if (staff != null) ...[
                                  _InfoRow(
                                    label: 'Full Name',
                                    value: staff.fullName,
                                  ),
                                  const SizedBox(height: 6),
                                  _InfoRow(
                                    label: 'Phone',
                                    value: staff.phone ?? 'Not available',
                                  ),
                                  const SizedBox(height: 6),
                                  _InfoRow(
                                    label: 'Email',
                                    value: staff.email ?? 'Not available',
                                  ),
                                ],
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Info Boxes
                  _InfoBox(
                    icon: Icons.check_circle_outline,
                    iconColor: AppColors.success,
                    title: 'What happens next?',
                    description:
                        'The lounge owner will receive a notification about your registration request.',
                  ),
                  const SizedBox(height: 12),
                  _InfoBox(
                    icon: Icons.notifications_active,
                    iconColor: AppColors.primary,
                    title: 'Stay tuned',
                    description:
                        'You will receive a notification once your application is approved.',
                  ),
                  const SizedBox(height: 12),
                  _InfoBox(
                    icon: Icons.schedule,
                    iconColor: AppColors.info,
                    title: 'Expected timeframe',
                    description:
                        'Most applications are reviewed within 24-48 hours.',
                  ),
                  const SizedBox(height: 40),

                  // Buttons
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Check status feature coming soon'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        _logger.i('📱 Check status button pressed');
                      },
                      text: 'Check Status',
                      isOutlined: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      onPressed: _logout,
                      text: 'Logout',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Reusable info box widget
class _InfoBox extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  const _InfoBox({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: iconColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: iconColor,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
          ),
        ),
      ],
    );
  }
}
