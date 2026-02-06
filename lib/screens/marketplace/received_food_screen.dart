import 'package:flutter/material.dart';
import '../../config/theme_config.dart';
import '../booking/order_details_screen.dart';

class ReceivedFoodScreen extends StatelessWidget {
  final bool isStaffMode;
  
  const ReceivedFoodScreen({super.key, this.isStaffMode = false});

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
                child: const TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search),
                    hintText: "Search Oder",
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
                  "Oders",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ---------------- ORDER LIST ----------------
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  orderCard(
                    context: context,
                    name: "Sarah",
                    item1: "Water Bottle 500ml",
                    item2: "Potato Chips",
                  ),
                  const SizedBox(height: 15),
                  orderCard(
                    context: context,
                    name: "John",
                    item1: "Orange Juice 250ml",
                    item2: "Chocolate Cookies",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- ORDER CARD WIDGET ----------------
  Widget orderCard({
    required BuildContext context,
    required String name,
    required String item1,
    required String item2,
  }) {
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
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "completed",
                  style: TextStyle(fontSize: 12, color: Colors.green),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              const Icon(Icons.shopping_cart, size: 16),
              const SizedBox(width: 6),
              Text(item1),
            ],
          ),

          const SizedBox(height: 5),

          Row(
            children: [
              const Icon(Icons.shopping_cart, size: 16),
              const SizedBox(width: 6),
              Text(item2),
            ],
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
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "view details",
                  style: TextStyle(fontSize: 12, color: Colors.green),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
