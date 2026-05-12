import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import 'status_chip.dart';

class OrderStatusChip extends StatelessWidget {
  const OrderStatusChip({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'selesai' || 'dibayar' => AppColors.success,
      'diproses' || 'dikirim' || 'menunggu_konfirmasi' => AppColors.warning,
      'dibatalkan' => AppColors.danger,
      _ => AppColors.primary,
    };
    final label = switch (status) {
      'diterima' => 'Diterima',
      'diproses' => 'Diproses',
      'dikirim' => 'Dikirim',
      'selesai' => 'Selesai',
      'dibatalkan' => 'Dibatalkan',
      'belum_dibayar' => 'Belum dibayar',
      'menunggu_konfirmasi' => 'Menunggu konfirmasi',
      'dibayar' => 'Dibayar',
      _ => status,
    };
    return StatusChip(label: label, color: color);
  }
}
