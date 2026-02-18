import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../../config/theme_config.dart';
import '../../domain/entities/lounge_booking.dart';
import '../../presentation/providers/lounge_booking_provider.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    returnImage: false,
  );

  bool _isProcessingScan = false;
  bool _isFetching = false;
  String? _scannedReference;
  LoungeBooking? _booking;
  String? _errorMessage;

  static final RegExp _referenceRegex = RegExp(
    r'(LNG-[A-Za-z0-9]+)',
    caseSensitive: false,
  );

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessingScan) return;

    final rawValue = capture.barcodes.firstOrNull?.rawValue?.trim();
    if (rawValue == null || rawValue.isEmpty) return;

    final reference = _extractReference(rawValue);
    if (reference == null) {
      setState(() {
        _errorMessage =
            'Invalid QR content. Expected booking reference like LNG-b7336f.';
      });
      return;
    }

    _isProcessingScan = true;
    await _cameraController.stop();
    await _lookupBooking(reference);
  }

  String? _extractReference(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;

    final directMatch = _referenceRegex.firstMatch(trimmed);
    if (directMatch != null) {
      return directMatch.group(1);
    }

    final uri = Uri.tryParse(trimmed);
    if (uri != null && uri.pathSegments.isNotEmpty) {
      for (final segment in uri.pathSegments.reversed) {
        final match = _referenceRegex.firstMatch(segment);
        if (match != null) {
          return match.group(1);
        }
      }
    }

    return null;
  }

  Future<void> _lookupBooking(String referenceId) async {
    if (!mounted) return;

    setState(() {
      _isFetching = true;
      _errorMessage = null;
      _scannedReference = referenceId;
      _booking = null;
    });

    final bookingProvider = context.read<LoungeBookingProvider>();
    final success = await bookingProvider.getBookingByReference(referenceId);

    if (!mounted) return;

    setState(() {
      _isFetching = false;
      _booking = success ? bookingProvider.selectedBooking : null;
      _errorMessage =
          success ? null : (bookingProvider.error ?? 'Booking not found');
    });
  }

  Future<void> _scanAgain() async {
    setState(() {
      _isProcessingScan = false;
      _isFetching = false;
      _errorMessage = null;
      _booking = null;
      _scannedReference = null;
    });

    await _cameraController.start();
  }

  Future<void> _showManualReferenceDialog() async {
    final controller = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Reference ID'),
          content: TextField(
            controller: controller,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              hintText: 'Booking reference',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Search'),
            ),
          ],
        );
      },
    );

    final reference = _extractReference(controller.text);
    if (!mounted) return;

    if (reference == null) {
      setState(() {
        _errorMessage =
            'Please enter a valid booking reference like LNG-b7336f.';
      });
      return;
    }

    _isProcessingScan = true;
    await _cameraController.stop();
    await _lookupBooking(reference);
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'confirmed':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'completed':
        return AppColors.info;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: AppColors.textPrimary,
          ),
        ),
        title: const Text(
          'QR Scanner',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Scan booking QR to fetch details',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _isFetching
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : _booking != null
                        ? _buildBookingResult()
                        : _buildScannerArea(),
              ),
              const SizedBox(height: 16),
              if (_errorMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _showManualReferenceDialog,
                  icon: const Icon(Icons.keyboard),
                  label: const Text('Enter Reference Manually'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScannerArea() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        color: AppColors.surface,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: MobileScanner(
          controller: _cameraController,
          fit: BoxFit.cover,
          onDetect: _onDetect,
          errorBuilder: (context, error, child) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Camera unavailable: ${error.errorDetails?.message ?? 'Please allow camera access.'}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBookingResult() {
    final booking = _booking!;
    final statusColor = _statusColor(booking.status);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Booking Found',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        booking.status,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _rowItem(
                    'Reference', _scannedReference ?? booking.bookingReference),
                _rowItem('Guest', booking.passengerName ?? 'N/A'),
                _rowItem('Phone', booking.passengerPhone ?? 'N/A'),
                _rowItem('Guests', booking.guestCount.toString()),
                _rowItem('Lounge', booking.loungeName ?? 'N/A'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _scanAgain,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scan Another QR'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rowItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
