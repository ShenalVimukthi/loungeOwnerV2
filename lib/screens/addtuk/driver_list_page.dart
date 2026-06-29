import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme_config.dart';
import '../../presentation/providers/driver_provider.dart';
import '../../presentation/providers/registration_provider.dart';
import 'add_tuk_tuk_page.dart';

class DriverListPage extends StatefulWidget {
  const DriverListPage({super.key});

  @override
  State<DriverListPage> createState() => _DriverListPageState();
}

class _DriverListPageState extends State<DriverListPage> {
  String? _selectedLoungeId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLounges();
    });
  }

  Future<void> _initializeLounges() async {
    final registrationProvider = context.read<RegistrationProvider>();

    if (registrationProvider.myLounges.isEmpty) {
      await registrationProvider.loadMyLounges();
    }

    final verifiedLounges = registrationProvider.verifiedLounges;
    if (verifiedLounges.isNotEmpty) {
      final preferredLoungeId = registrationProvider.preferredVerifiedLoungeId;
      setState(() {
        _selectedLoungeId = preferredLoungeId ?? verifiedLounges.first.id;
      });
      _loadDriverList();
    }
  }

  Future<void> _loadDriverList() async {
    final driverProvider = context.read<DriverProvider>();

    if (_selectedLoungeId == null) {
      return;
    }

    await driverProvider.getDriversByLounge(loungeId: _selectedLoungeId!);
  }

  Future<void> _confirmDeleteDriver(String driverId) async {
    if (_selectedLoungeId == null) return;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Driver'),
        content: const Text(
          'Are you sure you want to remove this driver from the lounge?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    final driverProvider = context.read<DriverProvider>();
    final success = await driverProvider.removeDriver(
      loungeId: _selectedLoungeId!,
      driverId: driverId,
      showLoading: false,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Driver removed successfully'
              : (driverProvider.error ?? 'Failed to remove driver'),
        ),
      ),
    );

    if (!success) {
      driverProvider.clearError();
    }
  }

  Future<void> _showEditDriverSheet(dynamic driver) async {
    if (_selectedLoungeId == null) return;

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _EditDriverSheet(
        driver: driver,
        loungeId: _selectedLoungeId!,
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Driver updated successfully')),
      );
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
          'Driver List',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer2<DriverProvider, RegistrationProvider>(
        builder: (context, driverProvider, registrationProvider, _) {
          if (driverProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (driverProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(driverProvider.error!,
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadDriverList,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final verifiedLounges = registrationProvider.verifiedLounges;
          if (verifiedLounges.isEmpty) {
            return const Center(
              child: Text(
                'No verified lounges yet',
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
            );
          }

          final driverList = driverProvider.driverList;

          return RefreshIndicator(
            onRefresh: _loadDriverList,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Lounge Selection Dropdown
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    underline: Container(),
                    hint: const Text('Select Lounge'),
                    value: verifiedLounges
                            .any((lounge) => lounge.id == _selectedLoungeId)
                        ? _selectedLoungeId
                        : null,
                    items: verifiedLounges.map((lounge) {
                      return DropdownMenuItem<String>(
                        value: lounge.id,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                lounge.loungeName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedLoungeId = value;
                        });
                        context
                            .read<RegistrationProvider>()
                            .setActiveLoungeId(value);
                        _loadDriverList();
                      }
                    },
                  ),
                ),
                // Driver list
                if (driverList.isEmpty && _selectedLoungeId != null)
                  const Padding(
                    padding: EdgeInsets.only(top: 48),
                    child: Column(
                      children: [
                        Icon(
                          Icons.local_taxi_outlined,
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No drivers yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...driverList.map(
                    (driver) => DriverCard(
                      driver: driver,
                      onDelete: () => _confirmDeleteDriver(driver.id),
                      onEdit: () => _showEditDriverSheet(driver),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTukTukPage(),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textLight,
        icon: const Icon(Icons.add),
        label: const Text(
          'Add Driver',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

/// ---------------- DRIVER CARD ----------------
class DriverCard extends StatelessWidget {
  final dynamic driver;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const DriverCard({
    super.key,
    required this.driver,
    this.onDelete,
    this.onEdit,
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
        border: Border.all(color: AppColors.primary),
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
                child: const Icon(Icons.local_taxi, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  driver.fullName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (onEdit != null) ...[
                const SizedBox(width: 4),
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: AppColors.primary,
                  ),
                  tooltip: 'Edit driver',
                ),
              ],
              if (onDelete != null) ...[
                const SizedBox(width: 4),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                  ),
                  tooltip: 'Delete driver',
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),

          InfoRow(label: 'Contact', value: driver.contactNumber),
          InfoRow(label: 'NIC', value: driver.nicNumber),
          InfoRow(label: 'Vehicle Number', value: driver.vehicleNumber),
          InfoRow(
            label: 'Vehicle Type',
            value: driver.vehicleType.toUpperCase().replaceAll('_', ' '),
          ),
          InfoRow(
            label: 'Added Date',
            value: dateFormat.format(driver.createdAt),
          ),
        ],
      ),
    );
  }
}

/// ---------------- EDIT DRIVER BOTTOM SHEET ----------------
class _EditDriverSheet extends StatefulWidget {
  final dynamic driver;
  final String loungeId;

  const _EditDriverSheet({
    required this.driver,
    required this.loungeId,
  });

  @override
  State<_EditDriverSheet> createState() => _EditDriverSheetState();
}

class _EditDriverSheetState extends State<_EditDriverSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _contactController;
  late final TextEditingController _nicController;
  late final TextEditingController _vehicleNoController;
  late String _selectedVehicleType;
  bool _isSaving = false;

  static const List<String> _vehicleTypes = [
    'three_wheeler',
    'car',
    'van',
  ];

  static const Map<String, String> _vehicleTypeLabels = {
    'three_wheeler': 'Three Wheeler',
    'car': 'Car',
    'van': 'Van',
  };

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.driver.fullName);
    _contactController =
        TextEditingController(text: widget.driver.contactNumber);
    _nicController = TextEditingController(text: widget.driver.nicNumber);
    _vehicleNoController =
        TextEditingController(text: widget.driver.vehicleNumber);
    _selectedVehicleType = widget.driver.vehicleType;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _nicController.dispose();
    _vehicleNoController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    // Only send fields that actually changed
    final String? newName = _nameController.text.trim() != widget.driver.fullName
        ? _nameController.text.trim()
        : null;
    final String? newContact =
        _contactController.text.trim() != widget.driver.contactNumber
            ? _contactController.text.trim()
            : null;
    final String? newNic =
        _nicController.text.trim() != widget.driver.nicNumber
            ? _nicController.text.trim()
            : null;
    final String? newVehicleNo =
        _vehicleNoController.text.trim() != widget.driver.vehicleNumber
            ? _vehicleNoController.text.trim()
            : null;
    final String? newVehicleType =
        _selectedVehicleType != widget.driver.vehicleType
            ? _selectedVehicleType
            : null;

    // Nothing changed
    if (newName == null &&
        newContact == null &&
        newNic == null &&
        newVehicleNo == null &&
        newVehicleType == null) {
      if (mounted) Navigator.pop(context, false);
      return;
    }

    final driverProvider = context.read<DriverProvider>();
    final success = await driverProvider.updateDriver(
      loungeId: widget.loungeId,
      driverId: widget.driver.id,
      fullName: newName,
      nicNumber: newNic,
      contactNumber: newContact,
      vehicleNumber: newVehicleNo,
      vehicleType: newVehicleType,
    );

    if (!mounted) return;

    setState(() => _isSaving = false);

    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(driverProvider.error ?? 'Failed to update driver'),
          backgroundColor: AppColors.error,
        ),
      );
      driverProvider.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: 16 + bottomInset,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              const Text(
                'Edit Driver Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),

              // Full Name
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration('Full Name', Icons.person_outline),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  }
                  if (value.trim().length < 2) {
                    return 'Name must be at least 2 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Contact Number
              TextFormField(
                controller: _contactController,
                decoration:
                    _inputDecoration('Contact Number', Icons.phone_outlined),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Contact number is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // NIC Number
              TextFormField(
                controller: _nicController,
                decoration:
                    _inputDecoration('NIC Number', Icons.credit_card_outlined),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'NIC number is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Vehicle Number
              TextFormField(
                controller: _vehicleNoController,
                decoration: _inputDecoration(
                    'Vehicle Number', Icons.directions_car_outlined),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vehicle number is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Vehicle Type Dropdown
              DropdownButtonFormField<String>(
                value: _selectedVehicleType,
                decoration:
                    _inputDecoration('Vehicle Type', Icons.local_taxi_outlined),
                items: _vehicleTypes.map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(_vehicleTypeLabels[type] ?? type),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedVehicleType = value);
                  }
                },
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isSaving ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textLight,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Save Changes',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20, color: AppColors.primary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
