import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  String? _errorMsg;
  bool _isLoading = false;

  late AnimationController _animController;
  late Animation<double> _formFade;
  late Animation<Offset> _formSlide;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _formFade = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _formSlide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _errorMsg = null;
      _isLoading = true;
    });

    final authProvider = context.read<AuthProvider>();

    try {
      await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!authProvider.isAdmin) {
        await authProvider.logout();
        throw Exception('Acceso Denegado: Esta cuenta no posee privilegios de administrador.');
      }

      if (mounted) context.go('/admin/dashboard');
    } catch (e) {
      setState(() {
        _errorMsg = e.toString()
            .replaceAll('Exception: ', '')
            .replaceAll('[firebase_auth/', '')
            .replaceAll(']', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
        color: Colors.white.withValues(alpha: 0.5),
      ),
      prefixIcon: Container(
        margin: const EdgeInsets.only(left: 12, right: 8),
        child: Icon(icon, size: 20, color: AppColors.secondaryAccent),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 48),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.08),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.secondaryAccent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.error.withValues(alpha: 0.7)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      errorStyle: GoogleFonts.inter(color: const Color(0xFFE8A0A0)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1510),
              Color(0xFF2C241B),
              Color(0xFF352D22),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Decorative accents
            Positioned(
              top: -80,
              right: -60,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primaryAccent.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              left: -70,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.secondaryAccent.withValues(alpha: 0.06),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Grid pattern overlay
            Positioned.fill(
              child: CustomPaint(
                painter: _GridPatternPainter(),
              ),
            ),

            // Main content
            const SizedBox.expand(),
            SafeArea(
              child: Column(
                children: [
                  // Top bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () => context.pop(),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryAccent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.primaryAccent.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: AppColors.secondaryAccent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'ADMIN',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.secondaryAccent,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Scrollable content
                  Expanded(
                    child: SlideTransition(
                      position: _formSlide,
                      child: FadeTransition(
                        opacity: _formFade,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 32),

                              // Shield icon
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppColors.primaryAccent.withValues(alpha: 0.2),
                                      AppColors.secondaryAccent.withValues(alpha: 0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: AppColors.primaryAccent.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.shield_outlined,
                                  size: 30,
                                  color: AppColors.secondaryAccent,
                                ),
                              ),
                              const SizedBox(height: 28),

                              Text(
                                "Panel de\nGestión",
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  height: 1.15,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "Ingresa con credenciales autorizadas para\nacceder al panel administrativo.",
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.white.withValues(alpha: 0.5),
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 36),

                              // Error message
                              if (_errorMsg != null) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: AppColors.error.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: AppColors.error.withValues(alpha: 0.25),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.warning_amber_rounded,
                                          size: 20, color: AppColors.error.withValues(alpha: 0.8)),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          _errorMsg!,
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            color: const Color(0xFFE8A0A0),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],

                              // Form
                              Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    TextFormField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                      decoration: _buildInputDecoration(
                                        label: 'Correo corporativo',
                                        icon: Icons.alternate_email_rounded,
                                      ),
                                      validator: (val) {
                                        if (val == null || val.trim().isEmpty) return 'Requerido';
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),

                                    TextFormField(
                                      controller: _passwordController,
                                      obscureText: _obscurePassword,
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                      decoration: _buildInputDecoration(
                                        label: 'Contraseña',
                                        icon: Icons.lock_outline_rounded,
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_off_outlined
                                                : Icons.visibility_outlined,
                                            size: 20,
                                            color: Colors.white.withValues(alpha: 0.4),
                                          ),
                                          onPressed: () =>
                                              setState(() => _obscurePassword = !_obscurePassword),
                                        ),
                                      ),
                                      validator: (val) {
                                        if (val == null || val.isEmpty) return 'Requerido';
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 32),

                                    // Submit button
                                    _isLoading
                                        ? Center(
                                            child: Container(
                                              width: 48,
                                              height: 48,
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: AppColors.secondaryAccent.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(14),
                                              ),
                                              child: const CircularProgressIndicator(
                                                color: AppColors.secondaryAccent,
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
                                                colors: [
                                                  Color(0xFFC4A57B),
                                                  Color(0xFF8B6F47),
                                                ],
                                              ),
                                              borderRadius: BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: AppColors.primaryAccent.withValues(alpha: 0.35),
                                                  blurRadius: 20,
                                                  offset: const Offset(0, 8),
                                                ),
                                              ],
                                            ),
                                            child: Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                onTap: _submit,
                                                borderRadius: BorderRadius.circular(16),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    const Icon(Icons.login_rounded, size: 20, color: Colors.white),
                                                    const SizedBox(width: 10),
                                                    Text(
                                                      "Ingresar al Panel",
                                                      style: GoogleFonts.inter(
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.w700,
                                                        color: Colors.white,
                                                        letterSpacing: 0.5,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 40),

                              // Security badge
                              Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.verified_user_outlined,
                                      size: 14,
                                      color: Colors.white.withValues(alpha: 0.25),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Conexión segura · Acceso restringido',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: Colors.white.withValues(alpha: 0.25),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Subtle grid pattern for the admin screen background
class _GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.02)
      ..strokeWidth = 0.5;

    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
