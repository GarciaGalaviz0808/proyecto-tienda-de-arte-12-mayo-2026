import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_typography.dart';
import '../core/constants/app_dimensions.dart';
import '../providers/wishlist_provider.dart';
import '../widgets/product_card_art.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Mis Favoritos',
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<WishlistProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.wishlistProducts.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (provider.wishlistProducts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.favorite_border, size: 64, color: AppColors.borderSubtle),
                  const SizedBox(height: 16),
                  Text('Aún no tienes favoritos', style: AppTypography.titleMedium),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppDimensions.paddingM,
              mainAxisSpacing: AppDimensions.paddingM,
              childAspectRatio: 0.65,
            ),
            itemCount: provider.wishlistProducts.length,
            itemBuilder: (context, index) {
              final product = provider.wishlistProducts[index];
              return ProductCardArt(
                product: product,
                isFavorite: true,
                onTap: () {
                  // TODO: Navigate to detail
                },
                onFavoriteTap: () {
                  provider.toggleFavorite(product.id);
                },
              );
            },
          );
        },
      ),
    );
  }
}
