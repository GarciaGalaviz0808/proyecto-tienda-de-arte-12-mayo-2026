import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_typography.dart';
import '../core/constants/app_dimensions.dart';
import '../providers/auth_provider.dart';
import '../widgets/loyalty_badge.dart';
import '../widgets/confirm_logout_dialog.dart';
import 'loyalty_screen.dart';
import 'coupons_screen.dart';
import 'edit_profile_screen.dart';
import 'addresses_screen.dart';
import 'help_support_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Mi Perfil',
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.textPrimary),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.userModel;

          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            child: Column(
              children: [
                // Header Profile Card
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                    boxShadow: AppDimensions.shadowStandard,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: AppColors.primaryLight,
                        child: Text(
                          user.username.isNotEmpty ? user.username[0].toUpperCase() : 'U',
                          style: AppTypography.headlineMedium.copyWith(color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.paddingM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.username,
                              style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.email,
                              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 8),
                            LoyaltyBadge(level: user.loyaltyLevel, points: user.loyaltyPoints),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: AppDimensions.paddingL),

                // Menu Options
                _buildMenuSection(
                  title: 'Mi Cuenta',
                  items: [
                    _MenuOption(
                      icon: Icons.person_outline,
                      title: 'Editar Perfil',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                        );
                      },
                    ),
                    _MenuOption(
                      icon: Icons.location_on_outlined,
                      title: 'Direcciones de Envío',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AddressesScreen()),
                        );
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: AppDimensions.paddingM),

                _buildMenuSection(
                  title: 'Eli\'s Art Club',
                  items: [
                    _MenuOption(
                      icon: Icons.card_giftcard,
                      title: 'Mis Puntos y Recompensas',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoyaltyScreen()),
                        );
                      },
                    ),
                    _MenuOption(
                      icon: Icons.local_activity_outlined,
                      title: 'Mis Cupones',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CouponsScreen()),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: AppDimensions.paddingM),

                _buildMenuSection(
                  title: 'Ajustes',
                  items: [
                    _MenuOption(
                      icon: Icons.help_outline,
                      title: 'Ayuda y Soporte',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const HelpSupportScreen()),
                        );
                      },
                    ),
                    _MenuOption(
                      icon: Icons.logout,
                      title: 'Cerrar Sesión',
                      isDestructive: true,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => ConfirmLogoutDialog(
                            onConfirm: () async {
                              await authProvider.signOut();
                              if (context.mounted) {
                                context.go('/landing');
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuSection({required String title, required List<_MenuOption> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            title,
            style: AppTypography.labelLarge.copyWith(color: AppColors.textSecondary),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
            boxShadow: AppDimensions.shadowStandard,
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  ListTile(
                    leading: Icon(
                      item.icon,
                      color: item.isDestructive ? AppColors.error : AppColors.primary,
                    ),
                    title: Text(
                      item.title,
                      style: AppTypography.bodyLarge.copyWith(
                        color: item.isDestructive ? AppColors.error : AppColors.textPrimary,
                        fontWeight: item.isDestructive ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.borderSubtle),
                    onTap: item.onTap,
                  ),
                  if (index < items.length - 1)
                    const Divider(height: 1, indent: 56),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _MenuOption {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  _MenuOption({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });
}
