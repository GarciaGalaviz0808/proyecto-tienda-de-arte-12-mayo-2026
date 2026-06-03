import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_typography.dart';
import '../core/constants/app_dimensions.dart';
// import '../providers/coupon_provider.dart'; // To be implemented or managed by Cart/Loyalty
import '../widgets/coupon_card.dart';
import '../models/coupon_model.dart';

class CouponsScreen extends StatelessWidget {
  const CouponsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock coupons since we don't have a specific user-coupon fetcher yet
    // Typically this would come from a provider based on active coupons
    final mockCoupons = [
      CouponModel(
        code: 'BIENVENIDA',
        type: 'percentage',
        value: 10,
        minPurchase: 0,
        maxUses: 1,
        usedCount: 0,
        expiresAt: DateTime.now().add(const Duration(days: 30)),
        isActive: true,
        createdAt: DateTime.now(),
      ),
      CouponModel(
        code: 'ARTE50',
        type: 'fixed',
        value: 50,
        minPurchase: 500,
        maxUses: 100,
        usedCount: 12,
        expiresAt: DateTime.now().add(const Duration(days: 15)),
        isActive: true,
        createdAt: DateTime.now(),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Mis Cupones',
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: mockCoupons.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.local_activity_outlined, size: 64, color: AppColors.borderSubtle),
                  const SizedBox(height: 16),
                  Text('No tienes cupones disponibles.', style: AppTypography.titleMedium),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              itemCount: mockCoupons.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppDimensions.paddingM),
              itemBuilder: (context, index) {
                return CouponCard(
                  coupon: mockCoupons[index],
                  onApply: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Cupón ${mockCoupons[index].code} copiado al portapapeles')),
                    );
                  },
                );
              },
            ),
    );
  }
}
