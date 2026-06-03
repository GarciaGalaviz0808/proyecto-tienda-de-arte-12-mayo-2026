import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_typography.dart';

class LoyaltyBadge extends StatelessWidget {
  final String level;
  final int points;

  const LoyaltyBadge({super.key, required this.level, required this.points});

  Color get _levelColor {
    switch (level.toLowerCase()) {
      case 'bronce':
        return AppColors.loyaltyBronze;
      case 'plata':
        return AppColors.loyaltySilver;
      case 'oro':
        return AppColors.loyaltyGold;
      default:
        return AppColors.loyaltyBronze;
    }
  }

  IconData get _levelIcon {
    switch (level.toLowerCase()) {
      case 'bronce':
        return Icons.star_border;
      case 'plata':
        return Icons.star_half;
      case 'oro':
        return Icons.star;
      default:
        return Icons.star_border;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _levelColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _levelColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_levelIcon, color: _levelColor, size: 16),
          const SizedBox(width: 6),
          Text(
            '$level • $points pts',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
