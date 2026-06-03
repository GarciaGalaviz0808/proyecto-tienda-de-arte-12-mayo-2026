import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';


class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _dotController;

  final List<_OnboardingSlide> _slides = [
    const _OnboardingSlide(
      icon: Icons.palette_outlined,
      accentColor: Color(0xFF8B6F47),
      bgGradient: [Color(0xFF2C241B), Color(0xFF3D3228)],
      title: 'Calidad\nProfesional',
      description:
          'Seleccionamos los mejores pigmentos, lienzos y pinceles del mundo para que tus obras destaquen.',
      badgeText: 'PREMIUM',
    ),
    const _OnboardingSlide(
      icon: Icons.local_shipping_outlined,
      accentColor: Color(0xFF5A7F6E),
      bgGradient: [Color(0xFF1E2E28), Color(0xFF2A3E35)],
      title: 'Envíos\nCuidadosos',
      description:
          'Empaquetamos tus materiales con protección especial para que lleguen a tu taller en perfecto estado.',
      badgeText: 'SEGURO',
    ),
    const _OnboardingSlide(
      icon: Icons.auto_awesome_outlined,
      accentColor: Color(0xFFB89A6A),
      bgGradient: [Color(0xFF2E2518), Color(0xFF3E3425)],
      title: 'Comunidad\nArtística',
      description:
          'Únete a nuestro club de lealtad, acumula puntos en cada compra y canjea recompensas exclusivas.',
      badgeText: 'REWARDS',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_currentPage];

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: slide.bgGradient,
          ),
        ),
        child: Stack(
          children: [
            const SizedBox.expand(),

            // Decorative blurred circle
            AnimatedPositioned(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              top: _currentPage * 40.0 - 60,
              right: _currentPage * 20.0 - 80,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      slide.accentColor.withValues(alpha: 0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  // Top bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Page indicator
                        Text(
                          '${_currentPage + 1}/${_slides.length}',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.4),
                          ),
                        ),
                        // Skip button
                        TextButton(
                          onPressed: () => context.go('/landing'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white.withValues(alpha: 0.6),
                          ),
                          child: Text(
                            'Saltar',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Page view
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() => _currentPage = index);
                      },
                      itemCount: _slides.length,
                      itemBuilder: (context, index) {
                        final s = _slides[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 36),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Icon container
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: s.accentColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: s.accentColor.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Icon(
                                  s.icon,
                                  size: 38,
                                  color: s.accentColor,
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: s.accentColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  s.badgeText,
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: s.accentColor,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Title
                              Text(
                                s.title,
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  height: 1.15,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Accent line
                              Container(
                                width: 40,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: s.accentColor,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Description
                              Text(
                                s.description,
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.white.withValues(alpha: 0.6),
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Bottom controls
                  Padding(
                    padding: const EdgeInsets.fromLTRB(36, 0, 36, 40),
                    child: Row(
                      children: [
                        // Dot indicators
                        Row(
                          children: List.generate(
                            _slides.length,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeOutCubic,
                              margin: const EdgeInsets.only(right: 8),
                              width: _currentPage == index ? 28 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _currentPage == index
                                    ? slide.accentColor
                                    : Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        // Next / Start button
                        GestureDetector(
                          onTap: () {
                            if (_currentPage == _slides.length - 1) {
                              context.go('/landing');
                            } else {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeOutCubic,
                              );
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: _currentPage == _slides.length - 1 ? 140 : 56,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  slide.accentColor,
                                  slide.accentColor.withValues(alpha: 0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: slide.accentColor.withValues(alpha: 0.3),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Center(
                              child: _currentPage == _slides.length - 1
                                  ? Text(
                                      'Comenzar',
                                      style: GoogleFonts.inter(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                      size: 22,
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
          ],
        ),
      ),
    );
  }
}

class _OnboardingSlide {
  final IconData icon;
  final Color accentColor;
  final List<Color> bgGradient;
  final String title;
  final String description;
  final String badgeText;

  const _OnboardingSlide({
    required this.icon,
    required this.accentColor,
    required this.bgGradient,
    required this.title,
    required this.description,
    required this.badgeText,
  });
}
