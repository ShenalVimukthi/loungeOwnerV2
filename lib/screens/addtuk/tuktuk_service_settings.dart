import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_config.dart';
import '../../presentation/providers/transport_location_provider.dart';
import '../../presentation/providers/registration_provider.dart';
import '../../data/models/transport_location_model.dart';

class TukTukServiceSettingsPage extends StatefulWidget {
  const TukTukServiceSettingsPage({super.key});

  @override
  State<TukTukServiceSettingsPage> createState() =>
      _TukTukServiceSettingsPageState();
}

class _TukTukServiceSettingsPageState extends State<TukTukServiceSettingsPage> {
  final List<String> vehicleTypes = ["Three Wheeler", "Car", "Van"];
  final Map<String, Map<String, TextEditingController>> _priceControllers = {};
  String? _selectedLoungeId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  Future<void> _initialize() async {
    final registrationProvider = context.read<RegistrationProvider>();
    
    // Load lounges if not already loaded
    if (registrationProvider.myLounges.isEmpty) {
      await registrationProvider.loadMyLounges();
    }

    if (registrationProvider.myLounges.isNotEmpty) {
      setState(() {
        _selectedLoungeId = registrationProvider.myLounges.first.id;
      });
      await _loadLocations();
    }
  }

  Future<void> _loadLocations() async {
    if (_selectedLoungeId == null) return;
    
    final provider = context.read<TransportLocationProvider>();
    await provider.loadTransportLocations(_selectedLoungeId!);
    
    // Initialize price controllers
    for (var location in provider.locations) {
      _initializeControllersForLocation(location);
    }
  }

  void _initializeControllersForLocation(TransportLocationModel location) {
    _priceControllers[location.id] = {};
    for (var vehicleType in vehicleTypes) {
      final price = location.prices?[vehicleType];
      _priceControllers[location.id]![vehicleType] = TextEditingController(
        text: price != null ? price.toString() : '',
      );
    }
  }

  _addLocationDialog() {
    if (_selectedLoungeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a lounge first'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final TextEditingController locCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Add Location',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: TextField(
          controller: locCtrl,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: 'Location Name',
            hintText: 'e.g., Airport, City Center',
            prefixIcon: const Icon(Icons.location_on, color: AppColors.primary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (locCtrl.text.isNotEmpty) {
                Navigator.pop(ctx);
                
                // Show loading
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                );

                final provider = context.read<TransportLocationProvider>();
                final success = await provider.addTransportLocation(
                  loungeId: _selectedLoungeId!,
                  locationName: locCtrl.text.trim(),
                );

                if (!mounted) return;
                Navigator.pop(context); // Close loading

                if (success) {
                  // Initialize controllers for new location
                  final newLocation = provider.locations.last;
                  _initializeControllersForLocation(newLocation);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Location added successfully!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(provider.error ?? 'Failed to add location'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _deleteLocation(String locationId) async {
    if (_selectedLoungeId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Location',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: const Text('Are you sure you want to delete this location?'),
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
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );

      final provider = context.read<TransportLocationProvider>();
      final success = await provider.deleteTransportLocation(
        loungeId: _selectedLoungeId!,
        locationId: locationId,
      );

      if (!mounted) return;
      Navigator.pop(context); // Close loading

      if (success) {
        _priceControllers.remove(locationId);
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
          'Transportation Service',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),

      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton.extended(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textLight,
          onPressed: _addLocationDialog,
          icon: const Icon(Icons.add),
          label: const Text(
            'Add Location',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Service Locations',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: Consumer<TransportLocationProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading && provider.locations.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.locations.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_off,
                            size: 64,
                            color: AppColors.textSecondary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No locations added yet',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Tap the button below to add a location',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: provider.locations.length,
                    itemBuilder: (context, index) {
                      final location = provider.locations[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Location name row
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
                                    size: 20,
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
                                    Icons.delete_outline,
                                    color: AppColors.error,
                                  ),
                                  onPressed: () => _deleteLocation(location.id),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),
                            const Divider(height: 1),
                            const SizedBox(height: 16),

                            // Price UI for the 3 vehicles
                            buildPriceFields(location),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (_selectedLoungeId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select a lounge first'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    return;
                  }

                  // Show loading
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  );

                  // Save all prices to backend
                  final provider = context.read<TransportLocationProvider>();
                  bool allSuccess = true;

                  for (var location in provider.locations) {
                    final controllers = _priceControllers[location.id];
                    if (controllers == null) continue;

                    final prices = <String, double>{};
                    controllers.forEach((vehicleType, controller) {
                      final priceText = controller.text.trim();
                      if (priceText.isNotEmpty) {
                        prices[vehicleType] = double.tryParse(priceText) ?? 0.0;
                      }
                    });

                    if (prices.isNotEmpty) {
                      final success = await provider.setLocationPrices(
                        loungeId: _selectedLoungeId!,
                        locationId: location.id,
                        prices: prices,
                      );
                      if (!success) allSuccess = false;
                    }
                  }

                  if (!mounted) return;
                  Navigator.pop(context); // Close loading

                  if (allSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Locations and prices saved successfully!'),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );

                    // Navigate back to home screen
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          provider.error ?? 'Failed to save some locations',
                        ),
                        backgroundColor: AppColors.error,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textLight,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  shadowColor: AppColors.primary.withOpacity(0.3),
                ),
                child: const Text(
                  'Save locations',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget builder for price input row

  Widget buildPriceFields(TransportLocationModel location) {
    return Column(
      children: [
        priceInputRow(location, "Three Wheeler", Icons.electric_rickshaw, AppColors.primary),
        const SizedBox(height: 12),
        priceInputRow(location, "Car", Icons.directions_car, AppColors.primary),
        const SizedBox(height: 12),
        priceInputRow(location, "Van", Icons.airport_shuttle, AppColors.secondary),
      ],
    );
  }

  Widget priceInputRow(TransportLocationModel location, String type, IconData icon, Color color) {
    final controller = _priceControllers[location.id]?[type];
    if (controller == null) return const SizedBox.shrink();

    return Row(
      children: [
        // Vehicle Icon
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 28, color: color),
        ),
        const SizedBox(width: 12),

        // Price Text Field
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: "Enter price",
              hintStyle: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              labelText: "$type Price (Rs.)",
              labelStyle: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: color, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    // Dispose all controllers
    _priceControllers.forEach((locationId, controllers) {
      controllers.forEach((vehicleType, controller) {
        controller.dispose();
      });
    });
    super.dispose();
  }
}
