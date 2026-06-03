import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/app_dimensions.dart';
import '../../models/product_model.dart';
import '../../models/category_model.dart';
import '../../models/brand_model.dart';
import '../../providers/product_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/admin_service.dart';

class AdminProductFormScreen extends StatefulWidget {
  final ProductModel? product;

  const AdminProductFormScreen({super.key, this.product});

  @override
  State<AdminProductFormScreen> createState() => _AdminProductFormScreenState();
}

class _AdminProductFormScreenState extends State<AdminProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final AdminService _adminService = AdminService();

  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _discountPriceController;
  late TextEditingController _stockController;
  late TextEditingController _skuController;
  late TextEditingController _dimensionsController;
  late TextEditingController _weightController;
  late TextEditingController _materialsController;
  late TextEditingController _imageUrlController;

  String? _selectedCategoryId;
  String? _selectedBrandId;
  String _selectedTechnique = 'óleo';
  String _selectedSkillLevel = 'principiante';
  bool _isFeatured = false;
  bool _isActive = true;
  bool _isLoading = false;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p?.name ?? '');
    _descController = TextEditingController(text: p?.description ?? '');
    _priceController = TextEditingController(text: p?.price.toString() ?? '');
    _discountPriceController = TextEditingController(text: p?.discountPrice?.toString() ?? '');
    _stockController = TextEditingController(text: p?.stock.toString() ?? '0');
    _skuController = TextEditingController(text: p?.sku ?? '');
    _dimensionsController = TextEditingController(text: p?.dimensions ?? '');
    _weightController = TextEditingController(text: p?.weight ?? '');
    _materialsController = TextEditingController(text: p?.materials ?? '');
    _imageUrlController = TextEditingController(text: p?.images.isNotEmpty ?? false ? p!.images.first : '');

    _selectedCategoryId = p?.categoryId;
    _selectedBrandId = p?.brandId;
    _selectedTechnique = p?.technique ?? 'óleo';
    _selectedSkillLevel = p?.skillLevel ?? 'principiante';
    _isFeatured = p?.isFeatured ?? false;
    _isActive = p?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _discountPriceController.dispose();
    _stockController.dispose();
    _skuController.dispose();
    _dimensionsController.dispose();
    _weightController.dispose();
    _materialsController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final adminId = context.read<AuthProvider>().user?.uid ?? '';
      final productProvider = context.read<ProductProvider>();

      final category = productProvider.categories.firstWhere(
        (c) => c.catId == _selectedCategoryId,
        orElse: () => CategoryModel(catId: '', name: '', slug: '', iconUrl: '', description: '', displayOrder: 0, isActive: true),
      );
      final brand = productProvider.brands.firstWhere(
        (b) => b.brandId == _selectedBrandId,
        orElse: () => BrandModel(brandId: '', name: '', logoUrl: '', country: '', description: '', isActive: true),
      );

      final images = <String>[];
      if (_imageUrlController.text.trim().isNotEmpty) {
        images.add(_imageUrlController.text.trim());
      }

      final product = ProductModel(
        prodId: widget.product?.prodId ?? '',
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        categoryId: _selectedCategoryId ?? '',
        categoryName: category.name,
        brandId: _selectedBrandId ?? '',
        brandName: brand.name,
        technique: _selectedTechnique,
        skillLevel: _selectedSkillLevel,
        price: double.tryParse(_priceController.text) ?? 0.0,
        discountPrice: double.tryParse(_discountPriceController.text),
        stock: int.tryParse(_stockController.text) ?? 0,
        sku: _skuController.text.trim(),
        images: images,
        dimensions: _dimensionsController.text.trim(),
        weight: _weightController.text.trim(),
        materials: _materialsController.text.trim(),
        rating: widget.product?.rating ?? 0.0,
        reviewCount: widget.product?.reviewCount ?? 0,
        isFeatured: _isFeatured,
        isActive: _isActive,
        status: _isActive ? 'active' : 'inactive',
        createdAt: widget.product?.createdAt ?? DateTime.now(),
      );

      if (_isEditing) {
        await _adminService.updateProduct(product, adminId, previousStock: widget.product?.stock);
      } else {
        await _adminService.createProduct(product, adminId);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Producto actualizado' : 'Producto creado'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final categories = productProvider.categories;
    final brands = productProvider.brands;

    final techniques = ['óleo', 'acuarela', 'dibujo', 'acrílico', 'pastel', 'escultura', 'grabado', 'serigrafía'];
    final skillLevels = ['principiante', 'intermedio', 'profesional'];

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          _isEditing ? 'Editar Producto' : 'Nuevo Producto',
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection('Información Básica', [
                _buildTextField(_nameController, 'Nombre del Producto*', Icons.label_outline, required: true),
                const SizedBox(height: AppDimensions.paddingM),
                _buildTextField(_descController, 'Descripción*', Icons.description_outlined, maxLines: 3, required: true),
              ]),
              const SizedBox(height: AppDimensions.paddingL),

              _buildSection('Categoría y Marca', [
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategoryId,
                  decoration: _inputDecoration('Categoría*', Icons.category_outlined),
                  items: categories.map((c) => DropdownMenuItem(value: c.catId, child: Text(c.name))).toList(),
                  onChanged: (v) => setState(() => _selectedCategoryId = v),
                  validator: (v) => v == null ? 'Requerido' : null,
                ),
                const SizedBox(height: AppDimensions.paddingM),
                DropdownButtonFormField<String>(
                  initialValue: _selectedBrandId,
                  decoration: _inputDecoration('Marca*', Icons.business_outlined),
                  items: brands.map((b) => DropdownMenuItem(value: b.brandId, child: Text(b.name))).toList(),
                  onChanged: (v) => setState(() => _selectedBrandId = v),
                  validator: (v) => v == null ? 'Requerido' : null,
                ),
                const SizedBox(height: AppDimensions.paddingM),
                DropdownButtonFormField<String>(
                  initialValue: _selectedTechnique,
                  decoration: _inputDecoration('Técnica*', Icons.palette_outlined),
                  items: techniques.map((t) => DropdownMenuItem(value: t, child: Text(t[0].toUpperCase() + t.substring(1)))).toList(),
                  onChanged: (v) => setState(() => _selectedTechnique = v!),
                ),
                const SizedBox(height: AppDimensions.paddingM),
                DropdownButtonFormField<String>(
                  initialValue: _selectedSkillLevel,
                  decoration: _inputDecoration('Nivel*', Icons.school_outlined),
                  items: skillLevels.map((s) => DropdownMenuItem(value: s, child: Text(s[0].toUpperCase() + s.substring(1)))).toList(),
                  onChanged: (v) => setState(() => _selectedSkillLevel = v!),
                ),
              ]),
              const SizedBox(height: AppDimensions.paddingL),

              _buildSection('Precio e Inventario', [
                Row(
                  children: [
                    Expanded(child: _buildTextField(_priceController, 'Precio*', Icons.attach_money, keyboardType: TextInputType.number, required: true)),
                    const SizedBox(width: AppDimensions.paddingM),
                    Expanded(child: _buildTextField(_discountPriceController, 'Precio Descuento', Icons.discount_outlined, keyboardType: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: AppDimensions.paddingM),
                Row(
                  children: [
                    Expanded(child: _buildTextField(_stockController, 'Stock*', Icons.inventory_outlined, keyboardType: TextInputType.number, required: true)),
                    const SizedBox(width: AppDimensions.paddingM),
                    Expanded(child: _buildTextField(_skuController, 'SKU', Icons.qr_code_outlined)),
                  ],
                ),
              ]),
              const SizedBox(height: AppDimensions.paddingL),

              _buildSection('Detalles', [
                _buildTextField(_dimensionsController, 'Dimensiones', Icons.straighten),
                const SizedBox(height: AppDimensions.paddingM),
                _buildTextField(_weightController, 'Peso', Icons.fitness_center),
                const SizedBox(height: AppDimensions.paddingM),
                _buildTextField(_materialsController, 'Materiales', Icons.brush_outlined),
                const SizedBox(height: AppDimensions.paddingM),
                _buildTextField(_imageUrlController, 'URL de imagen principal', Icons.image_outlined),
              ]),
              const SizedBox(height: AppDimensions.paddingL),

              _buildSection('Estado', [
                SwitchListTile(
                  title: const Text('Destacado'),
                  subtitle: const Text('Aparece en la sección destacados'),
                  value: _isFeatured,
                  onChanged: (v) => setState(() => _isFeatured = v),
                  activeThumbColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                ),
                SwitchListTile(
                  title: const Text('Activo'),
                  subtitle: const Text('Visible para los clientes'),
                  value: _isActive,
                  onChanged: (v) => setState(() => _isActive = v),
                  activeThumbColor: AppColors.success,
                  contentPadding: EdgeInsets.zero,
                ),
              ]),
              const SizedBox(height: AppDimensions.paddingXL),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: AppColors.surface)
                      : Text(
                          _isEditing ? 'Guardar Cambios' : 'Crear Producto',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingL),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
        const SizedBox(height: AppDimensions.paddingM),
        ...children,
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
    TextInputType? keyboardType,
    bool required = false,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: _inputDecoration(label, icon),
      validator: required ? (v) => (v == null || v.trim().isEmpty) ? 'Campo requerido' : null : null,
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.primary),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusButton)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      filled: true,
      fillColor: AppColors.surface,
    );
  }
}
