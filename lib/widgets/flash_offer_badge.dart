import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_typography.dart';

class FlashOfferBadge extends StatelessWidget {
  final double discountPercent;

  const FlashOfferBadge({super.key, required this.discountPercent});

  @override
  Widget build(BuildContext context) {
    if (discountPercent <= 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: AppColors.error.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_fire_department, color: AppColors.surface, size: 14),
          const SizedBox(width: 4),
          Text(
            '-${discountPercent.toStringAsFixed(0)}%',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.surface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
