import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_config.dart';
import '../../presentation/providers/driver_provider.dart';

class TukTukListPage extends StatefulWidget {
  final String? loungeId;
  final String? bookingId;
  final String? guestName;
  final String? guestContact;

  const TukTukListPage({
    super.key,
    this.loungeId,
    this.bookingId,
    this.guestName,
    this.guestContact,
  });

  @override
  State<TukTukListPage> createState() => _TukTukListPageState();
}

class _TukTukListPageState extends State<TukTukListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.loungeId != null) {
        context.read<DriverProvider>().getDriversByLounge(
              loungeId: widget.loungeId!,
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Drivers & Vehicles',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: Consumer<DriverProvider>(
        builder: (context, driverProvider, _) {
          if (driverProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (driverProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 60,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    driverProvider.error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red.shade400),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (widget.loungeId != null) {
                        context.read<DriverProvider>().getDriversByLounge(
                              loungeId: widget.loungeId!,
                            );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final drivers = driverProvider.driverList;

          if (drivers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.directions_car_outlined,
                    size: 60,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No drivers found',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: drivers.length,
            itemBuilder: (context, index) {
              final driver = drivers[index];
              return TukTukCard(
                driverId: driver.id,
                bookingId: widget.bookingId,
                loungeId: widget.loungeId,
                guestName: widget.guestName,
                guestContact: widget.guestContact,
                name: driver.fullName,
                vehicleNo: driver.vehicleNumber,
                phone: driver.contactNumber,
              );
            },
          );
        },
      ),
    );
  }
}

class TukTukCard extends StatefulWidget {
  final String driverId;
  final String? bookingId;
  final String? loungeId;
  final String? guestName;
  final String? guestContact;
  final String name;
  final String vehicleNo;
  final String phone;

  const TukTukCard({
    super.key,
    required this.driverId,
    this.bookingId,
    this.loungeId,
    this.guestName,
    this.guestContact,
    required this.name,
    required this.vehicleNo,
    required this.phone,
  });

  @override
  State<TukTukCard> createState() => _TukTukCardState();
}

class _TukTukCardState extends State<TukTukCard> {
  bool _isAssigning = false;

  Future<void> _assignDriver() async {
    if (widget.bookingId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Booking ID is required to assign a driver'),
          backgroundColor: Colors.red.shade600,
        ),
      );
      return;
    }

    if (widget.loungeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Lounge ID is required to assign a driver'),
          backgroundColor: Colors.red.shade600,
        ),
      );
      return;
    }

    if (widget.guestName == null || widget.guestName!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Guest name is required to assign a driver'),
          backgroundColor: Colors.red.shade600,
        ),
      );
      return;
    }

    if (widget.guestContact == null || widget.guestContact!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Guest contact is required to assign a driver'),
          backgroundColor: Colors.red.shade600,
        ),
      );
      return;
    }

    setState(() => _isAssigning = true);

    try {
      final driverProvider = context.read<DriverProvider>();

      final success = await driverProvider.assignDriverToBooking(
        bookingId: widget.bookingId!,
        driverId: widget.driverId,
        loungeId: widget.loungeId!,
        guestName: widget.guestName!,
        guestContact: widget.guestContact!,
        driverContact: widget.phone,
      );

      if (!mounted) return;

      if (success) {
        final assignment = driverProvider.lastAssignment;

        if (!mounted) return;

        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Success Icon
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.green.shade600,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    const Text(
                      'Driver Assigned Successfully!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Details
                    if (assignment != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            _buildDetailRow(
                              'Driver: ',
                              widget.name,
                            ),
                            const SizedBox(height: 8),
                            _buildDetailRow(
                              'Vehicle: ',
                              widget.vehicleNo,
                            ),
                            const SizedBox(height: 8),
                            _buildDetailRow(
                              'Status: ',
                              assignment.status ?? 'Pending',
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 24),

                    // OK Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'OK',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );

        // Navigate back after dialog closes
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              driverProvider.error ?? 'Failed to assign driver',
              style: const TextStyle(fontSize: 13),
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red.shade600,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isAssigning = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Top Row (Avatar + Name)
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: const Icon(Icons.person, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Tuk Tuk',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// Vehicle Number
          Row(
            children: [
              const Icon(Icons.directions_car,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(widget.vehicleNo,
                  style: const TextStyle(color: AppColors.textPrimary)),
            ],
          ),

          const SizedBox(height: 8),

          /// Phone + Call Button
          Row(
            children: [
              const Icon(Icons.phone, size: 18, color: AppColors.success),
              const SizedBox(width: 8),
              Text(widget.phone,
                  style: const TextStyle(color: AppColors.textPrimary)),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.call, size: 16),
                label: const Text('Call'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: AppColors.textLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          /// Assign Driver Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.bookingId != null && !_isAssigning
                  ? _assignDriver
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.bookingId != null && !_isAssigning
                    ? AppColors.success
                    : Colors.grey.shade400,
                foregroundColor: AppColors.textLight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isAssigning
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.textLight),
                      ),
                    )
                  : const Text('Assign Driver',
                      style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
