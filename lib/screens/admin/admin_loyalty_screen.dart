import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/app_dimensions.dart';

class AdminLoyaltyScreen extends StatelessWidget {
  const AdminLoyaltyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Configurar Fidelidad',
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Reglas Globales de Puntos', style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppDimensions.paddingM),
                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'Monto divisor (ej. \$100)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'Puntos por monto (ej. 5)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reglas actualizadas')));
                      },
                      child: const Text('Guardar Reglas'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.paddingXL),
            Text('Niveles de Fidelidad', style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppDimensions.paddingM),
            _buildLevelTile('Bronce', '0 puntos mínimos', AppColors.loyaltyBronze),
            const SizedBox(height: AppDimensions.paddingS),
            _buildLevelTile('Plata', '1000 puntos mínimos', AppColors.loyaltySilver),
            const SizedBox(height: AppDimensions.paddingS),
            _buildLevelTile('Oro', '5000 puntos mínimos', AppColors.loyaltyGold),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelTile(String name, String subtitle, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: ListTile(
        leading: Icon(Icons.star, color: color),
        title: Text(name, style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.edit_outlined, color: AppColors.primary),
        onTap: () {},
      ),
    );
  }
}
