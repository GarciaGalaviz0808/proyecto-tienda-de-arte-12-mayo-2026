import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/app_dimensions.dart';
import '../../models/order_model.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String _selectedStatus = 'all';
  bool _isLoading = true;
  List<OrderModel> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      Query query = _db.collection('orders').orderBy('createdAt', descending: true);
      if (_selectedStatus != 'all') {
        query = _db.collection('orders')
            .where('status', isEqualTo: _selectedStatus)
            .orderBy('createdAt', descending: true);
      }
      final snapshot = await query.get();
      _orders = snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
    } catch (_) {
      try {
        final snapshot = await _db.collection('orders').get();
        _orders = snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
        _orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        if (_selectedStatus != 'all') {
          _orders = _orders.where((o) => o.status == _selectedStatus).toList();
        }
      } catch (_) {}
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _db.collection('orders').doc(orderId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Estado actualizado a: $newStatus'), backgroundColor: AppColors.success),
        );
        _loadOrders();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending': return AppColors.loyaltyGold;
      case 'processing': return AppColors.primary;
      case 'shipped': return AppColors.success;
      case 'delivered': return AppColors.success;
      case 'cancelled': return AppColors.error;
      default: return AppColors.textSecondary;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending': return 'Pendiente';
      case 'processing': return 'En proceso';
      case 'shipped': return 'Enviado';
      case 'delivered': return 'Entregado';
      case 'cancelled': return 'Cancelado';
      default: return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final statuses = ['all', 'pending', 'processing', 'shipped', 'delivered', 'cancelled'];
    final statusLabels = {'all': 'Todos', 'pending': 'Pendientes', 'processing': 'En proceso', 'shipped': 'Enviados', 'delivered': 'Entregados', 'cancelled': 'Cancelados'};

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Pedidos (${_orders.length})',
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadOrders),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 50,
            color: AppColors.surface,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM, vertical: 8),
              itemCount: statuses.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final s = statuses[index];
                final selected = _selectedStatus == s;
                return FilterChip(
                  label: Text(statusLabels[s]!, style: TextStyle(color: selected ? AppColors.surface : AppColors.textPrimary)),
                  selected: selected,
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  checkmarkColor: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: selected ? AppColors.primary : AppColors.borderSubtle),
                  ),
                  onSelected: (_) {
                    setState(() => _selectedStatus = s);
                    _loadOrders();
                  },
                );
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _orders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.borderSubtle),
                            const SizedBox(height: 16),
                            Text('No hay pedidos', style: AppTypography.titleMedium),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadOrders,
                        color: AppColors.primary,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(AppDimensions.paddingM),
                          itemCount: _orders.length,
                          separatorBuilder: (_, __) => const SizedBox(height: AppDimensions.paddingM),
                          itemBuilder: (context, index) {
                            final order = _orders[index];
                            return Container(
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                                boxShadow: AppDimensions.shadowStandard,
                              ),
                              child: ExpansionTile(
                                tilePadding: const EdgeInsets.all(AppDimensions.paddingM),
                                childrenPadding: const EdgeInsets.all(AppDimensions.paddingM),
                                leading: CircleAvatar(
                                  backgroundColor: _statusColor(order.status).withValues(alpha: 0.1),
                                  child: Icon(Icons.receipt_long, color: _statusColor(order.status), size: 20),
                                ),
                                title: Text(
                                  '#${order.orderId.substring(0, 8).toUpperCase()}',
                                  style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(dateFormat.format(order.createdAt), style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary)),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${order.items.length} artículo(s) - ${currencyFormat.format(order.total)}',
                                      style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
                                    ),
                                  ],
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _statusColor(order.status).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _statusLabel(order.status),
                                    style: AppTypography.labelSmall.copyWith(
                                      color: _statusColor(order.status),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                children: [
                                  const Divider(),
                                  ...order.items.map((item) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      children: [
                                        if (item.imageUrl.isNotEmpty)
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(4),
                                            child: Image.network(item.imageUrl, width: 40, height: 40, fit: BoxFit.cover),
                                          )
                                        else
                                          Container(width: 40, height: 40, color: AppColors.backgroundSecondary, child: const Icon(Icons.image, size: 20)),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(item.name, style: AppTypography.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                                              Text('${item.quantity}x ${currencyFormat.format(item.priceUnit)}', style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                                  const SizedBox(height: 12),
                                  if (order.shippingAddress.isNotEmpty)
                                    Text(
                                      'Envío: ${order.shippingAddress['street'] ?? ''}, ${order.shippingAddress['city'] ?? ''}',
                                      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                                    ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if (order.status == 'pending') ...[
                                        _statusButton('Cancelar', AppColors.error, () => _updateOrderStatus(order.orderId, 'cancelled')),
                                        const SizedBox(width: 8),
                                        _statusButton('Procesar', AppColors.primary, () => _updateOrderStatus(order.orderId, 'processing')),
                                      ],
                                      if (order.status == 'processing')
                                        _statusButton('Enviar', AppColors.success, () => _updateOrderStatus(order.orderId, 'shipped')),
                                      if (order.status == 'shipped')
                                        _statusButton('Entregado', AppColors.success, () => _updateOrderStatus(order.orderId, 'delivered')),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _statusButton(String label, Color color, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(label, style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.bold)),
    );
  }
}
