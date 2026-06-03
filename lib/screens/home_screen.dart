import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_typography.dart';
import '../core/constants/app_dimensions.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card_art.dart';
import '../widgets/shimmer_product_card.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchCategories();
      context.read<ProductProvider>().fetchBanners();
      context.read<ProductProvider>().fetchActiveProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Eli\'s Art Supplies',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.textPrimary),
            onPressed: () {
              // TODO: Implement search
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined,
                color: AppColors.textPrimary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          if (productProvider.isLoading && productProvider.products.isEmpty) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (productProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar los productos',
                    style: AppTypography.titleMedium,
                  ),
                  TextButton(
                    onPressed: () => productProvider.fetchActiveProducts(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await productProvider.fetchBanners();
              await productProvider.fetchCategories();
              await productProvider.fetchActiveProducts();
            },
            color: AppColors.primary,
            child: CustomScrollView(
              slivers: [
                // Banners Section
                if (productProvider.banners.isNotEmpty)
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 180,
                      child: PageView.builder(
                        itemCount: productProvider.banners.length,
                        itemBuilder: (context, index) {
                          final banner = productProvider.banners[index];
                          return Container(
                            margin:
                                const EdgeInsets.all(AppDimensions.paddingM),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusCard),
                              color: AppColors.backgroundSecondary,
                              image: DecorationImage(
                                image: NetworkImage(banner.imageUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusCard),
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.6),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                              padding:
                                  const EdgeInsets.all(AppDimensions.paddingM),
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                banner.title,
                                style: AppTypography.titleLarge
                                    .copyWith(color: AppColors.surface),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                // Categories Section
                if (productProvider.categories.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.paddingM,
                              vertical: AppDimensions.paddingS),
                          child: Text('Categorías',
                              style: AppTypography.titleLarge),
                        ),
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.paddingS),
                            itemCount: productProvider.categories.length,
                            itemBuilder: (context, index) {
                              final category =
                                  productProvider.categories[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: AppDimensions.paddingS),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.surface,
                                        border: Border.all(
                                            color: AppColors.borderSubtle),
                                        image: category.imageUrl != null
                                            ? DecorationImage(
                                                image: NetworkImage(
                                                    category.imageUrl!),
                                                fit: BoxFit.cover,
                                              )
                                            : null,
                                      ),
                                      child: category.imageUrl == null
                                          ? const Icon(Icons.category,
                                              color: AppColors.primary)
                                          : null,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      category.name,
                                      style: AppTypography.labelMedium,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                // Featured Products Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingM),
                    child: Text('Destacados', style: AppTypography.titleLarge),
                  ),
                ),

                // Staggered Products Grid
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingM),
                  sliver: SliverMasonryGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: AppDimensions.paddingM,
                    crossAxisSpacing: AppDimensions.paddingM,
                    childCount: productProvider.isLoading
                        ? 6
                        : productProvider.products.length,
                    itemBuilder: (context, index) {
                      if (productProvider.isLoading) {
                        return const ShimmerProductCard();
                      }

                      final product = productProvider.products[index];
                      return ProductCardArt(
                        product: product,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ProductDetailScreen(product: product)),
                          );
                        },
                        onFavoriteTap: () {
                          // TODO: Toggle favorite
                        },
                      );
                    },
                  ),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: AppDimensions.paddingL),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
