import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class WarungkuLogo extends StatelessWidget {
  const WarungkuLogo({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.lightBlue,
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      child: Icon(
        Icons.storefront_rounded,
        color: AppColors.primary,
        size: size * 0.62,
      ),
    );
  }
}
