import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme_config.dart';
import '../../presentation/providers/lounge_staff_provider.dart';
import '../../presentation/providers/registration_provider.dart';

class StaffListPage extends StatefulWidget {
  const StaffListPage({super.key});

  @override
  State<StaffListPage> createState() => _StaffListPageState();
}

class _StaffListPageState extends State<StaffListPage> {
  String _selectedFilter = 'all'; // all, approved, pending

  @override
  void initState() {
    super.initState();
    // Schedule the load after the widget is built and has context access
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStaffList();
    });
  }

  Future<void> _loadStaffList() async {
    final staffProvider = context.read<LoungeStaffProvider>();
    final registrationProvider = context.read<RegistrationProvider>();

    // Get the first lounge ID from owner's lounges
    final lounges = registrationProvider.myLounges;
    if (lounges.isEmpty) {
      // Load lounges first if not loaded
      await registrationProvider.loadMyLounges();
    }

    final firstLoungeId = registrationProvider.myLounges.isNotEmpty
        ? registrationProvider.myLounges.first.id
        : null;

    if (firstLoungeId != null) {
      if (_selectedFilter == 'all') {
        await staffProvider.getStaffByLounge(loungeId: firstLoungeId);
      } else {
        await staffProvider.getStaffByApprovalStatus(
          loungeId: firstLoungeId,
          approvalStatus: _selectedFilter,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Staff List',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list, color: AppColors.textPrimary),
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
              _loadStaffList();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All Staff')),
              const PopupMenuItem(value: 'approved', child: Text('Approved')),
              const PopupMenuItem(value: 'pending', child: Text('Pending')),
            ],
          ),
        ],
      ),
      body: Consumer<LoungeStaffProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(provider.error!, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadStaffList,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final staffList = provider.staffList;

          if (staffList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.people_outline,
                      size: 64, color: AppColors.textSecondary),
                  const SizedBox(height: 16),
                  Text(
                    _selectedFilter == 'pending'
                        ? 'No pending staff'
                        : 'No staff members yet',
                    style: const TextStyle(
                      fontSize: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadStaffList,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_selectedFilter == 'pending') ...[
                  const SectionTitle(title: 'Pending Approval'),
                  ...provider.pendingStaff
                      .map((staff) => StaffCard(staff: staff)),
                ],
                if (_selectedFilter == 'approved') ...[
                  const SectionTitle(title: 'Approved Staff'),
                  ...provider.approvedStaff
                      .map((staff) => StaffCard(staff: staff)),
                ],
                if (_selectedFilter == 'all') ...[
                  if (provider.pendingStaff.isNotEmpty) ...[
                    const SectionTitle(title: 'Pending Approval'),
                    ...provider.pendingStaff
                        .map((staff) => StaffCard(staff: staff)),
                    const SizedBox(height: 24),
                  ],
                  const SectionTitle(title: 'Active Staff'),
                  ...provider.activeStaff
                      .map((staff) => StaffCard(staff: staff)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

/// ---------------- SECTION TITLE ----------------
class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

/// ---------------- STAFF CARD ----------------
class StaffCard extends StatelessWidget {
  final dynamic staff; // LoungeStaff entity

  const StaffCard({
    super.key,
    required this.staff,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd-MM-yyyy');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: staff.isApproved ? AppColors.success : AppColors.primary,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: const Icon(Icons.person, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  staff.fullName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              StatusChip(isApproved: staff.isApproved),
            ],
          ),
          const SizedBox(height: 12),

          InfoRow(label: 'Phone Number', value: staff.phone ?? 'N/A'),
          InfoRow(label: 'NIC', value: staff.nicNumber),
          if (staff.email != null) InfoRow(label: 'Email', value: staff.email!),
          if (staff.hiredDate != null)
            InfoRow(
                label: 'Hired Date',
                value: dateFormat.format(staff.hiredDate!)),
          if (staff.terminatedDate != null)
            InfoRow(
                label: 'Terminated Date',
                value: dateFormat.format(staff.terminatedDate!)),
          InfoRow(
            label: 'Employment Status',
            value: staff.employmentStatus.toUpperCase(),
          ),
          if (staff.notes != null && staff.notes!.isNotEmpty)
            InfoRow(label: 'Notes', value: staff.notes!),
        ],
      ),
    );
  }
}

/// ---------------- STATUS CHIP ----------------
class StatusChip extends StatelessWidget {
  final bool isApproved;

  const StatusChip({super.key, required this.isApproved});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isApproved
            ? AppColors.success.withOpacity(0.3)
            : AppColors.warning.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isApproved ? 'Approved' : 'Approve',
        style: TextStyle(
          color: isApproved ? AppColors.textPrimary : AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

/// ---------------- INFO ROW ----------------
class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style:
                  const TextStyle(fontSize: 13, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
