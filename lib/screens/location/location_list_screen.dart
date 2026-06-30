import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/theme_config.dart';
import '../../presentation/providers/transport_location_provider.dart';
import '../../presentation/providers/registration_provider.dart';
import '../../presentation/widgets/location_picker_widget.dart';
import '../../data/models/transport_location_model.dart';

/// Screen to display all saved transport locations
class LocationListScreen extends StatefulWidget {
  const LocationListScreen({super.key});

  @override
  State<LocationListScreen> createState() => _LocationListScreenState();
}

class _LocationListScreenState extends State<LocationListScreen> {
  String? _selectedLoungeId;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    final registrationProvider = context.read<RegistrationProvider>();

    if (registrationProvider.myLounges.isEmpty) {
      await registrationProvider.loadMyLounges();
    }

    final verifiedLounges = registrationProvider.verifiedLounges;
    if (verifiedLounges.isNotEmpty) {
      setState(() {
        _selectedLoungeId = verifiedLounges.first.id;
      });
      await _loadLocations();
    }
  }

  Future<void> _loadLocations() async {
    if (_selectedLoungeId == null) return;
    await context
        .read<TransportLocationProvider>()
        .loadTransportLocations(_selectedLoungeId!);
  }

  Future<void> _deleteLocation(String locationId) async {
    if (_selectedLoungeId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Location',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: const Text(
          'Are you sure you want to delete this location?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final provider = context.read<TransportLocationProvider>();
      final success = await provider.deleteTransportLocation(
        loungeId: _selectedLoungeId!,
        locationId: locationId,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location deleted successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to delete location'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  static const String _googleMapsApiKey =
      'AIzaSyAuA_RMUaOuqKOasnd5GU8MdYvrDmToXPg';

  Future<void> _editLocation(TransportLocationModel location) async {
    if (_selectedLoungeId == null) return;

    final locCtrl = TextEditingController(text: location.locationName);
    final latCtrl = TextEditingController(text: location.latitude.toString());
    final lonCtrl = TextEditingController(text: location.longitude.toString());
    final estDurationCtrl =
        TextEditingController(text: location.estDuration?.toString() ?? '');
    final distanceCtrl =
        TextEditingController(text: location.distance?.toString() ?? '');
    final threeWheelerPriceCtrl = TextEditingController(
        text: location.prices?['Three Wheeler']?.toString() ?? '');
    final carPriceCtrl =
        TextEditingController(text: location.prices?['Car']?.toString() ?? '');
    final vanPriceCtrl =
        TextEditingController(text: location.prices?['Van']?.toString() ?? '');

    final registrationProvider = context.read<RegistrationProvider>();
    final verifiedLounges = registrationProvider.verifiedLounges;

    Future<void> autoFillDistanceAndDuration({
      required double destinationLatitude,
      required double destinationLongitude,
      required void Function(void Function()) dialogSetState,
    }) async {
      if (_selectedLoungeId == null || _selectedLoungeId!.isEmpty) {
        return;
      }

      final selectedLounges = verifiedLounges
          .where((lounge) => lounge.id == _selectedLoungeId)
          .toList();
      if (selectedLounges.isEmpty) {
        return;
      }

      final lounge = selectedLounges.first;
      final loungeLatitude = double.tryParse((lounge.latitude ?? '').trim());
      final loungeLongitude = double.tryParse((lounge.longitude ?? '').trim());

      if (loungeLatitude == null || loungeLongitude == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Selected lounge has no valid coordinates'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/distancematrix/json'
        '?origins=$loungeLatitude,$loungeLongitude'
        '&destinations=$destinationLatitude,$destinationLongitude'
        '&mode=driving'
        '&key=$_googleMapsApiKey',
      );

      try {
        final response = await http.get(uri);
        if (response.statusCode != 200) {
          throw Exception('Failed to fetch route information');
        }

        final data = json.decode(response.body) as Map<String, dynamic>;
        final status = data['status']?.toString();
        if (status != 'OK') {
          throw Exception('Google API error: $status');
        }

        final rows = data['rows'] as List<dynamic>?;
        final elements = rows?.firstOrNull?['elements'] as List<dynamic>?;
        final element = elements?.firstOrNull as Map<String, dynamic>?;
        final elementStatus = element?['status']?.toString();

        if (element == null || elementStatus != 'OK') {
          throw Exception('No route data available');
        }

        final distanceMeters =
            (element['distance']?['value'] as num?)?.toDouble();
        final durationSeconds =
            (element['duration']?['value'] as num?)?.toDouble();

        if (distanceMeters == null || durationSeconds == null) {
          throw Exception('Invalid route data received');
        }

        final distanceKm = distanceMeters / 1000;
        final estimatedMinutes = (durationSeconds / 60).ceil();

        dialogSetState(() {
          distanceCtrl.text = distanceKm.toStringAsFixed(2);
          estDurationCtrl.text =
              estimatedMinutes < 1 ? '1' : estimatedMinutes.toString();
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to calculate route: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Edit Location',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 16,
              children: [
                // Location Name Field
                TextField(
                  controller: locCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Location Name *',
                    hintText: 'e.g., Negombo railway station',
                    prefixIcon:
                        const Icon(Icons.location_on, color: AppColors.primary),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                ),

                TextField(
                  controller: estDurationCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Estimated Duration (minutes) *',
                    hintText: 'e.g., 15',
                    prefixIcon:
                        const Icon(Icons.schedule, color: AppColors.primary),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                ),

                TextField(
                  controller: distanceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Distance from Lounge (km) *',
                    hintText: 'e.g., 3.5',
                    prefixIcon:
                        const Icon(Icons.route, color: AppColors.primary),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 12,
                    children: [
                      const Text(
                        'Prices (LKR) *',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextField(
                        controller: threeWheelerPriceCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Three Wheeler Price *',
                          hintText: 'Minimum 50',
                          prefixIcon: const Icon(
                            Icons.electric_rickshaw,
                            color: AppColors.primary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      TextField(
                        controller: carPriceCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Car Price *',
                          hintText: 'Minimum 50',
                          prefixIcon: const Icon(
                            Icons.directions_car,
                            color: AppColors.primary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      TextField(
                        controller: vanPriceCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Van Price *',
                          hintText: 'Minimum 50',
                          prefixIcon: const Icon(
                            Icons.airport_shuttle,
                            color: AppColors.primary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Coordinates Section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 12,
                    children: [
                      const Text(
                        'Coordinates',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          LatLng? initialLocation;
                          final existingLat = double.tryParse(latCtrl.text);
                          final existingLon = double.tryParse(lonCtrl.text);
                          if (existingLat != null && existingLon != null) {
                            initialLocation = LatLng(existingLat, existingLon);
                          } else {
                            initialLocation = LatLng(location.latitude, location.longitude);
                          }

                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LocationPickerWidget(
                                initialLocation: initialLocation,
                                onLocationSelected: (loc, _) async {
                                  setState(() {
                                    latCtrl.text =
                                        loc.latitude.toStringAsFixed(6);
                                    lonCtrl.text =
                                        loc.longitude.toStringAsFixed(6);
                                  });

                                  await autoFillDistanceAndDuration(
                                    destinationLatitude: loc.latitude,
                                    destinationLongitude: loc.longitude,
                                    dialogSetState: setState,
                                  );
                                },
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.map),
                        label: const Text('Select on Map'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          foregroundColor: AppColors.primary,
                          minimumSize: const Size(double.infinity, 44),
                        ),
                      ),
                      // Latitude Field
                      TextField(
                        controller: latCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true, signed: true),
                        decoration: InputDecoration(
                          labelText: 'Latitude (-90 to 90) *',
                          hintText: 'e.g., 7.21',
                          prefixIcon: const Icon(Icons.location_on_outlined,
                              color: AppColors.primary),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                                color: AppColors.primary, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                        ),
                      ),
                      // Longitude Field
                      TextField(
                        controller: lonCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true, signed: true),
                        decoration: InputDecoration(
                          labelText: 'Longitude (-180 to 180) *',
                          hintText: 'e.g., 79.84',
                          prefixIcon: const Icon(Icons.location_on_outlined,
                              color: AppColors.primary),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                                color: AppColors.primary, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),

                // Required Fields Note
                const Text(
                  '* Required fields',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Validate inputs
                if (locCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a location name'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                int? estDuration;
                try {
                  estDuration = int.parse(estDurationCtrl.text);
                  if (estDuration <= 0) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Estimated duration must be a positive integer'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    return;
                  }
                } catch (e) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Please enter a valid estimated duration in minutes'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                double? distance;
                try {
                  distance = double.parse(distanceCtrl.text);
                  if (distance < 0) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Distance must be zero or a positive number'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    return;
                  }
                } catch (e) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid distance in km'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                double? latitude, longitude;
                try {
                  latitude = double.parse(latCtrl.text);
                  longitude = double.parse(lonCtrl.text);

                  // Validate ranges
                  if (latitude < -90 || latitude > 90) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(
                        content: Text('Latitude must be between -90 and 90'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    return;
                  }

                  if (longitude < -180 || longitude > 180) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(
                        content: Text('Longitude must be between -180 and 180'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    return;
                  }
                } catch (e) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter valid coordinates'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                double? threeWheelerPrice;
                double? carPrice;
                double? vanPrice;
                try {
                  threeWheelerPrice = double.parse(threeWheelerPriceCtrl.text);
                  carPrice = double.parse(carPriceCtrl.text);
                  vanPrice = double.parse(vanPriceCtrl.text);

                  if (threeWheelerPrice < 50 ||
                      carPrice < 50 ||
                      vanPrice < 50) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Each price must be at least 50 LKR'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    return;
                  }
                } catch (e) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Please enter valid prices for all vehicles'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                Navigator.pop(ctx, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      final provider = context.read<TransportLocationProvider>();
      
      final nameVal = locCtrl.text.trim();
      final latVal = double.parse(latCtrl.text);
      final lonVal = double.parse(lonCtrl.text);
      final estDurationVal = int.parse(estDurationCtrl.text);
      final distanceVal = double.parse(distanceCtrl.text);
      
      final threeWheelerPrice = double.parse(threeWheelerPriceCtrl.text);
      final carPrice = double.parse(carPriceCtrl.text);
      final vanPrice = double.parse(vanPriceCtrl.text);

      final success = await provider.updateTransportLocation(
        loungeId: _selectedLoungeId!,
        locationId: location.id,
        locationName: nameVal,
        latitude: latVal,
        longitude: lonVal,
        estDuration: estDurationVal,
        distance: distanceVal,
      );

      bool pricesSaved = false;
      if (success) {
        pricesSaved = await provider.setLocationPrices(
          loungeId: _selectedLoungeId!,
          locationId: location.id,
          prices: {
            'Three Wheeler': threeWheelerPrice,
            'Car': carPrice,
            'Van': vanPrice,
          },
        );
      }

      if (!mounted) return;

      if (success && pricesSaved) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location and prices updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        await _loadLocations();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to update location details'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }

    locCtrl.dispose();
    latCtrl.dispose();
    lonCtrl.dispose();
    estDurationCtrl.dispose();
    distanceCtrl.dispose();
    threeWheelerPriceCtrl.dispose();
    carPriceCtrl.dispose();
    vanPriceCtrl.dispose();
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
          'Location List',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
            onPressed: _loadLocations,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Consumer2<TransportLocationProvider, RegistrationProvider>(
        builder: (context, provider, registrationProvider, child) {
          final verifiedLounges = registrationProvider.verifiedLounges;

          if (verifiedLounges.isEmpty) {
            return const Center(
              child: Text(
                'No verified lounges yet',
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
            );
          }

          if (provider.isLoading && provider.locations.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }


          // Compute filtered locations based on search query
          final filteredLocations = _searchQuery.isEmpty
              ? provider.locations
              : provider.locations
                  .where((loc) => loc.locationName
                      .toLowerCase()
                      .contains(_searchQuery))
                  .toList();

          // Build content for filtered results
          final filteredContent = filteredLocations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _searchQuery.isNotEmpty
                            ? Icons.search_off
                            : Icons.location_off,
                        size: 64,
                        color: AppColors.textSecondary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isNotEmpty
                            ? 'No locations found for "$_searchQuery"'
                            : 'No locations saved yet',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (_searchQuery.isEmpty) ...[
                        const SizedBox(height: 8),
                        const Text(
                          'Add locations from Transportation Service',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadLocations,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: filteredLocations.length,
                    itemBuilder: (context, index) {
                      final location = filteredLocations[index];
                      final prices = location.prices ?? {};

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.location_on,
                                    color: AppColors.primary,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    location.locationName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    color: AppColors.primary,
                                  ),
                                  onPressed: () => _editLocation(location),
                                  tooltip: 'Edit',
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: AppColors.error,
                                  ),
                                  onPressed: () => _deleteLocation(location.id),
                                  tooltip: 'Delete',
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.public,
                                    size: 18,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                _buildMetaChip(
                                  icon: Icons.schedule,
                                  label: '${location.estDuration ?? 0} min',
                                ),
                                const SizedBox(width: 8),
                                _buildMetaChip(
                                  icon: Icons.route,
                                  label:
                                      '${(location.distance ?? 0).toStringAsFixed(1)} km',
                                ),
                              ],
                            ),
                            if (prices.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              const Divider(height: 1),
                              const SizedBox(height: 16),
                              const Text(
                                'Pricing',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ...prices.entries.map((entry) {
                                final price = entry.value;
                                if (price <= 0) return const SizedBox.shrink();

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Icon(
                                        _getVehicleIcon(entry.key),
                                        size: 20,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          entry.key,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'Rs. ${price.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                );

          return Column(
            children: [
              // Lounge selector dropdown
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    underline: const SizedBox(),
                    hint: const Text(
                      'Select Lounge',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    value: verifiedLounges
                            .any((lounge) => lounge.id == _selectedLoungeId)
                        ? _selectedLoungeId
                        : null,
                    items: verifiedLounges.map((lounge) {
                      return DropdownMenuItem<String>(
                        value: lounge.id,
                        child: Row(
                          children: [
                            const Icon(Icons.store,
                                size: 20, color: AppColors.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                lounge.loungeName,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) async {
                      if (newValue != null) {
                        setState(() {
                          _selectedLoungeId = newValue;
                        });
                        await _loadLocations();
                      }
                    },
                  ),
                ),
              ),
              // Universal search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Search locations by name...',
                    hintStyle: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.textSecondary,
                      size: 22,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppColors.primary, width: 1.5),
                    ),
                  ),
                ),
              ),
              // Results count when searching
              if (_searchQuery.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${filteredLocations.length} result${filteredLocations.length == 1 ? '' : 's'} for "$_searchQuery"',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(child: filteredContent),
                    if (provider.isLoading)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(0.05),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  IconData _getVehicleIcon(String vehicleType) {
    switch (vehicleType.toLowerCase()) {
      case 'three wheeler':
        return Icons.electric_rickshaw;
      case 'car':
        return Icons.directions_car;
      case 'van':
        return Icons.airport_shuttle;
      default:
        return Icons.local_taxi;
    }
  }

  Widget _buildMetaChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
