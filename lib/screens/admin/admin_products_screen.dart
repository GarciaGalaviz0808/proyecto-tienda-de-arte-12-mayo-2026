import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/app_dimensions.dart';
import '../../services/product_service.dart';
import '../../services/admin_service.dart';
import '../../providers/auth_provider.dart';
import '../../models/product_model.dart';
import '../../widgets/price_tag.dart';
import 'admin_product_form_screen.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  final ProductService _productService = ProductService();
  final AdminService _adminService = AdminService();
  List<ProductModel> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      _products = await _productService.getAllProducts();
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  void _openProductForm({ProductModel? product}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminProductFormScreen(product: product),
      ),
    );
    if (result == true) _loadProducts();
  }

  void _confirmDelete(ProductModel product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        ),
        title: const Text('Confirmar Eliminación'),
        content: Text('¿Eliminar "${product.name}"?\nSe marcará como inactivo.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final adminId = context.read<AuthProvider>().user?.uid ?? '';
              try {
                await _adminService.softDeleteProduct(product.prodId, adminId);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Producto eliminado'), backgroundColor: AppColors.success),
                  );
                  _loadProducts();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.surface,
            ),
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
          'Productos (${_products.length})',
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProducts,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openProductForm(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Producto'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _products.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.borderSubtle),
                      const SizedBox(height: 16),
                      Text('No hay productos', style: AppTypography.titleMedium),
                      const SizedBox(height: 8),
                      Text(
                        'Crea tu primer producto para empezar a vender.',
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadProducts,
                  color: AppColors.primary,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(AppDimensions.paddingM),
                    itemCount: _products.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppDimensions.paddingS),
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                          border: Border.all(
                            color: product.isActive ? AppColors.borderSubtle : AppColors.error.withValues(alpha: 0.3),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(AppDimensions.paddingS),
                          leading: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppColors.backgroundSecondary,
                              borderRadius: BorderRadius.circular(AppDimensions.radiusCategoryBadge),
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
                            style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(product.brandName, style: AppTypography.labelMedium.copyWith(color: AppColors.primary)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  PriceTag(price: product.price, discountPrice: product.discountPrice, compact: true),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: product.isActive
                                          ? AppColors.success.withValues(alpha: 0.1)
                                          : AppColors.error.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      product.isActive ? 'Stock: ${product.stock}' : 'Inactivo',
                                      style: AppTypography.labelSmall.copyWith(
                                        color: product.isActive ? AppColors.success : AppColors.error,
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
                                icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                                onPressed: () => _openProductForm(product: product),
                                tooltip: 'Editar',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                                onPressed: () => _confirmDelete(product),
                                tooltip: 'Eliminar',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
