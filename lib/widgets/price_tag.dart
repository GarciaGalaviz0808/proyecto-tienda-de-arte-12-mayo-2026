import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_typography.dart';

class PriceTag extends StatelessWidget {
  final double price;
  final double? discountPrice;
  final bool compact;

  const PriceTag({
    super.key,
    required this.price,
    this.discountPrice,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasDiscount = discountPrice != null && discountPrice! < price;

    if (hasDiscount) {
      final double discountPercent = ((price - discountPrice!) / price) * 100;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                "\$${price.toStringAsFixed(2)}",
                style: AppTypography.bodySmall.copyWith(
                  decoration: TextDecoration.lineThrough,
                  color: AppColors.textSecondary,
                  fontSize: compact ? 12 : 14,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.secondaryAccent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "-${discountPercent.toStringAsFixed(0)}%",
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.surface,
                    fontSize: compact ? 8 : 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            "\$${discountPrice!.toStringAsFixed(2)}",
            style: AppTypography.headlineSmall.copyWith(
              color: AppColors.primaryAccent,
              fontSize: compact ? 16 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    } else {
      return Text(
        "\$${price.toStringAsFixed(2)}",
        style: AppTypography.titleMedium.copyWith(
          color: AppColors.textPrimary,
          fontSize: compact ? 14 : 18,
          fontWeight: FontWeight.bold,
        ),
      );
    }
  }
}
