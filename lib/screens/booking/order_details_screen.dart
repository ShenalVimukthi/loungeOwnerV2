import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../dashboard/lounge_owner_home_screen.dart';
import '../staff/staff_dashboard_screen.dart';
import '../../widgets/staff_bottom_nav_bar.dart';
import '../../widgets/owner_bottom_nav_bar.dart';
import '../../presentation/providers/lounge_owner_provider.dart';

class OrderDetailsPage extends StatefulWidget {
  final bool isOpenedByStaff;

  const OrderDetailsPage({super.key, this.isOpenedByStaff = false});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  final List<bool> _selectedItems = [true, true, false, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: Column(
          children: [
            /// HEADER
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Table No.',
                              style: TextStyle(color: Colors.grey),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '12',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.restaurant_menu,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '4 items',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Order ID',
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '#4829',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: const [
                                  Icon(
                                    Icons.timelapse,
                                    size: 14,
                                    color: Colors.orange,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Pending',
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            /// RESTAURANT INFO
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.white,
              child: Row(
                children: const [
                  Icon(Icons.arrow_back_ios, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SAKURA BISTRO',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Water App',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(radius: 16, child: Icon(Icons.person, size: 16)),
                ],
              ),
            ),

            const SizedBox(height: 8),

            /// ORDER ITEMS
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  OrderItemTile(
                    qty: '2x',
                    title: 'Spicy Tuna Roll',
                    price: '\$24.00',
                    note: 'No sesame seeds please',
                    isSelected: _selectedItems[0],
                    onChanged: (value) {
                      setState(() {
                        _selectedItems[0] = value ?? false;
                      });
                    },
                  ),
                  OrderItemTile(
                    qty: '4x',
                    title: 'Miso Soup',
                    price: '\$18.00',
                    isSelected: _selectedItems[1],
                    onChanged: (value) {
                      setState(() {
                        _selectedItems[1] = value ?? false;
                      });
                    },
                  ),
                  OrderItemTile(
                    qty: '1x',
                    title: 'Chicken Teriyaki Don',
                    price: '\$18.00',
                    note: 'Extra sauce on the side',
                    isSelected: _selectedItems[2],
                    onChanged: (value) {
                      setState(() {
                        _selectedItems[2] = value ?? false;
                      });
                    },
                  ),
                  OrderItemTile(
                    qty: '1x',
                    title: 'Dragon Roll',
                    price: '\$16.00',
                    isSelected: _selectedItems[3],
                    onChanged: (value) {
                      setState(() {
                        _selectedItems[3] = value ?? false;
                      });
                    },
                  ),
                ],
              ),
            ),

            /// TOTAL & BUTTON
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                children: [
                  _TotalRow(title: 'Subtotal', value: '\$76.00'),
                  const SizedBox(height: 6),
                  _TotalRow(title: 'Tax (8%)', value: '\$6.08'),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate based on who opened this screen
                        if (widget.isOpenedByStaff) {
                          // Staff flow - go to Staff Dashboard
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const StaffDashboardScreen(),
                            ),
                            (route) => false,
                          );
                        } else {
                          // Lounge Owner flow - go to Lounge Owner Home
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const LoungeOwnerHomeScreen(),
                            ),
                            (route) => false,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Complete Order',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: widget.isOpenedByStaff
          ? const StaffBottomNavBar(currentIndex: 2)
          : OwnerBottomNavBar(
              currentIndex: 2,
              verificationStatus: Provider.of<LoungeOwnerProvider>(
                context,
                listen: false,
              ).loungeOwner?.verificationStatus,
            ),
    );
  }
}

/// ---------------- ORDER ITEM TILE ----------------
class OrderItemTile extends StatelessWidget {
  final String qty;
  final String title;
  final String price;
  final String? note;
  final bool isSelected;
  final ValueChanged<bool?>? onChanged;

  const OrderItemTile({
    super.key,
    required this.qty,
    required this.title,
    required this.price,
    this.note,
    required this.isSelected,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Colors.green : Colors.transparent,
          width: 2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(qty, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    decoration: isSelected ? TextDecoration.lineThrough : null,
                    color: isSelected ? Colors.grey : Colors.black,
                  ),
                ),
                if (note != null) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          size: 14,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          note!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price),
              const SizedBox(height: 8),
              Checkbox(
                value: isSelected,
                onChanged: onChanged,
                activeColor: Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ---------------- TOTAL ROW ----------------
class _TotalRow extends StatelessWidget {
  final String title;
  final String value;

  const _TotalRow({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
