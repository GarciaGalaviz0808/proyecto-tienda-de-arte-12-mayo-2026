import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_typography.dart';
import '../core/constants/app_dimensions.dart';
import '../providers/product_provider.dart';
import '../widgets/category_tile.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Explorar Categorías',
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.categories.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (provider.categories.isEmpty) {
            return const Center(child: Text('No hay categorías disponibles.'));
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadCategories(),
            color: AppColors.primary,
            child: GridView.builder(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppDimensions.paddingM,
                mainAxisSpacing: AppDimensions.paddingM,
                childAspectRatio: 1.0,
              ),
              itemCount: provider.categories.length,
              itemBuilder: (context, index) {
                final category = provider.categories[index];
                return CategoryTile(
                  category: category,
                  onTap: () {
                    // TODO: Navigate to CatalogScreen filtered by this category
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
