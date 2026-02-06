import 'package:flutter/material.dart';
import '../../widgets/staff_bottom_nav_bar.dart';
import '../../config/theme_config.dart';

class BusScheduleScreen extends StatefulWidget {
  const BusScheduleScreen({super.key});

  @override
  State<BusScheduleScreen> createState() => _BusScheduleScreenState();
}

class _BusScheduleScreenState extends State<BusScheduleScreen> {
  // Sample bus schedules with more data
  final List<Map<String, dynamic>> _schedules = [
    {
      'busNumber': 'Express 101',
      'route': 'Colombo - Negombo',
      'time': '1:00 PM',
      'status': 'On Time',
      'platform': '3',
    },
    {
      'busNumber': 'Express 205',
      'route': 'Colombo - Kandy',
      'time': '2:30 PM',
      'status': 'On Time',
      'platform': '5',
    },
    {
      'busNumber': 'Express 312',
      'route': 'Colombo - Galle',
      'time': '3:15 PM',
      'status': 'Delayed',
      'platform': '2',
    },
    {
      'busNumber': 'Express 408',
      'route': 'Colombo - Jaffna',
      'time': '4:00 PM',
      'status': 'On Time',
      'platform': '7',
    },
  ];

  @override
  Widget build(BuildContext context) {
    const Color pageBg = Color(0xFFFFFBF5);

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        backgroundColor: pageBg,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: Colors.black87,
          ),
        ),
        title: const Text(
          'Upcoming Bus Schedule',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add_circle_outline,
              color: AppColors.primary,
            ),
            onPressed: () {
              _showAddScheduleDialog();
            },
            tooltip: 'Add Schedule',
          ),
        ],
      ),
      bottomNavigationBar: const StaffBottomNavBar(currentIndex: 3),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.directions_bus,
                        size: 48,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Today\'s Bus Schedule',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Next arrivals and departures',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Schedule List
              const Text(
                'Upcoming Departures',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              ..._schedules.map(
                (schedule) => BusCard(
                  busNumber: schedule['busNumber']!,
                  route: schedule['route']!,
                  time: schedule['time']!,
                  status: schedule['status']!,
                  platform: schedule['platform']!,
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddScheduleDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Add Bus Schedule',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: const Text(
          'Schedule creation form will be implemented here.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Close', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Feature coming soon!'),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class BusCard extends StatelessWidget {
  final String busNumber;
  final String route;
  final String time;
  final String status;
  final String platform;

  const BusCard({
    super.key,
    required this.busNumber,
    required this.route,
    required this.time,
    required this.status,
    required this.platform,
  });

  @override
  Widget build(BuildContext context) {
    final isDelayed = status == 'Delayed';
    final statusColor = isDelayed
        ? Colors.orange.shade700
        : Colors.green.shade700;
    final statusBgColor = isDelayed
        ? Colors.orange.shade50
        : Colors.green.shade50;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.directions_bus,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        busNumber,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        route,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Details Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoItem(
                  Icons.access_time,
                  'Departure',
                  time,
                  AppColors.primary,
                ),
                Container(height: 40, width: 1, color: Colors.grey.shade300),
                _buildInfoItem(
                  Icons.confirmation_number_outlined,
                  'Platform',
                  platform,
                  Colors.blue.shade600,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
