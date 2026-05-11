import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import 'status_chip.dart';

class DebtStatusChip extends StatelessWidget {
  const DebtStatusChip({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'lunas' => AppColors.success,
      'cicil' => AppColors.warning,
      _ => AppColors.danger,
    };
    final label = switch (status) {
      'lunas' => 'Lunas',
      'cicil' => 'Cicil',
      _ => 'Belum lunas',
    };
    return StatusChip(label: label, color: color);
  }
}
