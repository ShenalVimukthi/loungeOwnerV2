import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_config.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/providers/lounge_booking_provider.dart';
import '../../presentation/providers/lounge_staff_provider.dart';
import '../../widgets/staff_bottom_nav_bar.dart';
import '../bus_sedule/upcoming_bus_schedule.dart';
import '../bus/qr_scanner_screen.dart';
import '../lounge/loungedetails_page.dart';
import '../booking/today_bookings_screen.dart';
import 'staff_profile_page.dart';

class StaffDashboardScreen extends StatefulWidget {
  const StaffDashboardScreen({super.key});

  @override
  State<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen> {
  int _todayBookingsCount = 0;
  int _todayOrdersCount = 0;
  Timer? _overviewRefreshTimer;
  bool _isRefreshingOverview = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final loungeStaffProvider = Provider.of<LoungeStaffProvider>(
        context,
        listen: false,
      );

      if (loungeStaffProvider.selectedStaff == null &&
          !loungeStaffProvider.isLoading) {
        await loungeStaffProvider.getMyStaffProfile();
      }

      await _loadTodayOverviewCounts();
      _startOverviewAutoRefresh();
    });
  }

  void _startOverviewAutoRefresh() {
    _overviewRefreshTimer?.cancel();
    _overviewRefreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) {
        if (!mounted || _isRefreshingOverview) return;
        _loadTodayOverviewCounts();
      },
    );
  }

  Future<void> _loadTodayOverviewCounts() async {
    if (_isRefreshingOverview) return;
    _isRefreshingOverview = true;

    final loungeStaffProvider = Provider.of<LoungeStaffProvider>(
      context,
      listen: false,
    );
    final bookingProvider = Provider.of<LoungeBookingProvider>(
      context,
      listen: false,
    );

    final now = DateTime.now();
    final dateFilter = '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';

    try {
      final bookingsResult = await bookingProvider.getStaffBookings(
        date: dateFilter,
        limit: 100,
      );

      int ordersCount = 0;

      final loungeIdFromProfile = loungeStaffProvider.selectedStaff?.loungeId;
      final loungeIdFromBookings = bookingsResult?['lounge_id']?.toString();
      final loungeId =
          (loungeIdFromProfile != null && loungeIdFromProfile.isNotEmpty)
              ? loungeIdFromProfile
              : loungeIdFromBookings;

      if (loungeId != null && loungeId.isNotEmpty) {
        try {
          final bookingsWithOrders = await bookingProvider.remoteDataSource
              .getLoungeBookingsWithOrders(
            loungeId: loungeId,
            bookingDate: dateFilter,
            date: dateFilter,
            limit: 100,
            offset: 0,
          );

          print('📊 [Staff Dashboard] Bookings with Orders Response:');
          print('   Lounge ID: $loungeId');
          print('   Date: $dateFilter');
          print('   Response: $bookingsWithOrders');

          final totalOrdersRaw = bookingsWithOrders['total_orders'];
          print(
              '   Total Orders Raw: $totalOrdersRaw (type: ${totalOrdersRaw.runtimeType})');
          ordersCount = totalOrdersRaw is int
              ? totalOrdersRaw
              : int.tryParse(totalOrdersRaw?.toString() ?? '0') ?? 0;
          print('   Total Orders Count: $ordersCount');
        } catch (e) {
          print('❌ [Staff Dashboard] Error fetching bookings with orders: $e');
          ordersCount = 0;
        }
      }

      if (ordersCount == 0 && bookingProvider.bookings.isNotEmpty) {
        print(
            '📋 [Staff Dashboard] Falling back to per-booking orders (${bookingProvider.bookings.length} bookings)');
        for (final booking in bookingProvider.bookings) {
          try {
            final bookingWithOrders =
                await bookingProvider.remoteDataSource.getBookingWithOrders(
              bookingId: booking.id,
              date: dateFilter,
            );

            print(
                '   Booking ${booking.id} orders: ${bookingWithOrders['orders_count']}');

            final ordersRaw = bookingWithOrders['orders_count'];
            ordersCount += ordersRaw is int
                ? ordersRaw
                : int.tryParse(ordersRaw?.toString() ?? '0') ?? 0;
          } catch (e) {
            print('   ❌ Error fetching orders for booking ${booking.id}: $e');
            continue;
          }
        }
        print('   📋 Total Orders after fallback: $ordersCount');
      }

      if (!mounted) return;

      setState(() {
        _todayBookingsCount = bookingProvider.bookings.length;
        _todayOrdersCount = ordersCount;
      });

      print(
          '✅ [Staff Dashboard] Overview updated - Bookings: $_todayBookingsCount, Orders: $_todayOrdersCount');
    } finally {
      _isRefreshingOverview = false;
    }
  }

  @override
  void dispose() {
    _overviewRefreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color pageBg = Color(0xFFFFFBF5);

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        backgroundColor: pageBg,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Staff Dashboard',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black87),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StaffProfilePage(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Consumer2<AuthProvider, LoungeStaffProvider>(
                      builder: (context, authProvider, staffProvider, _) {
                        final user = authProvider.user;
                        final staff = staffProvider.selectedStaff;
                        final staffName =
                            staff?.fullName ?? user?.firstName ?? 'Staff';

                        return Row(
                          children: [
                            const Icon(
                              Icons.wb_sunny_outlined,
                              color: Colors.white,
                              size: 28,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Welcome Back, $staffName!',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ready to serve customers today',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Today's Stats
              const Text(
                'Today\'s Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'Orders',
                      value: _todayOrdersCount.toString(),
                      icon: Icons.receipt_long,
                      color: Colors.blue.shade600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Bookings',
                      value: _todayBookingsCount.toString(),
                      icon: Icons.event_available,
                      color: Colors.green.shade600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Quick Actions
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.3,
                children: [
                  _buildActionTile(
                    context: context,
                    label: 'Bus Schedule',
                    icon: Icons.directions_bus,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BusScheduleScreen(),
                        ),
                      );
                    },
                  ),
                  _buildActionTile(
                    context: context,
                    label: 'Lounge Profile',
                    icon: Icons.storefront,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoungeDetailsPage(),
                        ),
                      );
                    },
                  ),
                  _buildActionTile(
                    context: context,
                    label: 'QR Scanner',
                    icon: Icons.qr_code_scanner,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const QrScannerScreen(),
                        ),
                      );
                    },
                  ),
                  _buildActionTile(
                    context: context,
                    label: 'View Bookings',
                    icon: Icons.calendar_today,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const TodayBookingsScreen(isStaffMode: true),
                        ),
                      );

                      if (!mounted) return;
                      _loadTodayOverviewCounts();
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Recent Activity
              const Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              _buildActivityItem(
                title: 'Order #1234 completed',
                time: '10 minutes ago',
                icon: Icons.check_circle,
                iconColor: Colors.green.shade600,
              ),
              _buildActivityItem(
                title: 'New booking received',
                time: '25 minutes ago',
                icon: Icons.event,
                iconColor: Colors.blue.shade600,
              ),
              _buildActivityItem(
                title: 'Order #1233 in progress',
                time: '45 minutes ago',
                icon: Icons.pending_actions,
                iconColor: AppColors.primary,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const StaffBottomNavBar(
        currentIndex: 0,
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 24, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 32, color: AppColors.primary),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem({
    required String title,
    required String time,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
