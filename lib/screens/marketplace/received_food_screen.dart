import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme_config.dart';
import '../../domain/entities/lounge_booking.dart';
import '../../presentation/providers/lounge_booking_provider.dart';
import '../booking/order_details_screen.dart';

class ReceivedFoodScreen extends StatelessWidget {
  final bool isStaffMode;

  const ReceivedFoodScreen({super.key, this.isStaffMode = false});

  @override
  Widget build(BuildContext context) {
    return _ReceivedFoodView(isStaffMode: isStaffMode);
  }
}

class _ReceivedFoodView extends StatefulWidget {
  final bool isStaffMode;

  const _ReceivedFoodView({required this.isStaffMode});

  @override
  State<_ReceivedFoodView> createState() => _ReceivedFoodViewState();
}

class _ReceivedFoodViewState extends State<_ReceivedFoodView> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String? _errorMessage;
  List<_BookingOrdersViewData> _bookingOrders = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReceivedFoodData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadReceivedFoodData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final bookingProvider = context.read<LoungeBookingProvider>();
    final now = DateTime.now();
    final today = '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';

    bool bookingsLoaded;
    if (widget.isStaffMode) {
      bookingsLoaded = await bookingProvider.getStaffBookings(
            date: today,
            limit: 100,
          ) !=
          null;
    } else {
      bookingsLoaded = await bookingProvider.getOwnerBookings(date: today);
    }

    if (!bookingsLoaded) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = bookingProvider.error ?? 'Failed to load bookings';
      });
      return;
    }

    final bookings = bookingProvider.bookings;
    final detailCalls = bookings.map((booking) async {
      try {
        final data =
            await bookingProvider.remoteDataSource.getBookingWithOrders(
          bookingId: booking.id,
          date: today,
        );
        return _BookingOrdersViewData.fromApi(booking: booking, data: data);
      } catch (_) {
        return _BookingOrdersViewData.fromApi(booking: booking, data: const {});
      }
    }).toList();

    final results = await Future.wait(detailCalls);

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _bookingOrders = results;
    });
  }

  List<_BookingOrdersViewData> _filteredData() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _bookingOrders;

    return _bookingOrders.where((entry) {
      final guestName = (entry.booking.passengerName ?? '').toLowerCase();
      final reference = entry.booking.bookingReference.toLowerCase();
      final orderMatch = entry.items.any((item) =>
          item.name.toLowerCase().contains(query) ||
          item.quantityText.toLowerCase().contains(query));
      return guestName.contains(query) ||
          reference.contains(query) ||
          orderMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF5),
      body: SafeArea(
        child: Column(
          children: [
            // ---------------- APP BAR ----------------
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "All Received Food for Today",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // ---------------- SEARCH BAR ----------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search),
                    hintText: "Search booking or item",
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ---------------- ORDERS TITLE ----------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  "Orders",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ---------------- ORDER LIST ----------------
            Expanded(
              child: _isLoading
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary),
                    )
                  : _errorMessage != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _errorMessage!,
                                  textAlign: TextAlign.center,
                                  style:
                                      const TextStyle(color: AppColors.error),
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: _loadReceivedFoodData,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : _filteredData().isEmpty
                          ? const Center(
                              child: Text(
                                'No received food orders found for today',
                                style:
                                    TextStyle(color: AppColors.textSecondary),
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _loadReceivedFoodData,
                              color: AppColors.primary,
                              child: ListView.separated(
                                padding: const EdgeInsets.all(16),
                                itemCount: _filteredData().length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 15),
                                itemBuilder: (context, index) {
                                  final entry = _filteredData()[index];
                                  return _orderCard(
                                    context: context,
                                    entry: entry,
                                    isStaffMode: widget.isStaffMode,
                                  );
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- ORDER CARD WIDGET ----------------
  Widget _orderCard({
    required BuildContext context,
    required _BookingOrdersViewData entry,
    required bool isStaffMode,
  }) {
    final booking = entry.booking;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.passengerName ?? 'Guest',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Ref: ${booking.bookingReference}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  booking.status,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (entry.items.isEmpty)
            const Text(
              'No ordered items',
              style: TextStyle(color: AppColors.textSecondary),
            )
          else
            ...entry.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
                  children: [
                    const Icon(Icons.shopping_cart, size: 16),
                    const SizedBox(width: 6),
                    Expanded(child: Text(item.name)),
                    Text(
                      item.quantityText,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          Text(
            'Orders: ${entry.ordersCount} • Items: ${entry.orderedItemsCount} • Total: ${entry.ordersTotalAmount}',
            style:
                const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderDetailsPage(
                      isOpenedByStaff: isStaffMode,
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "View Details",
                  style: TextStyle(fontSize: 12, color: AppColors.primary),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingOrdersViewData {
  final LoungeBooking booking;
  final List<_OrderedItem> items;
  final int ordersCount;
  final int orderedItemsCount;
  final String ordersTotalAmount;

  const _BookingOrdersViewData({
    required this.booking,
    required this.items,
    required this.ordersCount,
    required this.orderedItemsCount,
    required this.ordersTotalAmount,
  });

  factory _BookingOrdersViewData.fromApi({
    required LoungeBooking booking,
    required Map<String, dynamic> data,
  }) {
    final orders = (data['orders'] as List<dynamic>?) ?? const [];
    final extractedItems = <_OrderedItem>[];

    for (final order in orders) {
      if (order is! Map<String, dynamic>) continue;
      final orderItems = (order['items'] as List<dynamic>?) ??
          (order['order_items'] as List<dynamic>?) ??
          (order['ordered_items'] as List<dynamic>?) ??
          const [];

      for (final item in orderItems) {
        if (item is! Map<String, dynamic>) continue;

        final name = (item['product_name'] ??
                item['item_name'] ??
                item['name'] ??
                item['title'] ??
                'Item')
            .toString();

        final quantityRaw =
            item['quantity'] ?? item['qty'] ?? item['count'] ?? 1;
        final quantityText = 'x${quantityRaw.toString()}';

        extractedItems
            .add(_OrderedItem(name: name, quantityText: quantityText));
      }
    }

    final ordersCountRaw = data['orders_count'];
    final orderedItemsCountRaw = data['ordered_items_count'];

    final ordersCount = ordersCountRaw is int
        ? ordersCountRaw
        : int.tryParse(ordersCountRaw?.toString() ?? '') ?? orders.length;
    final orderedItemsCount = orderedItemsCountRaw is int
        ? orderedItemsCountRaw
        : int.tryParse(orderedItemsCountRaw?.toString() ?? '') ??
            extractedItems.length;

    final ordersTotalAmount =
        (data['orders_total_amount'] ?? data['total_amount'] ?? '0.00')
            .toString();

    return _BookingOrdersViewData(
      booking: booking,
      items: extractedItems,
      ordersCount: ordersCount,
      orderedItemsCount: orderedItemsCount,
      ordersTotalAmount: ordersTotalAmount,
    );
  }
}

class _OrderedItem {
  final String name;
  final String quantityText;

  const _OrderedItem({required this.name, required this.quantityText});
}
