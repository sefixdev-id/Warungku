import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import 'app_card.dart';

class DashboardMetricCard extends StatelessWidget {
  const DashboardMetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.accentColor = AppColors.primary,
    this.caption,
    this.highlight = false,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;
  final String? caption;
  final bool highlight;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: highlight
                ? Colors.white.withValues(alpha: 0.18)
                : accentColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: highlight ? Colors.white : accentColor,
            size: 17,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: highlight ? Colors.white70 : AppColors.muted,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: highlight ? Colors.white : AppColors.text,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        if (caption != null) ...[
          const SizedBox(height: 5),
          Text(
            caption!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: highlight
                  ? Colors.white.withValues(alpha: 0.78)
                  : accentColor,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );

    final card = !highlight
        ? AppCard(padding: const EdgeInsets.all(14), child: content)
        : Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x332563EB),
                  blurRadius: 22,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: content,
          );

    if (onTap == null) return card;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Stack(
          children: [
            Positioned.fill(child: card),
            Positioned(
              right: 10,
              bottom: 10,
              child: Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: highlight
                    ? Colors.white.withValues(alpha: 0.85)
                    : accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
