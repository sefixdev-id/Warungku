import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/helpers/image_url_helper.dart';

class UniversalNetworkImage extends StatelessWidget {
  const UniversalNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.fallbackIcon = Icons.inventory_2_outlined,
    this.borderRadius,
  });

  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final IconData fallbackIcon;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final normalized = normalizeImageUrl(imageUrl);
    final child = normalized.isEmpty
        ? _Placeholder(width: width, height: height, icon: fallbackIcon)
        : Container(
            width: width,
            height: height,
            color: AppColors.lightBlue,
            child: Image.network(
              normalized,
              width: width,
              height: height,
              fit: fit,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return _Placeholder(
                  width: width,
                  height: height,
                  icon: fallbackIcon,
                  loading: true,
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return _Placeholder(
                  width: width,
                  height: height,
                  icon: fallbackIcon,
                );
              },
            ),
          );

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(18),
      child: child,
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({
    required this.width,
    required this.height,
    required this.icon,
    this.loading = false,
  });

  final double? width;
  final double? height;
  final IconData icon;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.lightBlue,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Center(
        child: loading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon, color: AppColors.primary, size: 42),
      ),
    );
  }
}
