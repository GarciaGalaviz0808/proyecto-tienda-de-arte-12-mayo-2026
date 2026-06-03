import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_typography.dart';
import '../core/constants/app_dimensions.dart';
import '../providers/order_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/order_status_badge.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        context.read<OrderProvider>().fetchUserOrders(user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Mis Pedidos',
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.orders.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (provider.orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.receipt_long, size: 64, color: AppColors.borderSubtle),
                  const SizedBox(height: 16),
                  Text('Aún no has realizado pedidos.', style: AppTypography.titleMedium),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              final user = context.read<AuthProvider>().user;
              if (user != null) {
                await provider.fetchUserOrders(user.uid);
              }
            },
            color: AppColors.primary,
            child: ListView.separated(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              itemCount: provider.orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppDimensions.paddingM),
              itemBuilder: (context, index) {
                final order = provider.orders[index];
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                    boxShadow: AppDimensions.shadowStandard,
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                    onTap: () {
                      // TODO: Navigate to Order Detail
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.paddingM),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Pedido #${order.orderId.substring(0, 8).toUpperCase()}',
                                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                              ),
                              OrderStatusBadge(status: order.status),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            dateFormat.format(order.createdAt),
                            style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary),
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${order.items.length} artículo(s)',
                                style: AppTypography.bodyMedium,
                              ),
                              Text(
                                currencyFormat.format(order.total),
                                style: AppTypography.titleMedium.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
