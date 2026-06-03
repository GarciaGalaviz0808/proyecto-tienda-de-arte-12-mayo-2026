import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_typography.dart';
import '../core/constants/app_dimensions.dart';
import '../providers/cart_provider.dart';
import '../widgets/price_tag.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Carrito de Compras',
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<CartProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.cart == null) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (provider.cart == null || provider.cart!.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_cart_outlined,
                      size: 64, color: AppColors.borderSubtle),
                  const SizedBox(height: 16),
                  Text('Tu carrito está vacío',
                      style: AppTypography.titleMedium),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Continuar comprando'),
                  ),
                ],
              ),
            );
          }

          final cart = provider.cart!;

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  itemCount: cart.items.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppDimensions.paddingM),
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusCard),
                        boxShadow: AppDimensions.shadowStandard,
                      ),
                      padding: const EdgeInsets.all(AppDimensions.paddingS),
                      child: Row(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.backgroundSecondary,
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusButton),
                            ),
                            child: const Center(
                                child: Icon(Icons.image,
                                    color: AppColors.borderSubtle)),
                          ),
                          const SizedBox(width: AppDimensions.paddingM),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.brandSnapshot,
                                  style: AppTypography.labelSmall
                                      .copyWith(color: AppColors.textSecondary),
                                ),
                                Text(
                                  item.nameSnapshot,
                                  style: AppTypography.titleMedium,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                PriceTag(
                                    price: item.priceSnapshot,
                                    discountPrice: null,
                                    compact: true),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: AppColors.error),
                                onPressed: () {
                                  provider.removeItem(item.prodId);
                                },
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: AppColors.borderSubtle),
                                  borderRadius: BorderRadius.circular(
                                      AppDimensions.radiusButton),
                                ),
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove, size: 16),
                                      onPressed: item.quantity > 1
                                          ? () => provider.updateQuantity(
                                              item.prodId,
                                              item.quantity - 1,
                                              999)
                                          : null,
                                      constraints: const BoxConstraints(),
                                      padding: const EdgeInsets.all(4),
                                    ),
                                    Text('${item.quantity}',
                                        style: AppTypography.bodyMedium),
                                    IconButton(
                                      icon: const Icon(Icons.add, size: 16),
                                      onPressed: () => provider.updateQuantity(
                                          item.prodId, item.quantity + 1, 999),
                                      constraints: const BoxConstraints(),
                                      padding: const EdgeInsets.all(4),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Order Summary Bottom Sheet
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Subtotal:', style: AppTypography.bodyLarge),
                          Text(
                            '\$${cart.total.toStringAsFixed(2)}',
                            style: AppTypography.titleLarge
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.paddingL),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const CheckoutScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusButton),
                            ),
                          ),
                          child: const Text('Proceder al Pago',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
