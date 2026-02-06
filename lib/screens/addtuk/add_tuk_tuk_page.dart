import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../config/theme_config.dart';
import '../../presentation/providers/registration_provider.dart';

class AddTukTukPage extends StatefulWidget {
  const AddTukTukPage({super.key});

  @override
  State<AddTukTukPage> createState() => _AddTukTukPageState();
}

class _AddTukTukPageState extends State<AddTukTukPage> {
  final _formKey = GlobalKey<FormState>();

  final _driverNameController = TextEditingController();
  final _vehicleNumberController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _nicController = TextEditingController();

  String _selectedVehicleType = 'Three Wheeler';
  String? _selectedLoungeId;

  @override
  void initState() {
    super.initState();
    // Load lounges when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RegistrationProvider>(context, listen: false).loadMyLounges();
    });
  }

  @override
  void dispose() {
    _driverNameController.dispose();
    _vehicleNumberController.dispose();
    _contactNumberController.dispose();
    _nicController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vehicle details added successfully!'),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color pageBg = Color(0xFFFFFBF5);

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        backgroundColor: pageBg,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: Colors.black87,
          ),
        ),
        title: const Text(
          'Add Vehicle Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.local_taxi,
                          size: 48,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Add New Vehicle',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Register your vehicle and driver details',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Driver Information Section
                const Text(
                  'Driver Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _driverNameController,
                  decoration: _inputDecoration(
                    'Driver Name',
                    Icons.person_outline,
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => v == null || v.isEmpty
                      ? 'Please enter driver name'
                      : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _nicController,
                  decoration: _inputDecoration(
                    'NIC Number',
                    Icons.badge_outlined,
                  ),
                  textCapitalization: TextCapitalization.characters,
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Please enter NIC number';
                    }
                    if (v.length != 10 && v.length != 12) {
                      return 'NIC must be 10 or 12 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _contactNumberController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  decoration: _inputDecoration(
                    'Contact Number',
                    Icons.phone_outlined,
                  ),
                  validator: (v) => v == null || v.length != 10
                      ? 'Please enter valid contact number'
                      : null,
                ),
                const SizedBox(height: 24),

                // Vehicle Information Section
                const Text(
                  'Vehicle Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _vehicleNumberController,
                  decoration: _inputDecoration(
                    'Vehicle Number',
                    Icons.confirmation_number_outlined,
                  ),
                  textCapitalization: TextCapitalization.characters,
                  validator: (v) => v == null || v.isEmpty
                      ? 'Please enter vehicle number'
                      : null,
                ),
                const SizedBox(height: 16),

                // Lounge Selection Dropdown
                Consumer<RegistrationProvider>(
                  builder: (context, provider, child) {
                    final lounges = provider.myLounges;

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _selectedLoungeId,
                        hint: const Text(
                          'Select Lounge',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        items: lounges.map((lounge) {
                          return DropdownMenuItem<String>(
                            value: lounge.id,
                            child: Text(
                              lounge.loungeName,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          );
                        }).toList(),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(
                            Icons.apartment_outlined,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          isDense: true,
                        ),
                        icon: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Icon(
                            Icons.arrow_drop_down,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        dropdownColor: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a lounge';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            _selectedLoungeId = value;
                          });
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _selectedVehicleType,
                    items: ['Three Wheeler', 'Van', 'Car'].map((type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(
                          type,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.local_taxi_outlined,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      isDense: true,
                    ),
                    icon: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    onChanged: (value) =>
                        setState(() => _selectedVehicleType = value!),
                  ),
                ),
                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      shadowColor: AppColors.primary.withOpacity(0.3),
                    ),
                    child: const Text(
                      'Add Vehicle',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
      prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade300),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }
}
