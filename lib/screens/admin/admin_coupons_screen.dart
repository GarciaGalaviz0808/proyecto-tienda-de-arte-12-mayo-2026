import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/app_dimensions.dart';

class AdminCouponsScreen extends StatefulWidget {
  const AdminCouponsScreen({super.key});

  @override
  State<AdminCouponsScreen> createState() => _AdminCouponsScreenState();
}

class _AdminCouponsScreenState extends State<AdminCouponsScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  bool _isLoading = true;
  List<Map<String, dynamic>> _coupons = [];

  @override
  void initState() {
    super.initState();
    _loadCoupons();
  }

  Future<void> _loadCoupons() async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await _db.collection('coupons').get();
      _coupons = snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  void _showCouponForm({Map<String, dynamic>? coupon}) {
    final codeController = TextEditingController(text: coupon?['id'] ?? '');
    final valueController = TextEditingController(text: coupon?['value']?.toString() ?? '');
    final minPurchaseController = TextEditingController(text: coupon?['minPurchase']?.toString() ?? '0');
    final maxUsesController = TextEditingController(text: coupon?['maxUses']?.toString() ?? '100');
    String type = coupon?['type'] ?? 'percentage';
    bool isActive = coupon?['isActive'] ?? true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusCard)),
          title: Text(coupon != null ? 'Editar Cupón' : 'Nuevo Cupón'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: codeController,
                  decoration: InputDecoration(
                    labelText: 'Código*',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.confirmation_number_outlined),
                  ),
                  enabled: coupon == null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: type,
                  decoration: const InputDecoration(labelText: 'Tipo', border: OutlineInputBorder(), prefixIcon: Icon(Icons.category)),
                  items: const [
                    DropdownMenuItem(value: 'percentage', child: Text('Porcentaje (%)')),
                    DropdownMenuItem(value: 'fixed', child: Text('Monto fijo (\$)')),
                  ],
                  onChanged: (v) => setDialogState(() => type = v!),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: valueController,
                  decoration: const InputDecoration(labelText: 'Valor*', border: OutlineInputBorder(), prefixIcon: Icon(Icons.attach_money)),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: minPurchaseController,
                  decoration: const InputDecoration(labelText: 'Compra mínima', border: OutlineInputBorder(), prefixIcon: Icon(Icons.shopping_cart_outlined)),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: maxUsesController,
                  decoration: const InputDecoration(labelText: 'Usos máximos', border: OutlineInputBorder(), prefixIcon: Icon(Icons.people_outlined)),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Activo'),
                  value: isActive,
                  onChanged: (v) => setDialogState(() => isActive = v),
                  activeThumbColor: AppColors.success,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                final code = codeController.text.trim().toUpperCase();
                final value = double.tryParse(valueController.text) ?? 0;
                final minPurchase = double.tryParse(minPurchaseController.text) ?? 0;
                final maxUses = int.tryParse(maxUsesController.text) ?? 100;

                if (code.isEmpty || value <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Código y valor son requeridos')),
                  );
                  return;
                }

                try {
                  await _db.collection('coupons').doc(code).set({
                    'type': type,
                    'value': value,
                    'minPurchase': minPurchase,
                    'maxUses': maxUses,
                    'usedCount': coupon?['usedCount'] ?? 0,
                    'expiresAt': Timestamp.fromDate(DateTime(2026, 12, 31)),
                    'applicableCategories': null,
                    'applicableBrands': null,
                    'isActive': isActive,
                    'createdAt': coupon?['createdAt'] ?? FieldValue.serverTimestamp(),
                  });
                  if (!ctx.mounted) return;
                  Navigator.pop(ctx);
                  _loadCoupons();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(coupon != null ? 'Cupón actualizado' : 'Cupón creado'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.surface),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleCoupon(String code, bool currentStatus) async {
    try {
      await _db.collection('coupons').doc(code).update({'isActive': !currentStatus});
      _loadCoupons();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _deleteCoupon(String code) async {
    try {
      await _db.collection('coupons').doc(code).delete();
      _loadCoupons();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cupón eliminado'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Cupones (${_coupons.length})',
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadCoupons),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCouponForm(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Cupón'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _coupons.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.local_offer_outlined, size: 64, color: AppColors.borderSubtle),
                      const SizedBox(height: 16),
                      Text('No hay cupones', style: AppTypography.titleMedium),
                      const SizedBox(height: 8),
                      Text('Crea tu primer cupón de descuento.', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadCoupons,
                  color: AppColors.primary,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(AppDimensions.paddingM),
                    itemCount: _coupons.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppDimensions.paddingM),
                    itemBuilder: (context, index) {
                      final coupon = _coupons[index];
                      final code = coupon['id'] as String? ?? '';
                      final type = coupon['type'] ?? 'percentage';
                      final value = (coupon['value'] as num?)?.toDouble() ?? 0;
                      final minPurchase = (coupon['minPurchase'] as num?)?.toDouble() ?? 0;
                      final maxUses = coupon['maxUses'] ?? 0;
                      final usedCount = coupon['usedCount'] ?? 0;
                      final isActive = coupon['isActive'] ?? true;
                      final expiresAt = (coupon['expiresAt'] as Timestamp?)?.toDate();

                      return Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                          boxShadow: AppDimensions.shadowStandard,
                          border: Border.all(
                            color: isActive ? AppColors.borderSubtle : AppColors.error.withValues(alpha: 0.3),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(AppDimensions.paddingM),
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                            ),
                            child: Center(
                              child: Text(
                                type == 'percentage' ? '${value.toStringAsFixed(0)}%' : '\$${value.toStringAsFixed(0)}',
                                style: AppTypography.titleMedium.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            code,
                            style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${type == 'percentage' ? 'Descuento porcentaje' : 'Monto fijo'} - Mín: \$${minPurchase.toStringAsFixed(0)}',
                                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                              ),
                              Text(
                                'Usos: $usedCount/$maxUses${expiresAt != null ? ' - Exp: ${dateFormat.format(expiresAt)}' : ''}',
                                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showCouponForm(coupon: coupon);
                              } else if (value == 'toggle') {
                                _toggleCoupon(code, isActive);
                              } else if (value == 'delete') {
                                _deleteCoupon(code);
                              }
                            },
                            itemBuilder: (ctx) => [
                              const PopupMenuItem(value: 'edit', child: Text('Editar')),
                              PopupMenuItem(
                                value: 'toggle',
                                child: Text(isActive ? 'Desactivar' : 'Activar'),
                              ),
                              const PopupMenuItem(value: 'delete', child: Text('Eliminar', style: TextStyle(color: AppColors.error))),
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
