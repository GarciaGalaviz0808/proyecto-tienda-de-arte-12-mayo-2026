import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_typography.dart';
import '../core/constants/app_dimensions.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../models/order_model.dart';
import 'order_confirmation_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipController = TextEditingController();
  
  String _selectedPaymentMethod = 'tarjeta';
  bool _isProcessing = false;

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  void _processPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    try {
      final cartProvider = context.read<CartProvider>();
      final orderProvider = context.read<OrderProvider>();

      final cart = cartProvider.cart;
      if (cart == null || cart.items.isEmpty) {
        throw Exception('El carrito está vacío');
      }

      final shippingAddress = {
        'street': _addressController.text,
        'city': _cityController.text,
        'zip': _zipController.text,
        'country': 'México', // Default for now
      };

      // Simulate a small delay for payment gateway
      await Future.delayed(const Duration(seconds: 2));

      final order = await orderProvider.placeOrder(
        items: cart.items.map((i) => OrderItemModel(
          prodId: i.prodId,
          name: i.nameSnapshot,
          priceUnit: i.priceSnapshot,
          brand: i.brandSnapshot,
          imageUrl: i.imageUrl,
          quantity: i.quantity,
        )).toList(),
        subtotal: cartProvider.subtotal,
        shippingCost: cartProvider.shippingCost,
        paymentMethod: _selectedPaymentMethod,
        shippingAddress: shippingAddress,
        couponCode: cart.appliedCoupon,
        discountAmount: cart.discountAmount,
      );

      // Force refresh of cart
      await cartProvider.loadCart();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => OrderConfirmationScreen(order: order)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al procesar el pago: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>().cart;
    if (cart == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final subtotal = cart.total;
    const shipping = 99.00;
    final total = subtotal + shipping - cart.discountAmount;

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Pago y Envío',
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isProcessing
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text('Procesando pago de forma segura...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dirección de Envío', style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: AppDimensions.paddingM),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Calle y Número',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                    ),
                    const SizedBox(height: AppDimensions.paddingM),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _cityController,
                            decoration: const InputDecoration(
                              labelText: 'Ciudad',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) => value!.isEmpty ? 'Requerido' : null,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.paddingM),
                        Expanded(
                          child: TextFormField(
                            controller: _zipController,
                            decoration: const InputDecoration(
                              labelText: 'C.P.',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) => value!.isEmpty ? 'Requerido' : null,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppDimensions.paddingXL),
                    
                    Text('Método de Pago', style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: AppDimensions.paddingM),
                    _buildPaymentOption('tarjeta', 'Tarjeta de Crédito / Débito', Icons.credit_card),
                    _buildPaymentOption('paypal', 'PayPal', Icons.paypal),
                    _buildPaymentOption('oxxo', 'Pago en OXXO', Icons.store),
                    
                    const SizedBox(height: AppDimensions.paddingXL),
                    
                    // Resumen
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.paddingL),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                        boxShadow: AppDimensions.shadowStandard,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Resumen de Compra', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: AppDimensions.paddingM),
                          _buildSummaryRow('Subtotal', subtotal),
                          if (cart.discountAmount > 0)
                            _buildSummaryRow('Descuento', -cart.discountAmount, isDiscount: true),
                          _buildSummaryRow('Envío', shipping),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total', style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold)),
                              Text(
                                '\$${total.toStringAsFixed(2)}',
                                style: AppTypography.titleLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingXL),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: _isProcessing ? null : SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _processPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                ),
              ),
              child: Text('Confirmar y Pagar \$${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodyMedium),
          Text(
            isDiscount ? '-\$${amount.abs().toStringAsFixed(2)}' : '\$${amount.toStringAsFixed(2)}',
            style: AppTypography.bodyMedium.copyWith(
              color: isDiscount ? AppColors.success : AppColors.textPrimary,
              fontWeight: isDiscount ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String value, String title, IconData icon) {
    return RadioListTile<String>(
      value: value,
      groupValue: _selectedPaymentMethod,
      onChanged: (val) {
        setState(() => _selectedPaymentMethod = val!);
      },
      title: Text(title, style: AppTypography.bodyLarge),
      secondary: Icon(icon, color: AppColors.primary),
      activeColor: AppColors.primary,
      contentPadding: EdgeInsets.zero,
    );
  }
}
