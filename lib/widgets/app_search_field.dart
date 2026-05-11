import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    required this.hint,
    this.controller,
    this.onChanged,
    this.trailingIcon,
  });

  final String hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.muted, fontSize: 13),
        prefixIcon: const Icon(Icons.search, color: AppColors.muted),
        suffixIcon: trailingIcon == null
            ? null
            : Icon(trailingIcon, color: AppColors.primary),
      ),
    );
  }
}
