import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/app_dimensions.dart';
import '../../providers/product_provider.dart';
import '../../models/product_model.dart';
import '../../widgets/price_tag.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  @override
  void initState() {
    super.initState();
    // Admin needs to see all products, not just active ones
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // For now we use the regular fetch. A real app might have an fetchAllProducts
      context.read<ProductProvider>().fetchActiveProducts();
    });
  }

  void _showAddEditProductDialog(BuildContext context,
      {ProductModel? product}) {
    // Placeholder for product add/edit dialog/screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Formulario de producto (Próximamente)')),
    );
  }

  void _confirmDelete(BuildContext context, ProductModel product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text(
            '¿Estás seguro de que deseas eliminar "${product.name}"? Esta acción marcará el producto como inactivo (Soft delete).'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              // TODO: Call admin service to soft delete
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Producto marcado como inactivo')),
              );
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.surface),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Gestión de Productos',
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditProductDialog(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Producto'),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.products.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.products.isEmpty) {
            return const Center(child: Text('No hay productos registrados.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            itemCount: provider.products.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppDimensions.paddingS),
            itemBuilder: (context, index) {
              final product = provider.products[index];
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(AppDimensions.paddingS),
                  leading: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundSecondary,
                      borderRadius: BorderRadius.circular(
                          AppDimensions.radiusCategoryBadge),
                      image: product.images.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(product.images.first),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: product.images.isEmpty
                        ? const Icon(Icons.image, color: AppColors.borderSubtle)
                        : null,
                  ),
                  title: Text(
                    product.name,
                    style: AppTypography.titleMedium
                        .copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.brandName,
                          style: AppTypography.labelMedium
                              .copyWith(color: AppColors.primary)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          PriceTag(
                              price: product.price,
                              discountPrice: product.discountPrice,
                              compact: true),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: product.isAvailable
                                  ? AppColors.success.withValues(alpha: 0.1)
                                  : AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Stock: ${product.stock}',
                              style: AppTypography.labelSmall.copyWith(
                                color: product.isAvailable
                                    ? AppColors.success
                                    : AppColors.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined,
                            color: AppColors.primary),
                        onPressed: () => _showAddEditProductDialog(context,
                            product: product),
                        tooltip: 'Editar',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: AppColors.error),
                        onPressed: () => _confirmDelete(context, product),
                        tooltip: 'Eliminar',
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
