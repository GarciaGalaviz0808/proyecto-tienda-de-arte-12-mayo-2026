import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_typography.dart';
import '../core/constants/app_dimensions.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../widgets/price_tag.dart';
import '../widgets/flash_offer_badge.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final bool isFavorite = context.watch<WishlistProvider>().isFavorite(widget.product.id);

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: CustomScrollView(
        slivers: [
          // App Bar & Image Gallery
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            backgroundColor: AppColors.surface,
            iconTheme: const IconThemeData(color: AppColors.textPrimary),
            actions: [
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? AppColors.error : AppColors.textPrimary,
                ),
                onPressed: () {
                  context.read<WishlistProvider>().toggleFavorite(widget.product.id);
                },
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: widget.product.images.isNotEmpty
                  ? PageView.builder(
                      itemCount: widget.product.images.length,
                      itemBuilder: (context, index) {
                        return Image.network(
                          widget.product.images[index],
                          fit: BoxFit.cover,
                        );
                      },
                    )
                  : const Center(
                      child: Icon(Icons.image_outlined, size: 64, color: AppColors.borderSubtle),
                    ),
            ),
          ),
          
          // Content
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.backgroundPrimary,
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand & Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.product.brandName.toUpperCase(),
                        style: AppTypography.labelLarge.copyWith(color: AppColors.primary),
                      ),
                      if (widget.product.discountPrice != null)
                        FlashOfferBadge(
                          discountPercent: ((widget.product.price - widget.product.discountPrice!) / widget.product.price) * 100,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Title
                  Text(
                    widget.product.name,
                    style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  // Price & Reviews
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      PriceTag(
                        price: widget.product.price,
                        discountPrice: widget.product.discountPrice,
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: AppColors.loyaltyGold, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            widget.product.rating.toStringAsFixed(1),
                            style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            ' (${widget.product.reviewCount})',
                            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  
                  // Stock Status
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.product.isAvailable ? AppColors.success : AppColors.error,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.product.isAvailable 
                            ? 'En stock (${widget.product.stock} disponibles)'
                            : 'Agotado',
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: widget.product.isAvailable ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Description
                  Text('Descripción', style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.description,
                    style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary, height: 1.5),
                  ),
                  
                  // Keep space for bottom bar
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Quantity Selector
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.borderSubtle),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: _quantity > 1
                          ? () => setState(() => _quantity--)
                          : null,
                    ),
                    Text('$_quantity', style: AppTypography.titleMedium),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _quantity < widget.product.stock
                          ? () => setState(() => _quantity++)
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.paddingM),
              // Add to Cart Button
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: widget.product.isAvailable
                        ? () {
                            context.read<CartProvider>().addItem(widget.product, _quantity);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Agregado al carrito')),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                      ),
                    ),
                    child: const Text('Agregar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
