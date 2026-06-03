import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/app_dimensions.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  bool _isLoading = true;

  String _storeName = "Eli's Art Supplies";
  String _storeEmail = "contacto@elisart.com";
  String _storePhone = "+52 (55) 1234-5678";
  double _freeShippingThreshold = 500.0;
  double _standardShippingCost = 99.0;
  bool _maintenanceMode = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final doc = await _db.collection('settings').doc('store').get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _storeName = data['storeName'] ?? _storeName;
          _storeEmail = data['storeEmail'] ?? _storeEmail;
          _storePhone = data['storePhone'] ?? _storePhone;
          _freeShippingThreshold = (data['freeShippingThreshold'] as num?)?.toDouble() ?? _freeShippingThreshold;
          _standardShippingCost = (data['standardShippingCost'] as num?)?.toDouble() ?? _standardShippingCost;
          _maintenanceMode = data['maintenanceMode'] ?? false;
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _saveSettings() async {
    try {
      await _db.collection('settings').doc('store').set({
        'storeName': _storeName,
        'storeEmail': _storeEmail,
        'storePhone': _storePhone,
        'freeShippingThreshold': _freeShippingThreshold,
        'standardShippingCost': _standardShippingCost,
        'maintenanceMode': _maintenanceMode,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Configuración guardada'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          title: Text('Configuración', style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold)),
        ),
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Configuración',
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: Text('Guardar', style: AppTypography.labelLarge.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('Tienda', [
              _buildTextField(_storeName, 'Nombre de la Tienda', Icons.store_outlined, onChanged: (v) => _storeName = v),
              const SizedBox(height: AppDimensions.paddingM),
              _buildTextField(_storeEmail, 'Email de Contacto', Icons.email_outlined, onChanged: (v) => _storeEmail = v, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: AppDimensions.paddingM),
              _buildTextField(_storePhone, 'Teléfono', Icons.phone_outlined, onChanged: (v) => _storePhone = v, keyboardType: TextInputType.phone),
            ]),
            const SizedBox(height: AppDimensions.paddingL),

            _buildSection('Envíos', [
              _buildTextField(
                _freeShippingThreshold.toString(),
                'Envío gratis desde (\$)',
                Icons.local_shipping_outlined,
                onChanged: (v) => _freeShippingThreshold = double.tryParse(v) ?? 500.0,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppDimensions.paddingM),
              _buildTextField(
                _standardShippingCost.toString(),
                'Costo de envío estándar (\$)',
                Icons.attach_money,
                onChanged: (v) => _standardShippingCost = double.tryParse(v) ?? 99.0,
                keyboardType: TextInputType.number,
              ),
            ]),
            const SizedBox(height: AppDimensions.paddingL),

            _buildSection('Sistema', [
              SwitchListTile(
                title: const Text('Modo Mantenimiento'),
                subtitle: const Text('Desactiva el acceso a clientes'),
                value: _maintenanceMode,
                onChanged: (v) => setState(() => _maintenanceMode = v),
                activeThumbColor: AppColors.error,
                contentPadding: EdgeInsets.zero,
              ),
            ]),
            const SizedBox(height: AppDimensions.paddingXL),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                  ),
                ),
                child: const Text('Guardar Configuración', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
        const SizedBox(height: AppDimensions.paddingM),
        ...children,
      ],
    );
  }

  Widget _buildTextField(
    String value,
    String label,
    IconData icon, {
    required ValueChanged<String> onChanged,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusButton)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: AppColors.surface,
      ),
      keyboardType: keyboardType,
      onChanged: onChanged,
    );
  }
}
