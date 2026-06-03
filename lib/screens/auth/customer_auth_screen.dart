import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';

class CustomerAuthScreen extends StatefulWidget {
  const CustomerAuthScreen({super.key});

  @override
  State<CustomerAuthScreen> createState() => _CustomerAuthScreenState();
}

class _CustomerAuthScreenState extends State<CustomerAuthScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();
  String? _selectedTechnique;

  final List<String> _techniques = ['Óleo', 'Acuarela', 'Dibujo', 'Acrílico', 'Escultura', 'Grabado'];

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMsg;

  late AnimationController _formAnimController;
  late Animation<double> _formFade;

  @override
  void initState() {
    super.initState();
    _formAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _formFade = CurvedAnimation(parent: _formAnimController, curve: Curves.easeOut);
    _formAnimController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    _formAnimController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    _formAnimController.reverse().then((_) {
      setState(() {
        _isLogin = !_isLogin;
        _errorMsg = null;
        _formKey.currentState?.reset();
      });
      _formAnimController.forward();
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _errorMsg = null);

    final authProvider = context.read<AuthProvider>();

    try {
      if (_isLogin) {
        await authProvider.login(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
        if (mounted) context.go('/home');
      } else {
        await authProvider.register(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          username: _usernameController.text.trim(),
          favoriteTechnique: _selectedTechnique,
        );
        if (mounted) context.go('/home');
      }
    } catch (e) {
      setState(() {
        _errorMsg = e.toString()
            .replaceAll('Exception: ', '')
            .replaceAll('[firebase_auth/', '')
            .replaceAll(']', '');
      });
    }
  }

  InputDecoration _buildInputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      ),
      prefixIcon: Container(
        margin: const EdgeInsets.only(left: 12, right: 8),
        child: Icon(icon, size: 20, color: AppColors.primaryAccent),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 48),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.borderSubtle.withValues(alpha: 0.5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.borderSubtle.withValues(alpha: 0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primaryAccent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          const SizedBox.expand(),

          // Top dark header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight * 0.28,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF2C241B),
                    Color(0xFF3D3228),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -40,
                    right: -30,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.primaryAccent.withValues(alpha: 0.15),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          // Back button
                          InkWell(
                            onTap: () => context.pop(),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _isLogin ? "¡Bienvenido\nde vuelta!" : "Crea tu\ncuenta",
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isLogin
                                ? "Ingresa para acceder a tus suministros favoritos"
                                : "Únete y comienza a acumular puntos de arte",
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Form card
          Positioned(
            top: screenHeight * 0.24,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFDFBF7),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: FadeTransition(
                opacity: _formFade,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Error message
                        if (_errorMsg != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.error.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline_rounded, size: 20, color: AppColors.error),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _errorMsg!,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: AppColors.error,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Username field (register only)
                        if (!_isLogin) ...[
                          TextFormField(
                            controller: _usernameController,
                            decoration: _buildInputDecoration(
                              label: 'Nombre de usuario',
                              icon: Icons.person_outline_rounded,
                            ),
                            style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
                            validator: (val) =>
                                val == null || val.trim().isEmpty ? 'Ingresa un nombre de usuario' : null,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Email
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _buildInputDecoration(
                            label: 'Correo electrónico',
                            icon: Icons.mail_outline_rounded,
                          ),
                          style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'Ingresa tu correo';
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val.trim())) {
                              return 'Ingresa un correo válido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: _buildInputDecoration(
                            label: 'Contraseña',
                            icon: Icons.lock_outline_rounded,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 20,
                                color: AppColors.textSecondary,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Ingresa tu contraseña';
                            if (val.length < 6) return 'Mínimo 6 caracteres';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Confirm password (register only)
                        if (!_isLogin) ...[
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            decoration: _buildInputDecoration(
                              label: 'Confirmar contraseña',
                              icon: Icons.lock_reset_rounded,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 20,
                                  color: AppColors.textSecondary,
                                ),
                                onPressed: () =>
                                    setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                              ),
                            ),
                            style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
                            validator: (val) {
                              if (val != _passwordController.text) return 'Las contraseñas no coinciden';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Technique dropdown
                          DropdownButtonFormField<String>(
                            initialValue: _selectedTechnique,
                            decoration: _buildInputDecoration(
                              label: 'Técnica favorita (opcional)',
                              icon: Icons.brush_outlined,
                            ),
                            style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
                            dropdownColor: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            items: _techniques.map((tech) {
                              return DropdownMenuItem(
                                value: tech,
                                child: Text(tech),
                              );
                            }).toList(),
                            onChanged: (val) => setState(() => _selectedTechnique = val),
                          ),
                          const SizedBox(height: 8),
                        ],

                        const SizedBox(height: 24),

                        // Submit button
                        authProvider.isLoading
                            ? Center(
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryAccent.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const CircularProgressIndicator(
                                    color: AppColors.primaryAccent,
                                    strokeWidth: 2.5,
                                  ),
                                ),
                              )
                            : Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [Color(0xFF8B6F47), Color(0xFFA68358)],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryAccent.withValues(alpha: 0.3),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: _submit,
                                    borderRadius: BorderRadius.circular(16),
                                    child: Center(
                                      child: Text(
                                        _isLogin ? "Iniciar Sesión" : "Crear Cuenta",
                                        style: GoogleFonts.inter(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                        const SizedBox(height: 28),

                        // Toggle mode
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _isLogin ? "¿No tienes cuenta? " : "¿Ya tienes cuenta? ",
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            GestureDetector(
                              onTap: _toggleMode,
                              child: Text(
                                _isLogin ? "Regístrate" : "Inicia sesión",
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryAccent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
