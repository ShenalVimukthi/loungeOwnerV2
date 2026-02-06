// import 'package:flutter/material.dart';
// import '../../widgets/custom_bottom_nav_bar.dart';
// import '../bus_sedule/upcoming_bus_schedule.dart';
// import '../booking/today_bookings_screen.dart';
// import '../bus/qr_scanner_screen.dart';

// /// Dashboard statistics data model
// class DashboardStats {
//   final int currentBookings;
//   final int upcomingBookings;
//   final double todayRevenue;
//   final double occupancyRate;
//   final int totalLounges;
//   final int activeLounges;
//   final int pendingLounges;

//   DashboardStats({
//     required this.currentBookings,
//     required this.upcomingBookings,
//     required this.todayRevenue,
//     required this.occupancyRate,
//     required this.totalLounges,
//     required this.activeLounges,
//     required this.pendingLounges,
//   });
// }

// /// DashboardPage - Main dashboard screen for lounge owners
// ///
// /// Provides comprehensive overview of lounge operations including:
// /// - Account verification status banner
// /// - Real-time statistics (current bookings, upcoming bookings, revenue, occupancy)
// /// - Quick action buttons for common tasks
// /// - Management options for check-in/checkout and settings
// ///
// /// Features:
// /// - Pull-to-refresh functionality
// /// - API integration for live data
// /// - Error handling with retry option
// /// - Navigation to various management screens
// /// - Bottom navigation bar for app-wide navigation
// class DashboardPage extends StatefulWidget {
//   const DashboardPage({super.key});

//   @override
//   State<DashboardPage> createState() => _DashboardPageState();
// }

// class _DashboardPageState extends State<DashboardPage> {
//   // ==============================================================================
//   // STATE VARIABLES - Dashboard state management
//   // ==============================================================================

//   /// Account verification status - true when admin approves the lounge owner
//   bool isVerified = false;

//   /// Loading state indicator for API calls
//   bool _isLoading = true;

//   /// Dashboard statistics data from API
//   DashboardStats? _stats;

//   /// Error message to display if API call fails
//   String? _errorMessage;

//   // ==============================================================================
//   // CONFIGURATION - User and service configuration
//   // ==============================================================================

//   @override
//   void initState() {
//     super.initState();
//     _loadDashboardStats();
//   }

//   /// Fetches dashboard statistics from the API
//   ///
//   /// Handles loading states, success, and error scenarios.
//   /// Updates UI with fetched data or displays error messages.
//   Future<void> _loadDashboardStats() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     try {
//       // Simulate API delay
//       await Future.delayed(const Duration(milliseconds: 500));

//       // Use mock data instead of API call
//       setState(() {
//         _stats = DashboardStats(
//           currentBookings: 8,
//           upcomingBookings: 15,
//           todayRevenue: 125000.0,
//           occupancyRate: 78.5,
//           totalLounges: 3,
//           activeLounges: 2,
//           pendingLounges: 1,
//         );
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Failed to load dashboard data: $e';
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final bg = const Color(0xFFFFFBF5);

//     return Scaffold(
//       backgroundColor: bg,
//       appBar: AppBar(
//         backgroundColor: bg,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black87),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         title: const Text(
//           'Dashboard',
//           style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
//         ),
//         centerTitle: false,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh, color: Colors.black87),
//             onPressed: _loadDashboardStats,
//           ),
//         ],
//       ),
//       body: SafeArea(
//         child: _isLoading
//             ? const Center(child: CircularProgressIndicator())
//             : _errorMessage != null
//             ? Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Icon(
//                       Icons.error_outline,
//                       size: 64,
//                       color: Colors.red,
//                     ),
//                     const SizedBox(height: 16),
//                     Text(
//                       _errorMessage!,
//                       textAlign: TextAlign.center,
//                       style: const TextStyle(color: Colors.red),
//                     ),
//                     const SizedBox(height: 16),
//                     ElevatedButton(
//                       onPressed: _loadDashboardStats,
//                       child: const Text('Retry'),
//                     ),
//                   ],
//                 ),
//               )
//             : Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 18.0,
//                   vertical: 8,
//                 ),
//                 child: RefreshIndicator(
//                   onRefresh: _loadDashboardStats,
//                   child: SingleChildScrollView(
//                     physics: const AlwaysScrollableScrollPhysics(),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Verification Status Banner
//                         Container(
//                           width: double.infinity,
//                           padding: const EdgeInsets.all(16),
//                           decoration: BoxDecoration(
//                             color: isVerified
//                                 ? const Color(0xFFE8F5E9)
//                                 : const Color(0xFFFFF3E0),
//                             borderRadius: BorderRadius.circular(12),
//                             border: Border.all(
//                               color: isVerified
//                                   ? const Color(0xFF4CAF50)
//                                   : const Color(0xFFFFA726),
//                               width: 1.5,
//                             ),
//                           ),
//                           child: Row(
//                             children: [
//                               Icon(
//                                 isVerified
//                                     ? Icons.verified
//                                     : Icons.info_outline,
//                                 color: isVerified
//                                     ? const Color(0xFF2E7D32)
//                                     : const Color(0xFFF57C00),
//                                 size: 28,
//                               ),
//                               const SizedBox(width: 12),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       isVerified
//                                           ? 'Account Verified'
//                                           : 'Account Pending',
//                                       style: TextStyle(
//                                         color: isVerified
//                                             ? const Color(0xFF2E7D32)
//                                             : const Color(0xFFF57C00),
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 16,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 4),
//                                     Text(
//                                       isVerified
//                                           ? 'Your account has been approved by admin'
//                                           : 'Your account is under review',
//                                       style: TextStyle(
//                                         color: isVerified
//                                             ? const Color(0xFF388E3C)
//                                             : const Color(0xFFEF6C00),
//                                         fontSize: 13,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),

//                         const SizedBox(height: 18),

//                         // Stats cards row - WITH API DATA
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             _StatCard(
//                               title: 'Current Bookings',
//                               value: '${_stats?.currentBookings ?? 0}',
//                               icon: Icons.person,
//                               onTap: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) =>
//                                         const TodayBookingsScreen(),
//                                   ),
//                                 );
//                               },
//                             ),
//                             const SizedBox(width: 12),
//                             _StatCard(
//                               title: 'Upcoming Bookings',
//                               value: '${_stats?.upcomingBookings ?? 0}',
//                               icon: Icons.schedule,
//                               onTap: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) =>
//                                         const BusScheduleScreen(),
//                                   ),
//                                 );
//                               },
//                             ),
//                           ],
//                         ),

//                         const SizedBox(height: 24),

//                         const Text(
//                           'Quick Actions',
//                           style: TextStyle(
//                             color: Colors.black87,
//                             fontWeight: FontWeight.w700,
//                             fontSize: 18,
//                           ),
//                         ),
//                         const SizedBox(height: 16),

//                         // Quick actions grid
//                         GridView.count(
//                           crossAxisCount: 2,
//                           shrinkWrap: true,
//                           physics: const NeverScrollableScrollPhysics(),
//                           mainAxisSpacing: 16,
//                           crossAxisSpacing: 16,
//                           childAspectRatio: 1.4,
//                           children: [
//                             _ActionCard(
//                               label: 'Current Bookings',
//                               icon: Icons.event_available,
//                               color: const Color(0xFF4CAF50),
//                               onTap: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) =>
//                                         const TodayBookingsScreen(),
//                                   ),
//                                 );
//                               },
//                             ),
//                             _ActionCard(
//                               label: 'Bus Schedule',
//                               icon: Icons.directions_bus,
//                               color: const Color(0xFF2196F3),
//                               onTap: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) =>
//                                         const BusScheduleScreen(),
//                                   ),
//                                 );
//                               },
//                             ),
//                             _ActionCard(
//                               label: 'QR Scanner',
//                               icon: Icons.qr_code_scanner,
//                               color: const Color(0xFFFF9800),
//                               onTap: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) =>
//                                         const QrScannerScreen(),
//                                   ),
//                                 );
//                               },
//                             ),
//                             _ActionCard(
//                               label: 'Lounge Profile',
//                               icon: Icons.storefront,
//                               color: const Color(0xFF9C27B0),
//                               onTap: () {
//                                 Navigator.pushNamed(context, '/lounge/details');
//                               },
//                             ),
//                           ],
//                         ),

//                         const SizedBox(height: 36),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//       ),
//       // Bottom navigation bar
//       bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
//     );
//   }
// }

// /// Small stat card used in the dashboard
// class _StatCard extends StatelessWidget {
//   final String title;
//   final String value;
//   final IconData icon;
//   final bool small;
//   final VoidCallback? onTap;
//   const _StatCard({
//     required this.title,
//     required this.value,
//     required this.icon,
//     this.small = false,
//     this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(12),
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFEFF6F8),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Icon(icon, color: Colors.black54, size: small ? 18 : 20),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title,
//                       style: const TextStyle(
//                         fontSize: 12,
//                         color: Colors.black54,
//                       ),
//                     ),
//                     const SizedBox(height: 6),
//                     Text(
//                       value,
//                       style: const TextStyle(
//                         fontSize: 15,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// /// Colorful action card for quick actions
// class _ActionCard extends StatelessWidget {
//   final String label;
//   final IconData icon;
//   final Color color;
//   final VoidCallback onTap;
  
//   const _ActionCard({
//     required this.label,
//     required this.icon,
//     required this.color,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(20),
//       child: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [color, color.withOpacity(0.7)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: color.withOpacity(0.3),
//               blurRadius: 8,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(14),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.3),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 icon,
//                 size: 32,
//                 color: Colors.white,
//               ),
//             ),
//             const SizedBox(height: 12),
//             Text(
//               label,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 fontWeight: FontWeight.w600,
//                 fontSize: 14,
//                 color: Colors.white,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// /// Quick action tile
// class _ActionTile extends StatelessWidget {
//   final String label;
//   final IconData icon;
//   final VoidCallback onTap;
//   const _ActionTile({
//     required this.label,
//     required this.icon,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(16),
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: const Color(0xFFE6E6E6)),
//         ),
//         child: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFF6F6F6),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Icon(icon, size: 26, color: Colors.black87),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text(
//                 label,
//                 style: const TextStyle(fontWeight: FontWeight.w600),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// /// Management tile (full width)
// class _ManagementTile extends StatelessWidget {
//   final String label;
//   final VoidCallback onTap;
//   const _ManagementTile({required this.label, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(14),
//       child: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(color: const Color(0xFFE6E6E6)),
//         ),
//         child: Row(
//           children: [
//             const Icon(Icons.qr_code_scanner, color: Colors.black54),
//             const SizedBox(width: 14),
//             Expanded(
//               child: Text(
//                 label,
//                 style: const TextStyle(fontWeight: FontWeight.w600),
//               ),
//             ),
//             const Icon(
//               Icons.arrow_forward_ios,
//               size: 16,
//               color: Colors.black45,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
