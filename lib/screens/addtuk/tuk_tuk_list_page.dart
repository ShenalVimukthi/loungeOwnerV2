import 'package:flutter/material.dart';
import '../../config/theme_config.dart';

class TukTukListPage extends StatelessWidget {
  const TukTukListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tuk Tuk List',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          TukTukCard(
            name: 'Sunil Perera',
            vehicleNo: 'NB-1234',
            phone: '0711234567',
          ),
          SizedBox(height: 16),
          TukTukCard(
            name: 'Sandun Weerasinghe',
            vehicleNo: 'NB-1234',
            phone: '0711234567',
          ),
          SizedBox(height: 16),
          TukTukCard(
            name: 'Avishka Fernando',
            vehicleNo: 'NB-1234',
            phone: '0711234567',
          ),
        ],
      ),
    );
  }
}

class TukTukCard extends StatelessWidget {
  final String name;
  final String vehicleNo;
  final String phone;

  const TukTukCard({
    super.key,
    required this.name,
    required this.vehicleNo,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Top Row (Avatar + Name)
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: const Icon(Icons.person, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Tuk Tuk',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// Vehicle Number
          Row(
            children: [
              const Icon(Icons.directions_car, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(vehicleNo, style: const TextStyle(color: AppColors.textPrimary)),
            ],
          ),

          const SizedBox(height: 8),

          /// Phone + Call Button
          Row(
            children: [
              const Icon(Icons.phone, size: 18, color: AppColors.success),
              const SizedBox(width: 8),
              Text(phone, style: const TextStyle(color: AppColors.textPrimary)),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.call, size: 16),
                label: const Text('Call'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: AppColors.textLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          /// Assign Driver Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: AppColors.textLight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Assign Driver', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
