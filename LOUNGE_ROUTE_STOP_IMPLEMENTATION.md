# Flutter Lounge Owner Registration - Route & Stop Selection Implementation Guide

## Overview
Add route and stop selection to the lounge registration form. The lounge owner must select:
1. A route that their lounge serves
2. Two consecutive stops where the lounge is located between them

## UI Changes Required in `lounge_owner_registration_screen.dart`

### 1. Add State Variables (around line 60-70)

```dart
// Route and Stop selection
String? _selectedRouteId;
String? _selectedStopBeforeId;
String? _selectedStopAfterId;
List<MasterRoute> _availableRoutes = [];
List<MasterRouteStop> _routeStops = [];
bool _loadingRoutes = false;
```

### 2. Import Required Models

Add at the top of the file:
```dart
import '../../data/models/route_model.dart';
import '../../data/datasources/route_remote_datasource.dart';
import '../../core/di/injection_container.dart';
```

### 3. Load Routes on Init

Add to `initState()` or create a method:
```dart
@override
void initState() {
  super.initState();
  _loadRoutes();
}

Future<void> _loadRoutes() async {
  setState(() => _loadingRoutes = true);
  try {
    final routeDataSource = RouteRemoteDataSource(
      apiClient: InjectionContainer().apiClient,
    );
    final routes = await routeDataSource.getMasterRoutes();
    setState(() {
      _availableRoutes = routes;
      _loadingRoutes = false;
    });
  } catch (e) {
    print('Error loading routes: $e');
    setState(() => _loadingRoutes = false);
  }
}

Future<void> _loadRouteStops(String routeId) async {
  try {
    final routeDataSource = RouteRemoteDataSource(
      apiClient: InjectionContainer().apiClient,
    );
    final stops = await routeDataSource.getRouteStops(routeId);
    setState(() {
      _routeStops = stops;
      // Reset stop selections when route changes
      _selectedStopBeforeId = null;
      _selectedStopAfterId = null;
    });
  } catch (e) {
    print('Error loading stops: $e');
  }
}
```

### 4. Add Form Fields in `_buildLoungeDetailsStep()`

Add these fields AFTER the address field and BEFORE the map location picker (around line 540):

```dart
const SizedBox(height: 16),

// Route Selection
Text(
  'Route & Stop Selection',
  style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
),
const SizedBox(height: 8),
Text(
  'Select the route your lounge serves and the two nearest stops',
  style: TextStyle(
    fontSize: 14,
    color: Colors.grey[600],
  ),
),
const SizedBox(height: 12),

// Route Dropdown
DropdownButtonFormField<String>(
  value: _selectedRouteId,
  decoration: InputDecoration(
    labelText: 'Select Route *',
    hintText: 'Choose a route',
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    prefixIcon: const Icon(Icons.route),
  ),
  items: _loadingRoutes
      ? []
      : _availableRoutes.map((route) {
          return DropdownMenuItem<String>(
            value: route.id,
            child: Text(
              '${route.routeNumber} - ${route.routeDisplay}',
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
  onChanged: _loadingRoutes
      ? null
      : (value) {
          if (value != null) {
            setState(() {
              _selectedRouteId = value;
            });
            _loadRouteStops(value);
          }
        },
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Please select a route';
    }
    return null;
  },
),
const SizedBox(height: 16),

// Stop Before Dropdown
DropdownButtonFormField<String>(
  value: _selectedStopBeforeId,
  decoration: InputDecoration(
    labelText: 'Stop Before Lounge *',
    hintText: 'Select the stop before your lounge',
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    prefixIcon: const Icon(Icons.location_on),
  ),
  items: _routeStops.map((stop) {
    return DropdownMenuItem<String>(
      value: stop.id,
      child: Text(
        '${stop.stopOrder}. ${stop.stopName}',
        overflow: TextOverflow.ellipsis,
      ),
    );
  }).toList(),
  onChanged: _selectedRouteId == null
      ? null
      : (value) {
          setState(() {
            _selectedStopBeforeId = value;
          });
        },
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Please select the stop before your lounge';
    }
    return null;
  },
),
const SizedBox(height: 16),

// Stop After Dropdown
DropdownButtonFormField<String>(
  value: _selectedStopAfterId,
  decoration: InputDecoration(
    labelText: 'Stop After Lounge *',
    hintText: 'Select the stop after your lounge',
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    prefixIcon: const Icon(Icons.location_on_outlined),
  ),
  items: _routeStops.map((stop) {
    return DropdownMenuItem<String>(
      value: stop.id,
      child: Text(
        '${stop.stopOrder}. ${stop.stopName}',
        overflow: TextOverflow.ellipsis,
      ),
    );
  }).toList(),
  onChanged: _selectedRouteId == null
      ? null
      : (value) {
          setState(() {
            _selectedStopAfterId = value;
          });
        },
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Please select the stop after your lounge';
    }
    // Optional: Validate that stop after comes after stop before
    if (_selectedStopBeforeId != null && value != null) {
      final stopBefore = _routeStops.firstWhere((s) => s.id == _selectedStopBeforeId);
      final stopAfter = _routeStops.firstWhere((s) => s.id == value);
      if (stopAfter.stopOrder <= stopBefore.stopOrder) {
        return 'Stop after must come after stop before';
      }
    }
    return null;
  },
),
const SizedBox(height: 16),
```

### 5. Update saveLoungeData Call

Find where `registrationProvider.saveLoungeData()` is called (in the "Next" button handler around line 1200) and update it:

```dart
registrationProvider.saveLoungeData(
  loungeName: _loungeNameController.text.trim(),
  description: _descriptionController.text.trim().isNotEmpty 
      ? _descriptionController.text.trim() 
      : null,
  address: _addressController.text.trim(),
  state: _stateController.text.trim().isNotEmpty 
      ? _stateController.text.trim() 
      : null,
  postalCode: _postalCodeController.text.trim().isNotEmpty 
      ? _postalCodeController.text.trim() 
      : null,
  latitude: _selectedLatitude!,
  longitude: _selectedLongitude!,
  contactPhone: _contactPhoneController.text.trim(),
  capacity: int.parse(_capacityController.text.trim()),
  price1Hour: _price1HourController.text.trim().isEmpty 
      ? '0.00' 
      : _price1HourController.text.trim(),
  price2Hours: _price2HoursController.text.trim().isEmpty 
      ? '0.00' 
      : _price2HoursController.text.trim(),
  price3Hours: _price3HoursController.text.trim().isEmpty 
      ? '0.00' 
      : _price3HoursController.text.trim(),
  priceUntilBus: _priceUntilBusController.text.trim().isEmpty 
      ? '0.00' 
      : _priceUntilBusController.text.trim(),
  amenities: _selectedAmenities,
  masterRouteId: _selectedRouteId!,  // ADD THIS
  stopBeforeId: _selectedStopBeforeId!,  // ADD THIS
  stopAfterId: _selectedStopAfterId!,  // ADD THIS
);
```

### 6. Update Form Validation

In the validation section (before moving to review step), add:

```dart
if (_selectedRouteId == null) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Please select a route'),
      backgroundColor: Colors.red,
    ),
  );
  return;
}

if (_selectedStopBeforeId == null) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Please select the stop before your lounge'),
      backgroundColor: Colors.red,
    ),
  );
  return;
}

if (_selectedStopAfterId == null) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Please select the stop after your lounge'),
      backgroundColor: Colors.red,
    ),
  );
  return;
}
```

## Backend API Endpoint

The backend expects these fields:
```json
{
  "lounge_name": "string",
  "address": "string",
  "contact_phone": "string",
  "latitude": "string",
  "longitude": "string",
  "capacity": 50,
  "master_route_id": "uuid",
  "stop_before_id": "uuid",
  "stop_after_id": "uuid",
  "amenities": ["wifi", "ac"],
  "images": ["url1", "url2"]
}
```

## Testing Checklist

1. [ ] Routes load when screen opens
2. [ ] Selecting a route loads its stops
3. [ ] Stop dropdowns are disabled until route is selected
4. [ ] Cannot select same stop for both before/after
5. [ ] Validation prevents progression without selections
6. [ ] Data is saved to provider correctly
7. [ ] API call includes route and stop IDs
8. [ ] Backend successfully creates lounge with route info

## Notes

- The route dropdown shows: "Route Number - Origin - Destination"
- Stop dropdowns show: "Order. Stop Name"
- Stops are ordered sequentially (stop_order field)
- Validation ensures stop_after comes after stop_before
