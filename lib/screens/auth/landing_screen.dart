import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          const SizedBox.expand(),

          // Top dark section with brand
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight * 0.55,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF2C241B),
                    Color(0xFF3D3228),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Decorative circle accent
                  Positioned(
                    top: -100,
                    left: -80,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.primaryAccent.withValues(alpha: 0.12),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 40,
                    right: -60,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.secondaryAccent.withValues(alpha: 0.08),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Brand content
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 40),
                          // Logo mark
                          Container(
                            width: 56,
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
                            ),
                            child: const Center(
                              child: Text(
                                'E',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.white,
                                  letterSpacing: 1,
                                  height: 1.0,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            "Bienvenido a",
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: AppColors.secondaryAccent.withValues(alpha: 0.7),
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Eli's Art\nSupplies",
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 42,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: 48,
                            height: 3,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFC4A57B), Color(0xFF8B6F47)],
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Materiales profesionales para artistas\nque buscan calidad excepcional.",
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                              color: Colors.white.withValues(alpha: 0.6),
                              height: 1.6,
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

          // Bottom white section with portal buttons
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: screenHeight * 0.50,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFDFBF7),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: SlideTransition(
                position: _slideUp,
                child: FadeTransition(
                  opacity: _fadeIn,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(28, 40, 28, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Selecciona tu portal",
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Elige cómo deseas acceder a la plataforma",
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                // Customer Portal Card
                                _PortalCard(
                                  icon: Icons.palette_outlined,
                                  title: "Portal de Clientes",
                                  subtitle: "Explora, compra y acumula\npuntos de arte",
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [Color(0xFF8B6F47), Color(0xFFA68358)],
                                  ),
                                  iconBgColor: Colors.white.withValues(alpha: 0.2),
                                  textColor: Colors.white,
                                  onTap: () => context.push('/auth/customer'),
                                ),
                                const SizedBox(height: 16),

                                // Admin Portal Card
                                _PortalCard(
                                  icon: Icons.dashboard_customize_outlined,
                                  title: "Portal de Administración",
                                  subtitle: "Gestiona productos, pedidos\ny configuración",
                                  gradient: null,
                                  borderColor: AppColors.borderSubtle,
                                  iconBgColor: AppColors.backgroundSecondary,
                                  textColor: AppColors.textPrimary,
                                  onTap: () => context.push('/admin/login'),
                                ),

                                const SizedBox(height: 20),
                                // Footer
                                Center(
                                  child: Text(
                                    "© 2026 Eli's Art Supplies · Todos los derechos reservados",
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: AppColors.textSecondary.withValues(alpha: 0.5),
                                    ),
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PortalCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final LinearGradient? gradient;
  final Color? borderColor;
  final Color iconBgColor;
  final Color textColor;
  final VoidCallback onTap;

  const _PortalCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.gradient,
    this.borderColor,
    required this.iconBgColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  State<_PortalCard> createState() => _PortalCardState();
}

class _PortalCardState extends State<_PortalCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: widget.gradient,
            color: widget.gradient == null ? Colors.white : null,
            borderRadius: BorderRadius.circular(20),
            border: widget.borderColor != null
                ? Border.all(color: widget.borderColor!, width: 1.5)
                : null,
            boxShadow: [
              if (widget.gradient != null)
                BoxShadow(
                  color: const Color(0xFF8B6F47).withValues(alpha: 0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              if (widget.gradient == null)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: widget.iconBgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(widget.icon, size: 26, color: widget.textColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: widget.textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: widget.textColor.withValues(alpha: 0.7),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: widget.textColor.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
