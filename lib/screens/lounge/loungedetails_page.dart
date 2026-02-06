import 'package:flutter/material.dart';
import '../../widgets/staff_bottom_nav_bar.dart';

class LoungeDetailsPage extends StatelessWidget {
  const LoungeDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),

      /// APP BAR
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Lounge Details',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),

      /// BODY
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  Image.network(
                    'https://images.unsplash.com/photo-1524758631624-e2822e304c36',
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    right: 12,
                    top: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '1 / 4',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            /// STATUS + SHARE
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Approved',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.share_outlined),
                ),
              ],
            ),

            /// TITLE
            const Text(
              'Sky Terrace Lounge',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),

            /// DESCRIPTION
            Text(
              'Premium rooftop lounge with stunning city views, perfect for corporate events and private gatherings. Features modern amenities and professional service.',
              style: TextStyle(
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 12),

            /// CAPACITY
            Row(
              children: const [
                Icon(Icons.groups, color: Colors.orange, size: 20),
                SizedBox(width: 8),
                Text(
                  'Capacity: 50–80 people',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// FACILITIES
            const Text(
              'Facilities',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: const [
                FacilityItem(icon: Icons.wifi, label: 'WiFi'),
                FacilityItem(icon: Icons.ac_unit, label: 'AC'),
                FacilityItem(icon: Icons.local_parking, label: 'Parking'),
                FacilityItem(icon: Icons.restaurant, label: 'Catering'),
              ],
            ),

            const SizedBox(height: 24),

            /// LOCATION
            const Text(
              'Location & Contact',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 12),

            InfoRow(
              icon: Icons.location_on,
              text: '123, Downtown Plaza, Colombo',
            ),
            const SizedBox(height: 8),
            InfoRow(
              icon: Icons.phone,
              text: '037 2248567',
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.map),
                label: const Text('View on Map'),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// PRICE
            const Text(
              'Price Per Hour',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'RS 1,250',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: const StaffBottomNavBar(currentIndex: 1),
    );
  }
}

/// ---------- FACILITY ITEM ----------
class FacilityItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const FacilityItem({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.orange),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// ---------- INFO ROW ----------
class InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const InfoRow({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.orange, size: 20),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }
}
