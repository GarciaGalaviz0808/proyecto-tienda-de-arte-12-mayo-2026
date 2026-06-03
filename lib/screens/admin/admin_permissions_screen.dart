import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/app_dimensions.dart';

class AdminPermissionsScreen extends StatelessWidget {
  const AdminPermissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Permisos de Administrador',
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
              border: Border.all(color: AppColors.primaryLight),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.primary),
                const SizedBox(width: AppDimensions.paddingM),
                Expanded(
                  child: Text(
                    'Solo los usuarios con rol de Super Admin pueden modificar los permisos de otros administradores.',
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.primaryDark),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.paddingXL),
          
          Text('Administradores Activos', style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppDimensions.paddingM),
          
          _buildAdminTile('admin@elisart.com', 'Super Admin', true),
          const SizedBox(height: AppDimensions.paddingS),
          _buildAdminTile('soporte@elisart.com', 'Soporte', false),
          const SizedBox(height: AppDimensions.paddingS),
          _buildAdminTile('inventario@elisart.com', 'Inventario', false),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Show invite admin dialog
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add),
        label: const Text('Invitar Admin'),
      ),
    );
  }

  Widget _buildAdminTile(String email, String role, bool isSuper) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: isSuper ? AppColors.loyaltyGold : AppColors.borderSubtle),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isSuper ? AppColors.loyaltyGold.withValues(alpha: 0.2) : AppColors.backgroundSecondary,
          child: Icon(Icons.shield, color: isSuper ? AppColors.loyaltyGold : AppColors.textSecondary),
        ),
        title: Text(email, style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Text(role),
        trailing: const Icon(Icons.settings, color: AppColors.primary),
        onTap: () {
          // TODO: Open permission edit bottom sheet
        },
      ),
    );
  }
}
