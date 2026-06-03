import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_typography.dart';
import '../core/constants/app_dimensions.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Ayuda y Soporte',
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Preguntas Frecuentes', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppDimensions.paddingM),
            _buildFAQItem(
              '¿Cómo realizo un pedido?',
              'Agrega productos al carrito, procede al pago y completa los datos de envío.',
            ),
            _buildFAQItem(
              '¿Cuál es el tiempo de entrega?',
              'El tiempo de entrega estándar es de 3 a 5 días hábiles.',
            ),
            _buildFAQItem(
              '¿Puedo devolver un producto?',
              'Sí, tienes hasta 30 días para devoluciones. Contacta soporte para más detalles.',
            ),
            const SizedBox(height: AppDimensions.paddingXL),
            Text('Contacto', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppDimensions.paddingM),
            _buildContactOption(Icons.email_outlined, 'Email', 'soporte@elisart.com'),
            _buildContactOption(Icons.phone_outlined, 'Teléfono', '+52 (55) 1234-5678'),
            _buildContactOption(Icons.chat_outlined, 'WhatsApp', '+52 (55) 9876-5432'),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusCard)),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(question, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(answer, style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildContactOption(IconData icon, String title, String detail) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingS),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusCard)),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: AppTypography.bodyLarge),
        subtitle: Text(detail, style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.borderSubtle),
        onTap: () {
          // TODO: Launch contact action
        },
      ),
    );
  }
}
