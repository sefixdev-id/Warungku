import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/app_card.dart';

class WarungAddressScreen extends StatelessWidget {
  const WarungAddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Alamat Warungku',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: AppColors.lightBlue,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.storefront,
                        color: AppColors.primary,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppConstants.appName,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      AppConstants.appSubtitle,
                      style: TextStyle(color: AppColors.muted),
                    ),
                    const Divider(height: 28),
                    _row(
                      Icons.place_outlined,
                      'Alamat',
                      AppConstants.warungAddress,
                    ),
                    _row(
                      Icons.schedule_outlined,
                      'Jam buka',
                      AppConstants.warungOpenHours,
                    ),
                    _row(
                      Icons.phone_outlined,
                      'Kontak',
                      AppConstants.warungPhone,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Silakan hubungi admin untuk informasi stok dan pemesanan.',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
              const SizedBox(height: 3),
              Text(value, style: const TextStyle(color: AppColors.muted)),
            ],
          ),
        ),
      ],
    ),
  );
}
