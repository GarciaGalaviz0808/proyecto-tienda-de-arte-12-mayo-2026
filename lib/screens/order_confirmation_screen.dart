import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_typography.dart';
import '../core/constants/app_dimensions.dart';
import '../models/order_model.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final OrderModel order;

  const OrderConfirmationScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingXL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle,
                    color: AppColors.success, size: 64),
              ),
              const SizedBox(height: AppDimensions.paddingXL),
              Text(
                '¡Pedido Confirmado!',
                style: AppTypography.headlineMedium
                    .copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.paddingM),
              Text(
                'Gracias por tu compra en Eli\'s Art Supplies. Tu pedido ha sido recibido y está siendo procesado.',
                style: AppTypography.bodyLarge
                    .copyWith(color: AppColors.textSecondary, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.paddingL),
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                ),
                child: Column(
                  children: [
                    Text('Número de Pedido', style: AppTypography.labelMedium),
                    const SizedBox(height: 4),
                    Text(
                      order.orderId.substring(0, 8).toUpperCase(),
                      style: AppTypography.titleLarge.copyWith(
                          fontWeight: FontWeight.bold, letterSpacing: 2),
                    ),
                  ],
                ),
              ),
              if (order.loyaltyPointsEarned > 0) ...[
                const SizedBox(height: AppDimensions.paddingL),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, color: AppColors.loyaltyGold),
                    const SizedBox(width: 8),
                    Text(
                      '¡Ganaste ${order.loyaltyPointsEarned} puntos!',
                      style: AppTypography.titleMedium.copyWith(
                          color: AppColors.loyaltyGold,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate back to home and clear stack
                    context.go('/home');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusButton),
                    ),
                  ),
                  child: const Text('Volver al Inicio',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
