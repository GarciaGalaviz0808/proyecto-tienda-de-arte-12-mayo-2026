import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_typography.dart';
import '../core/constants/app_dimensions.dart';
import '../models/coupon_model.dart';
import 'package:intl/intl.dart';

class CouponCard extends StatelessWidget {
  final CouponModel coupon;
  final VoidCallback? onApply;
  final bool isApplied;

  const CouponCard({
    super.key,
    required this.coupon,
    this.onApply,
    this.isApplied = false,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');
    
    return Container(
      decoration: BoxDecoration(
        color: isApplied ? AppColors.primaryLight.withValues(alpha: 0.1) : AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(
          color: isApplied ? AppColors.primary : AppColors.borderSubtle,
          width: isApplied ? 2 : 1,
        ),
        boxShadow: AppDimensions.shadowStandard,
      ),
      child: Row(
        children: [
          // Left side (Discount)
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.radiusCard),
                bottomLeft: Radius.circular(AppDimensions.radiusCard),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  coupon.type == 'percentage' 
                      ? '${coupon.value.toInt()}%'
                      : '\$${coupon.value.toInt()}',
                  style: AppTypography.titleLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'DTO',
                  style: AppTypography.labelSmall.copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ),
          // Dashed line could go here (custom painter)
          // Right side (Details)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coupon.code,
                    style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  if (coupon.minPurchase > 0)
                    Text(
                      'Compra mínima: \$${coupon.minPurchase.toStringAsFixed(2)}',
                      style: AppTypography.bodySmall,
                    ),
                  Text(
                    'Válido hasta: ${dateFormat.format(coupon.expiresAt)}',
                    style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          if (onApply != null)
            Padding(
              padding: const EdgeInsets.only(right: AppDimensions.paddingM),
              child: TextButton(
                onPressed: onApply,
                child: Text(isApplied ? 'Quitar' : 'Aplicar'),
              ),
            ),
        ],
      ),
    );
  }
}
