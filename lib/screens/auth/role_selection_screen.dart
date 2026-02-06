import 'package:flutter/material.dart';
import 'package:lounge_owner_app/screens/lounge_owner/lounge_owner_registration_screen.dart';
import 'package:provider/provider.dart';
import '../../presentation/providers/role_selection_provider.dart';
import '../../config/theme_config.dart';
import '../staff/staff_registration_page.dart';

class RoleSelectionScreen extends StatefulWidget {
  final String userId;

  const RoleSelectionScreen({super.key, required this.userId});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedDistrict;
  String? _selectedLoungeOwner;
  String? _selectedLounge;

  // Sri Lanka's 25 districts
  final List<String> _districts = [
    'Ampara',
    'Anuradhapura',
    'Badulla',
    'Batticaloa',
    'Colombo',
    'Galle',
    'Gampaha',
    'Hambantota',
    'Jaffna',
    'Kalutara',
    'Kandy',
    'Kegalle',
    'Kilinochchi',
    'Kurunegala',
    'Mannar',
    'Matale',
    'Matara',
    'Monaragala',
    'Mullaitivu',
    'Nuwara Eliya',
    'Polonnaruwa',
    'Puttalam',
    'Ratnapura',
    'Trincomalee',
    'Vavuniya',
  ];

  @override
  void initState() {
    super.initState();
    // Fetch all lounges for staff dropdown when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoleSelectionProvider>().fetchAllLounges();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.large,
              vertical: AppSpacing.large,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Bus Icon
                Container(
                  padding: const EdgeInsets.all(AppSpacing.large),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.directions_bus,
                    size: 50,
                    color: AppColors.textLight,
                  ),
                ),

                const SizedBox(height: AppSpacing.large),

                // Welcome Text
                Text(
                  'Select your role',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.small),

                // Subtitle
                Text(
                  'Please select your role to continue with registration',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.xxLarge),

                // Lounge Owner Card
                _buildLoungeOwnerCard(context),

                const SizedBox(height: AppSpacing.large),

                // Staff Member Card
                _buildStaffMemberCard(context),

                const SizedBox(height: AppSpacing.xLarge),

                // Footer Note
                Container(
                  padding: const EdgeInsets.all(AppSpacing.medium),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.info.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 18, color: AppColors.info),
                      const SizedBox(width: AppSpacing.small),
                      Expanded(
                        child: Text(
                          'Your registration will be pending approval after submission',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoungeOwnerCard(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        // Navigate to Admin registration
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoungeOwnerRegistrationScreen(userId: widget.userId),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.large),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.person,
                size: 32,
                color: AppColors.textLight,
              ),
            ),
            const SizedBox(height: AppSpacing.medium),
            Text(
              'Lounge Owner',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.small / 2),
            Text(
              'Register as a Lounge Owner',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.medium),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.large,
                vertical: AppSpacing.small,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'Select',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textLight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffMemberCard(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<RoleSelectionProvider>(
      builder: (context, provider, child) {
        // Lounge owners by district
        final Map<String, List<String>> loungeOwnersByDistrict = {
          'Colombo': ['Rashmika Daham', 'Maleesha Fernando', 'Kasun De Silva'],
          'Gampaha': ['Pradeep Silva', 'Nimal Perera', 'Sunil Bandara'],
          'Kalutara': ['Lakshman Dias', 'Roshan Jayasinghe'],
          'Kandy': ['Chaminda Silva', 'Ajith Fernando', 'Kumar Sathya'],
          'Matale': ['Rajan Murali', 'Selvam Kannan'],
          'Nuwara Eliya': ['Farook Hassan', 'Nazeer Ahmed'],
          'Galle': ['Rizan Farook', 'Pradeep Gamage'],
          'Matara': ['Sanjeewa Liyanage', 'Tharaka Wijesinghe'],
          'Hambantota': ['Saman Kumara', 'Upul Dissanayake'],
          'Jaffna': ['Indika Rajapaksa', 'Bandula Weerasinghe'],
          'Kilinochchi': ['Sudath Ranasinghe'],
          'Mannar': ['Prasanna Wickrama'],
          'Vavuniya': ['Rohitha Perera'],
          'Mullaitivu': ['Nuwan Jayawardena'],
          'Batticaloa': ['Dilan Wijeratne', 'Kamal Peris'],
          'Ampara': ['Ajith Gunasekara'],
          'Trincomalee': ['Ruwan Fernando'],
          'Kurunegala': ['Mahesh Silva', 'Chathura Perera'],
          'Puttalam': ['Samantha Jayawardena'],
          'Anuradhapura': ['Tharindu Wijesinghe', 'Dilshan Kumar'],
          'Polonnaruwa': ['Janaka Silva'],
          'Badulla': ['Nishantha Perera', 'Suresh Bandara'],
          'Monaragala': ['Anil Gunasekara'],
          'Ratnapura': ['Kapila Silva', 'Lasantha Fernando'],
          'Kegalle': ['Wijith Perera'],
        };

        // Hardcoded data as fallback with district mapping
        final Map<String, List<String>> loungesByDistrict = {
          'Colombo': [
            'Colombo Paradise Lounge',
            'Fort Lounge',
            'Bambalapitiya Lounge',
          ],
          'Gampaha': [
            'Negombo Beach Lounge',
            'Gampaha City Lounge',
            'Ja-Ela Lounge',
          ],
          'Kalutara': ['Kalutara Beach Lounge', 'Wadduwa Lounge'],
          'Kandy': ['Kandy Hill Lounge', 'Peradeniya Lounge', 'Temple Lounge'],
          'Matale': ['Matale Heritage Lounge', 'Dambulla Lounge'],
          'Nuwara Eliya': ['Nuwara Eliya Tea Lounge', 'Nanu Oya Lounge'],
          'Galle': ['Galle Fort Lounge', 'Unawatuna Beach Lounge'],
          'Matara': ['Matara Beach Lounge', 'Mirissa Lounge'],
          'Hambantota': ['Hambantota Safari Lounge', 'Tangalle Beach Lounge'],
          'Jaffna': ['Jaffna Royal Lounge', 'Nallur Lounge'],
          'Kilinochchi': ['Kilinochchi Central Lounge'],
          'Mannar': ['Mannar Island Lounge'],
          'Vavuniya': ['Vavuniya Central Lounge'],
          'Mullaitivu': ['Mullaitivu Beach Lounge'],
          'Batticaloa': ['Batticaloa Beach Lounge', 'Kalmunai Lounge'],
          'Ampara': ['Ampara Town Lounge'],
          'Trincomalee': ['Trincomalee Bay Lounge', 'Nilaveli Beach Lounge'],
          'Kurunegala': ['Kurunegala City Lounge', 'Maho Lounge'],
          'Puttalam': ['Puttalam Coast Lounge', 'Kalpitiya Lounge'],
          'Anuradhapura': [
            'Anuradhapura Heritage Lounge',
            'Sacred City Lounge',
          ],
          'Polonnaruwa': ['Polonnaruwa Ancient Lounge', 'Sigiriya Rock Lounge'],
          'Badulla': ['Badulla Hill Lounge', 'Bandarawela Tea Lounge'],
          'Monaragala': ['Monaragala Town Lounge'],
          'Ratnapura': ['Ratnapura Gem Lounge', 'Adam\'s Peak Lounge'],
          'Kegalle': ['Kegalle Mountain Lounge', 'Kitulgala Lounge'],
        };

        // Get lounge owners for selected district
        List<String> availableLoungeOwners = [];
        if (_selectedDistrict != null) {
          availableLoungeOwners =
              loungeOwnersByDistrict[_selectedDistrict!] ?? [];
        }

        // Get lounges for selected district
        List<String> availableLounges = [];
        if (_selectedDistrict != null && _selectedLoungeOwner != null) {
          // Use hardcoded data mapped by district
          availableLounges = loungesByDistrict[_selectedDistrict!] ?? [];

          // If we have real data from provider, we could also show those lounges
          // but since Lounge entity doesn't have district field, we just use hardcoded data
          // In production, you would filter provider.lounges by matching the district field
          // or add a district field to the Lounge entity
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.large),
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.secondary.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person,
                  size: 32,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: AppSpacing.medium),
              Text(
                'Staff Member',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: AppSpacing.small / 2),
              Text(
                'Register as a Staff Member',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.medium),

              // Select District Dropdown
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.medium,
                  vertical: AppSpacing.small / 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: AppColors.secondary,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.small),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          hint: Text(
                            'Select your district',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          value: _selectedDistrict,
                          icon: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          items: _districts.map((String district) {
                            return DropdownMenuItem<String>(
                              value: district,
                              child: Text(
                                district,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedDistrict = newValue;
                              _selectedLoungeOwner =
                                  null; // Reset lounge owner when district changes
                              _selectedLounge =
                                  null; // Reset lounge selection when district changes
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.medium),

              // Select Lounge Owner Dropdown (only enabled if district is selected)
              Opacity(
                opacity: _selectedDistrict == null ? 0.5 : 1.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.medium,
                    vertical: AppSpacing.small / 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        color: AppColors.secondary,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.small),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: Text(
                              _selectedDistrict == null
                                  ? 'Select district first'
                                  : availableLoungeOwners.isEmpty
                                  ? 'No lounge owners in this district'
                                  : 'Select lounge owner',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            value: _selectedLoungeOwner,
                            icon: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            items: availableLoungeOwners.map((String owner) {
                              return DropdownMenuItem<String>(
                                value: owner,
                                child: Text(
                                  owner,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged:
                                _selectedDistrict == null ||
                                    availableLoungeOwners.isEmpty
                                ? null
                                : (String? newValue) {
                                    setState(() {
                                      _selectedLoungeOwner = newValue;
                                      _selectedLounge =
                                          null; // Reset lounge when owner changes
                                    });
                                  },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.medium),

              // Select Lounge Dropdown (only enabled if district and lounge owner are selected)
              Opacity(
                opacity:
                    _selectedDistrict == null || _selectedLoungeOwner == null
                    ? 0.5
                    : 1.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.medium,
                    vertical: AppSpacing.small / 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.store_outlined,
                        color: AppColors.secondary,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.small),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: Text(
                              _selectedDistrict == null ||
                                      _selectedLoungeOwner == null
                                  ? 'Select lounge owner first'
                                  : availableLounges.isEmpty
                                  ? 'No lounges in this district'
                                  : 'Select your lounge',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            value: _selectedLounge,
                            icon: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            items: availableLounges.map((String lounge) {
                              return DropdownMenuItem<String>(
                                value: lounge,
                                child: Text(
                                  lounge,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged:
                                _selectedDistrict == null ||
                                    _selectedLoungeOwner == null ||
                                    availableLounges.isEmpty
                                ? null
                                : (String? newValue) {
                                    setState(() {
                                      _selectedLounge = newValue;
                                    });
                                  },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (_selectedDistrict != null &&
                  _selectedLoungeOwner != null &&
                  availableLounges.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.small),
                  child: Text(
                    '${availableLounges.length} lounge${availableLounges.length == 1 ? '' : 's'} available in $_selectedDistrict',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

              const SizedBox(height: AppSpacing.medium),

              // Select Button
              InkWell(
                onTap:
                    _selectedDistrict != null &&
                        _selectedLoungeOwner != null &&
                        _selectedLounge != null
                    ? () {
                        // Navigate to staff registration
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const StaffRegistrationPage(),
                          ),
                        );
                      }
                    : null,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.large,
                    vertical: AppSpacing.small,
                  ),
                  decoration: BoxDecoration(
                    color:
                        _selectedDistrict != null &&
                            _selectedLoungeOwner != null &&
                            _selectedLounge != null
                        ? AppColors.secondary
                        : AppColors.secondary.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow:
                        _selectedDistrict != null &&
                            _selectedLoungeOwner != null &&
                            _selectedLounge != null
                        ? [
                            BoxShadow(
                              color: AppColors.secondary.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [],
                  ),
                  child: Text(
                    'Select',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textLight,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
