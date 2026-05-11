import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../models/category_model.dart';

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.category,
    this.selected = false,
    this.onTap,
  });

  final CategoryModel category;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      selected: selected,
      onSelected: (_) => onTap?.call(),
      label: Text(category.name),
      selectedColor: AppColors.primary.withValues(alpha: 0.14),
      labelStyle: TextStyle(
        color: selected ? AppColors.primary : AppColors.text,
      ),
    );
  }
}
