import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_typography.dart';
import '../core/constants/app_dimensions.dart';
import '../providers/loyalty_provider.dart';
import '../providers/auth_provider.dart';

class LoyaltyScreen extends StatefulWidget {
  const LoyaltyScreen({super.key});

  @override
  State<LoyaltyScreen> createState() => _LoyaltyScreenState();
}

class _LoyaltyScreenState extends State<LoyaltyScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        context.read<LoyaltyProvider>().loadTransactions();
      }
    });
  }

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'bronce':
        return AppColors.loyaltyBronze;
      case 'plata':
        return AppColors.loyaltySilver;
      case 'oro':
        return AppColors.loyaltyGold;
      default:
        return AppColors.loyaltyBronze;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Eli\'s Art Club',
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer2<AuthProvider, LoyaltyProvider>(
        builder: (context, authProvider, loyaltyProvider, child) {
          final user = authProvider.userModel;
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final levelColor = _getLevelColor(user.loyaltyLevel);

          return CustomScrollView(
            slivers: [
              // Hero Section
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(AppDimensions.paddingM),
                  padding: const EdgeInsets.all(AppDimensions.paddingXL),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [levelColor.withOpacity(0.8), levelColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                    boxShadow: AppDimensions.shadowStandard,
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.star, size: 64, color: AppColors.surface),
                      const SizedBox(height: 16),
                      Text(
                        'Nivel ${user.loyaltyLevel.toUpperCase()}',
                        style: AppTypography.headlineMedium.copyWith(
                          color: AppColors.surface,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${user.loyaltyPoints} puntos disponibles',
                        style: AppTypography.titleMedium.copyWith(color: AppColors.surface),
                      ),
                    ],
                  ),
                ),
              ),

              // Redeem Rewards Section (Placeholder)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  child: Text('Canjear Recompensas', style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold)),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 150,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
                    children: [
                      _buildRewardCard('Descuento \$50', 500),
                      _buildRewardCard('Envío Gratis', 1000),
                      _buildRewardCard('Descuento \$150', 1200),
                    ],
                  ),
                ),
              ),

              // Transaction History
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  child: Text('Historial de Puntos', style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold)),
                ),
              ),
              
              if (loyaltyProvider.isLoading && loyaltyProvider.transactions.isEmpty)
                const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()))
              else if (loyaltyProvider.transactions.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingL),
                    child: Center(
                      child: Text('Aún no tienes movimientos', style: AppTypography.bodyMedium),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final tx = loyaltyProvider.transactions[index];
                      final isEarned = tx.type == 'earned';
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isEarned ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
                          child: Icon(
                            isEarned ? Icons.add : Icons.remove,
                            color: isEarned ? AppColors.success : AppColors.error,
                          ),
                        ),
                        title: Text(tx.description, style: AppTypography.bodyMedium),
                        trailing: Text(
                          '${isEarned ? '+' : '-'}${tx.points}',
                          style: AppTypography.titleMedium.copyWith(
                            color: isEarned ? AppColors.success : AppColors.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                    childCount: loyaltyProvider.transactions.length,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRewardCard(String title, int pointsCost) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: AppDimensions.paddingM),
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.card_giftcard, size: 32, color: AppColors.primary),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '$pointsCost pts',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              child: const Text('Canjear', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}
