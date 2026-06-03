import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_typography.dart';
import '../core/constants/app_dimensions.dart';
import '../models/category_model.dart';

class CategoryTile extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onTap;

  const CategoryTile({
    super.key,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          boxShadow: AppDimensions.shadowStandard,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            if (category.imageUrl != null)
              Positioned.fill(
                child: Image.network(
                  category.imageUrl!,
                  fit: BoxFit.cover,
                ),
              ),
            if (category.imageUrl != null)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.4),
                ),
              ),
            if (category.imageUrl == null)
              const Center(
                child: Icon(Icons.category, size: 48, color: AppColors.primaryLight),
              ),
            Center(
              child: Text(
                category.name,
                style: AppTypography.titleMedium.copyWith(
                  color: category.imageUrl != null ? AppColors.surface : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
