import 'package:flutter/material.dart';
import '../../config/theme_config.dart';
import 'add_tuk_tuk_page.dart';

class DriverListPage extends StatelessWidget {
  const DriverListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      /// AppBar
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Driver List',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),

      /// Body
      body: Column(
        children: [
          const SizedBox(height: 80),

          /// Empty State
          Icon(
            Icons.person_outline,
            size: 120,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Drivers Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add drivers to manage and assign\nTuk Tuk services easily.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),

      /// Add Driver Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTukTukPage(),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textLight,
        icon: const Icon(Icons.add),
        label: const Text(
          'Add Driver',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
