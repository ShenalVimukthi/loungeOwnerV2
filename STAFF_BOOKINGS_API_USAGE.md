# Staff Bookings API Usage Guide

## Overview

The `/api/v1/lounge-staff/bookings` endpoint allows authenticated staff members to retrieve bookings for their assigned lounge.

## Implementation

### Data Layer

**File**: `lib/data/datasources/lounge_booking_remote_datasource.dart`

Added method:

```dart
Future<Map<String, dynamic>> getStaffBookings({
  int? limit,
  int? offset,
  String? status,
  String? date,
})
```

### Presentation Layer

**File**: `lib/presentation/providers/lounge_booking_provider.dart`

Added method:

```dart
Future<Map<String, dynamic>?> getStaffBookings({
  int? limit,
  int? offset,
  String? status,
  String? date,
})
```

## Usage in UI

### Basic Usage - Get All Bookings

```dart
import 'package:provider/provider.dart';

// In your widget
final bookingProvider = Provider.of<LoungeBookingProvider>(context, listen: false);

// Fetch all bookings for staff's lounge
final result = await bookingProvider.getStaffBookings();

if (result != null) {
  print('Lounge ID: ${result['lounge_id']}');
  print('Total bookings: ${result['total_bookings']}');
  print('Limit: ${result['limit']}');
  print('Offset: ${result['offset']}');

  // Access bookings via provider
  final bookings = bookingProvider.bookings;
}
```

### With Filters - Status Filter

```dart
// Get only confirmed bookings
await bookingProvider.getStaffBookings(
  status: 'confirmed',
);

// Available status values:
// - 'pending'
// - 'confirmed'
// - 'checked_in'
// - 'completed'
// - 'cancelled'
```

### With Filters - Date Filter

```dart
// Get bookings for a specific date
await bookingProvider.getStaffBookings(
  date: '2026-02-17', // Format: YYYY-MM-DD
);
```

### With Pagination

```dart
// First page (50 bookings)
await bookingProvider.getStaffBookings(
  limit: 50,
  offset: 0,
);

// Second page
await bookingProvider.getStaffBookings(
  limit: 50,
  offset: 50,
);
```

### Complete Example - Staff Bookings Screen

```dart
class StaffBookingsScreen extends StatefulWidget {
  const StaffBookingsScreen({super.key});

  @override
  State<StaffBookingsScreen> createState() => _StaffBookingsScreenState();
}

class _StaffBookingsScreenState extends State<StaffBookingsScreen> {
  String? _selectedStatus;
  String? _selectedDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBookings();
    });
  }

  Future<void> _loadBookings() async {
    final bookingProvider = context.read<LoungeBookingProvider>();

    await bookingProvider.getStaffBookings(
      status: _selectedStatus,
      date: _selectedDate,
      limit: 50,
      offset: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Bookings'),
        actions: [
          // Status Filter
          DropdownButton<String>(
            value: _selectedStatus,
            hint: const Text('Status'),
            items: const [
              DropdownMenuItem(value: null, child: Text('All')),
              DropdownMenuItem(value: 'pending', child: Text('Pending')),
              DropdownMenuItem(value: 'confirmed', child: Text('Confirmed')),
              DropdownMenuItem(value: 'checked_in', child: Text('Checked In')),
              DropdownMenuItem(value: 'completed', child: Text('Completed')),
              DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
            ],
            onChanged: (value) {
              setState(() => _selectedStatus = value);
              _loadBookings();
            },
          ),
        ],
      ),
      body: Consumer<LoungeBookingProvider>(
        builder: (context, provider, child) {
          // Loading state
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Error state
          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${provider.error}'),
                  ElevatedButton(
                    onPressed: _loadBookings,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Empty state
          final bookings = provider.bookings;
          if (bookings.isEmpty) {
            return const Center(
              child: Text('No bookings found'),
            );
          }

          // Bookings list
          return RefreshIndicator(
            onRefresh: _loadBookings,
            child: ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return ListTile(
                  title: Text(booking.passengerName ?? 'Guest'),
                  subtitle: Text(
                    'Status: ${booking.status} | '
                    'Guests: ${booking.guestCount} | '
                    'Amount: \$${booking.amountPaid}',
                  ),
                  trailing: Text(booking.bookingReference),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
```

## API Response Format

The endpoint returns:

```json
{
  "bookings": [
    {
      "id": "uuid",
      "booking_reference": "LB20260217A1B2C3D4",
      "lounge_id": "uuid",
      "lounge_name": "Premium Lounge",
      "booking_type": "hourly",
      "scheduled_arrival": "2026-02-17T15:04:05Z",
      "number_of_guests": 5,
      "primary_guest_name": "John Doe",
      "primary_guest_phone": "+94771234567",
      "total_amount": 1000,
      "status": "confirmed",
      "payment_status": "paid",
      "created_at": "2026-02-17T10:00:00Z"
    }
  ],
  "lounge_id": "uuid",
  "limit": 50,
  "offset": 0
}
```

## Authentication

The endpoint requires JWT authentication. The token is automatically added by the `ApiClient` interceptor from secure storage.

## Error Handling

The provider catches and handles the following errors:

- **401 Unauthorized**: Invalid or expired token
- **403 Forbidden**: User is not an approved/active staff member
- **400 Bad Request**: Invalid date format or parameters
- **500 Internal Server Error**: Server-side errors

Example error handling:

```dart
final result = await bookingProvider.getStaffBookings();

if (result == null) {
  // Error occurred
  final errorMessage = bookingProvider.error;
  print('Error loading bookings: $errorMessage');
} else {
  // Success
  final bookings = bookingProvider.bookings;
  print('Loaded ${bookings.length} bookings');
}
```

## Provider State

The provider manages:

- `isLoading`: Boolean indicating loading state
- `error`: String containing error message (if any)
- `bookings`: List of `LoungeBooking` entities
- Various filtered getters: `activeBookings`, `pendingBookings`, `completedBookings`, `todayBookings`

## Notes

1. The endpoint automatically returns bookings for the lounge assigned to the authenticated staff member
2. No need to pass lounge_id - it's determined from the staff member's assignment
3. The `LoungeBookingModel` already handles flexible field names from the API
4. Pagination is supported via `limit` and `offset` parameters
5. Date filter must use YYYY-MM-DD format
