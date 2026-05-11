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
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;
  final String? caption;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: highlight
                    ? Colors.white.withValues(alpha: 0.18)
                    : accentColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: highlight ? Colors.white : accentColor,
                size: 18,
              ),
            ),
            const Spacer(),
          ],
        ),
        const Spacer(),
        Text(
          label,
          style: TextStyle(
            color: highlight ? Colors.white70 : AppColors.muted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: highlight ? Colors.white : AppColors.text,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        if (caption != null) ...[
          const SizedBox(height: 4),
          Text(
            caption!,
            style: TextStyle(
              color: highlight
                  ? Colors.white.withValues(alpha: 0.78)
                  : accentColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );

    if (!highlight) {
      return AppCard(child: SizedBox(height: 118, child: content));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      height: 118,
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
  }
}
