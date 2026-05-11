import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    required this.mine,
    this.time,
  });

  final String message;
  final bool mine;
  final String? time;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 290),
        decoration: BoxDecoration(
          color: mine ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(mine ? 16 : 4),
            bottomRight: Radius.circular(mine ? 4 : 16),
          ),
          border: mine ? null : Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x100F172A),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: mine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextStyle(
                color: mine ? Colors.white : AppColors.text,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (time != null) ...[
              const SizedBox(height: 4),
              Text(
                time!,
                style: TextStyle(
                  color: mine ? Colors.white70 : AppColors.muted,
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
