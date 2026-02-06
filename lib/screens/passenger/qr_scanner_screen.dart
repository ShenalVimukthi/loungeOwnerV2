import 'package:flutter/material.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  String? _scannedData;
  bool _isScanning = false;

  void _startScanning() {
    setState(() {
      _isScanning = true;
    });

    // Simulate QR code scanning (in production, use a QR scanner package)
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _scannedData = "BOOKING-REF-12345";
          _isScanning = false;
        });
        _showPassengerDetails();
      }
    });
  }

  void _showPassengerDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PassengerDetailsPage(bookingRef: _scannedData!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF8C1A),
        title: const Text('QR Scanner', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // QR Scanner Area
              Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFFF8C1A), width: 3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    // Corner decorations
                    Positioned(
                      top: 0,
                      left: 0,
                      child: _buildCorner(true, true),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: _buildCorner(true, false),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: _buildCorner(false, true),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: _buildCorner(false, false),
                    ),

                    // Center content
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isScanning)
                            const Column(
                              children: [
                                CircularProgressIndicator(
                                  color: Color(0xFFFF8C1A),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Scanning...',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            )
                          else
                            Icon(
                              Icons.qr_code_scanner,
                              size: 100,
                              color: Colors.grey.shade300,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Instructions
              const Text(
                'Scan Booking QR Code',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Position the QR code within the frame\nto scan automatically',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),

              const SizedBox(height: 40),

              // Scan Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isScanning ? null : _startScanning,
                  icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                  label: Text(
                    _isScanning ? 'Scanning...' : 'Start Scanning',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8C1A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Enter Manually Button
              TextButton.icon(
                onPressed: () {
                  _showManualEntryDialog();
                },
                icon: const Icon(Icons.keyboard, color: Color(0xFFFF8C1A)),
                label: const Text(
                  'Enter Code Manually',
                  style: TextStyle(fontSize: 14, color: Color(0xFFFF8C1A)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCorner(bool top, bool left) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        border: Border(
          top: top
              ? const BorderSide(color: Color(0xFFFF8C1A), width: 4)
              : BorderSide.none,
          bottom: !top
              ? const BorderSide(color: Color(0xFFFF8C1A), width: 4)
              : BorderSide.none,
          left: left
              ? const BorderSide(color: Color(0xFFFF8C1A), width: 4)
              : BorderSide.none,
          right: !left
              ? const BorderSide(color: Color(0xFFFF8C1A), width: 4)
              : BorderSide.none,
        ),
      ),
    );
  }

  void _showManualEntryDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Booking Code'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter booking reference',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.characters,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  _scannedData = controller.text;
                });
                Navigator.pop(context);
                _showPassengerDetails();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8C1A),
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}

// Passenger Details Page showing complete booking information
class PassengerDetailsPage extends StatelessWidget {
  final String bookingRef;

  const PassengerDetailsPage({super.key, required this.bookingRef});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF8C1A),
        title: const Text(
          'Passenger Details',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Booking Reference Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF8C1A), Color(0xFFFF6B00)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Booking Reference',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    bookingRef,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Passenger Information
            _buildSectionTitle('Passenger Information', Icons.person),
            const SizedBox(height: 12),
            _buildInfoCard([
              _buildInfoRow('Name', 'Sarah Johnson'),
              _buildInfoRow('Phone', '+94 71 234 5678'),
              _buildInfoRow('Email', 'sarah.j@example.com'),
              _buildInfoRow('Adults', '2'),
              _buildInfoRow('Children', '1'),
            ]),

            const SizedBox(height: 20),

            // Bus Schedule Details
            _buildSectionTitle('Bus Schedule', Icons.directions_bus),
            const SizedBox(height: 12),
            _buildInfoCard([
              _buildInfoRow('Bus Number', 'NB-1234'),
              _buildInfoRow('Route', 'Colombo → Kandy'),
              _buildInfoRow('Departure Time', '10:30 AM'),
              _buildInfoRow('Arrival Time', '2:30 PM'),
              _buildInfoRow('Seat Numbers', 'A12, A13, A14'),
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Checked In',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ]),

            const SizedBox(height: 20),

            // Food Order Details
            _buildSectionTitle('Food Order', Icons.restaurant),
            const SizedBox(height: 12),
            _buildInfoCard([
              _buildFoodItem('Water Bottle 500ml', 2, 150),
              _buildFoodItem('Chocolate Cookies', 3, 250),
              _buildFoodItem('Orange Juice', 2, 200),
              const Divider(height: 24),
              _buildInfoRow('Subtotal', 'LKR 1,350', isBold: true),
              _buildInfoRow('Service Charge', 'LKR 135'),
              _buildInfoRow('Total', 'LKR 1,485', isBold: true, isTotal: true),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.pending,
                      color: Colors.orange.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Order Pending',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ]),

            const SizedBox(height: 20),

            // Tuk Tuk Service Details
            _buildSectionTitle('Tuk Tuk Service', Icons.local_taxi),
            const SizedBox(height: 12),
            _buildInfoCard([
              _buildInfoRow('Service Type', 'Airport Transfer'),
              _buildInfoRow('Pickup Location', 'Colombo Airport Terminal 1'),
              _buildInfoRow('Drop Location', 'Galle Face Hotel'),
              _buildInfoRow('Scheduled Time', '3:00 PM'),
              _buildInfoRow('Vehicle Number', 'WP CAB-1234'),
              _buildInfoRow('Driver Name', 'Ravi Perera'),
              _buildInfoRow('Driver Contact', '+94 77 123 4567'),
              _buildInfoRow('Fare', 'LKR 2,500', isBold: true),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tuk Tuk will be ready 10 mins before scheduled time',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ]),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Print receipt
                    },
                    icon: const Icon(Icons.print),
                    label: const Text('Print Receipt'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFFF8C1A),
                      side: const BorderSide(color: Color(0xFFFF8C1A)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/dashboard',
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: const Text(
                      'Confirm',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF8C1A),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFF8C1A), size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool isBold = false,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isTotal ? Colors.black87 : Colors.black54,
              fontWeight: isBold || isTotal
                  ? FontWeight.w600
                  : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: isBold || isTotal ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodItem(String name, int quantity, int price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${quantity}x',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(name, style: const TextStyle(fontSize: 14))),
          Text(
            'LKR ${price * quantity}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
