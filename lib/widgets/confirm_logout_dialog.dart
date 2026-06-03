import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_typography.dart';
import '../core/constants/app_dimensions.dart';

class ConfirmLogoutDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const ConfirmLogoutDialog({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
      ),
      backgroundColor: AppColors.surface,
      title: Row(
        children: [
          const Icon(Icons.logout, color: AppColors.primary),
          const SizedBox(width: 8),
          Text('Cerrar Sesión', style: AppTypography.titleLarge),
        ],
      ),
      content: Text(
        '¿Estás seguro que deseas cerrar sesión?',
        style: AppTypography.bodyMedium,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancelar',
            style: AppTypography.labelLarge.copyWith(color: AppColors.textSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
            ),
          ),
          child: const Text('Sí, Salir'),
        ),
      ],
    );
  }
}
