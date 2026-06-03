import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/app_dimensions.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/confirm_logout_dialog.dart';
import '../../services/seed_service.dart';
import 'admin_products_screen.dart';
import 'admin_loyalty_screen.dart';
import 'admin_permissions_screen.dart';
import 'admin_orders_screen.dart';
import 'admin_coupons_screen.dart';
import 'admin_settings_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _isSeeding = false;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().userModel;

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Panel de Administración',
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      drawer: Drawer(
        backgroundColor: AppColors.surface,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: AppColors.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const CircleAvatar(
                    backgroundColor: AppColors.surface,
                    radius: 24,
                    child: Icon(Icons.admin_panel_settings, color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.username ?? 'Administrador',
                    style: AppTypography.titleLarge.copyWith(color: AppColors.surface),
                  ),
                  Text(
                    user?.email ?? '',
                    style: AppTypography.labelMedium.copyWith(color: AppColors.surface.withValues(alpha: 0.8)),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard, color: AppColors.primary),
              title: const Text('Dashboard'),
              selected: true,
              selectedTileColor: AppColors.primary.withValues(alpha: 0.1),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text('Productos y Catálogo'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminProductsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Pedidos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminOrdersScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Usuarios y Fidelidad'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminLoyaltyScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_offer),
              title: const Text('Cupones'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminCouponsScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.security),
              title: const Text('Permisos de Administrador'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminPermissionsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configuración'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminSettingsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text('Cerrar Sesión', style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (_) => ConfirmLogoutDialog(
                    onConfirm: () async {
                      await context.read<AuthProvider>().signOut();
                      if (context.mounted) context.go('/landing');
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Resumen Hoy', style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppDimensions.paddingM),
            Row(
              children: [
                Expanded(child: _buildStatCard('Ventas', '\$12,450', Icons.attach_money, AppColors.success)),
                const SizedBox(width: AppDimensions.paddingM),
                Expanded(child: _buildStatCard('Pedidos', '24', Icons.shopping_bag, AppColors.primary)),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingM),
            Row(
              children: [
                Expanded(child: _buildStatCard('Nuevos Usuarios', '8', Icons.person_add, AppColors.loyaltyGold)),
                const SizedBox(width: AppDimensions.paddingM),
                Expanded(child: _buildStatCard('Agotados', '3', Icons.warning, AppColors.error)),
              ],
            ),
            
            const SizedBox(height: AppDimensions.paddingXL),
            Text('Acciones Rápidas', style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppDimensions.paddingM),
            Wrap(
              spacing: AppDimensions.paddingM,
              runSpacing: AppDimensions.paddingM,
              children: [
                _buildActionButton('Añadir Producto', Icons.add_box, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminProductsScreen()),
                  );
                }),
                _buildActionButton('Crear Cupón', Icons.local_activity, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminCouponsScreen()),
                  );
                }),
                _buildActionButton('Escanear Pedido', Icons.qr_code_scanner, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminOrdersScreen()),
                  );
                }),
                if (!_isSeeding)
                  _buildActionButton('Poblar BD', Icons.storage, _seedDatabase)
                else
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: const [
                        SizedBox(
                          width: 24, height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                        ),
                        SizedBox(height: 8),
                        Text('Sembrando...', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _seedDatabase() async {
    setState(() => _isSeeding = true);
    try {
      await SeedService().seedAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Base de datos poblada exitosamente.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al poblar BD: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSeeding = false);
    }
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        boxShadow: AppDimensions.shadowStandard,
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value, style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
