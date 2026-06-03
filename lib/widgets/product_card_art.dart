import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_typography.dart';
import '../core/constants/app_dimensions.dart';
import '../models/product_model.dart';
import 'price_tag.dart';
import 'shimmer_product_card.dart';

class ProductCardArt extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;
  final bool isFavorite;

  const ProductCardArt({
    super.key,
    required this.product,
    this.onTap,
    this.onFavoriteTap,
    this.isFavorite = false,
  });

  String _statusLabel(String status) {
    switch (status) {
      case 'new':
        return 'Nuevo';
      case 'limited':
        return 'Ed. Limitada';
      case 'sold_out':
        return 'Agotado';
      case 'offer':
        return 'Oferta';
      default:
        return '';
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'new':
        return AppColors.success;
      case 'limited':
        return AppColors.loyaltyGold;
      case 'sold_out':
        return AppColors.error;
      case 'offer':
        return AppColors.warning;
      default:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = _statusLabel(product.status);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 260,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusProductCard),
          boxShadow: AppDimensions.shadowStandard,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            Expanded(
              child: Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: product.images.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: product.images.first,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => const ShimmerProductCard(),
                            errorWidget: (_, __, ___) => Container(
                              color: AppColors.backgroundSecondary,
                              child: const Icon(Icons.palette_outlined, size: 48, color: AppColors.borderSubtle),
                            ),
                          )
                        : Container(
                            color: AppColors.backgroundSecondary,
                            child: const Center(
                              child: Icon(Icons.image_outlined, size: 48, color: AppColors.borderSubtle),
                            ),
                          ),
                  ),
                  // Status badge
                  if (label.isNotEmpty)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _statusColor(product.status),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          label,
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.surface,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  // Favorite button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onFavoriteTap,
                      child: AnimatedScale(
                        scale: isFavorite ? 1.1 : 1.0,
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.surface.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            size: 18,
                            color: isFavorite ? AppColors.error : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Info section
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.brandName,
                    style: AppTypography.bodySmall.copyWith(fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.name,
                    style: AppTypography.titleMedium.copyWith(fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PriceTag(
                        price: product.price,
                        discountPrice: product.discountPrice,
                        compact: true,
                      ),
                      // Stock dot indicator
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: product.isAvailable ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
