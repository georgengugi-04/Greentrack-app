import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../shared/widgets/seed_growth_intro.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _progress;
  late Animation<double> _fade;
  bool _introDone = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));
    _progress = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _fade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.5)));
    // The seed→roots→sprout intro plays first (see SeedGrowthIntro); the
    // brand name/progress bar only start fading in once that finishes,
    // rather than on a fixed timer guessed independently of it.
  }

  void _onIntroComplete() {
    if (!mounted) return;
    setState(() => _introDone = true);
    _ctrl.forward();
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) context.go('/onboarding');
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D3320), Color(0xFF1B4332), Color(0xFF2D6A4F)],
          ),
        ),
        child: Stack(
          children: [
            // Farm photo backdrop — subtle, so the gradient still reads as
            // the dominant color and text stays fully legible.
            Positioned.fill(
              child: Opacity(
                opacity: 0.22,
                child: CachedNetworkImage(
                  imageUrl:
                      'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=900&q=80',
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF0D3320).withValues(alpha: 0.55),
                      const Color(0xFF1B4332).withValues(alpha: 0.75),
                      const Color(0xFF0D3320).withValues(alpha: 0.92),
                    ],
                  ),
                ),
              ),
            ),
            // Background circles
            const _BgCircle(top: -60, left: -60, size: 220, opacity: 0.12),
            const _BgCircle(top: -30, right: -40, size: 160, opacity: 0.08),
            const _BgCircle(bottom: 120, right: -80, size: 260, opacity: 0.1),
            const _BgCircle(bottom: -40, left: -50, size: 200, opacity: 0.08),

            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  // Seed → roots → sprout intro, then cross-fades to the
                  // logo mark once it finishes.
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 450),
                    child: _introDone
                        ? Container(
                            key: const ValueKey('logo'),
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Image.asset('assets/images/logo_icon.png',
                                  fit: BoxFit.contain),
                            ),
                          )
                        : SeedGrowthIntro(
                            key: const ValueKey('seed'),
                            size: 140,
                            onComplete: _onIntroComplete,
                          ),
                  ),
                  const SizedBox(height: 24),
                  FadeTransition(
                    opacity: _fade,
                    child: Column(children: [
                      // Brand name
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'green',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w300,
                                color: Colors.white,
                                fontFamily: 'Inter',
                              ),
                            ),
                            TextSpan(
                              text: 'track',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                fontFamily: 'Inter',
                              ),
                            ),
                            TextSpan(
                              text: '.',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w700,
                                color: AppColors.amber,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Cultivating Conscious Consumption',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 13,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ]),
                  ),
                  const Spacer(flex: 3),
                  // Progress bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 80),
                    child: AnimatedBuilder(
                      animation: _progress,
                      builder: (_, __) => ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _progress.value,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white),
                          minHeight: 3,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'v2.0.0',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BgCircle extends StatelessWidget {
  final double? top, bottom, left, right, size, opacity;
  const _BgCircle({this.top, this.bottom, this.left, this.right, this.size, this.opacity});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top, bottom: bottom, left: left, right: right,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: opacity ?? 0.1),
        ),
      ),
    );
  }
}
