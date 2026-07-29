import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../shared/widgets/animated_emoji.dart';
import '../../shared/widgets/chef_cooking_illustration.dart';
import '../../shared/widgets/farmer_growing_illustration.dart';
import '../../shared/widgets/diner_eating_illustration.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  final List<_Slide> _slides = const [
    _Slide(
      gradient: [Color(0xFF0D3320), Color(0xFF1B4332), Color(0xFF2D6A4F)],
      photoUrl: 'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=900&q=80',
      emoji: '🌱',
      tag: 'FOR FARMERS',
      title: 'Log Every Batch',
      body:
          'Record every crop batch from planting to harvest, complete with irrigation, '
          'pest treatments, and PHI safety windows — then generate a QR code the whole '
          'supply chain can trust.',
      features: [
        _Feature('📸', 'AI Pest & Disease Scans'),
        _Feature('💧', 'Smart Irrigation Advice'),
        _Feature('🔖', 'One QR Per Batch'),
      ],
    ),
    _Slide(
      gradient: [Color(0xFF7A4200), Color(0xFFB7791F), Color(0xFFD4A017)],
      photoUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=900&q=80',
      emoji: '👨‍🍳',
      tag: 'FOR CHEFS',
      title: 'Verify What You Cook With',
      body:
          'Scan incoming batches to confirm farm origin, harvest date, and organic '
          'certification in seconds, then build meals with full nutrition and allergen '
          'info ready for the menu.',
      features: [
        _Feature('✅', 'Instant Batch Verification'),
        _Feature('🍽️', 'Meal & Allergen Builder'),
        _Feature('📊', 'Nutrition Snapshots'),
      ],
    ),
    _Slide(
      gradient: [Color(0xFF1A3A6B), Color(0xFF2D6CDF), Color(0xFF4D8FEF)],
      photoUrl: 'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=900&q=80',
      emoji: '🍽️',
      tag: 'FOR SHOPPERS & DINERS',
      title: 'Know Where It Came From',
      body:
          'Scan the QR code on your produce or your restaurant menu to trace it straight '
          'back to the farm — the plot, the farmer, the harvest date, all in one tap.',
      features: [
        _Feature('🔍', 'Farm-to-Table Trace'),
        _Feature('🌾', 'Real Harvest Data'),
        _Feature('🛡️', 'Verified Organic Claims'),
      ],
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < _slides.length - 1) {
      _controller.nextPage(
          duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
    } else {
      context.go('/welcome');
    }
  }

  void _back() {
    _controller.previousPage(
        duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: _slides.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) => _SlidePage(slide: _slides[i]),
          ),
          // Skip button
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: TextButton(
                  onPressed: () => context.go('/welcome'),
                  child: const Text('Skip',
                      style: TextStyle(color: Colors.white, fontSize: 15)),
                ),
              ),
            ),
          ),
          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  children: [
                    // Dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _slides.length,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: i == _page ? 28 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: i == _page
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Buttons
                    Row(
                      children: [
                        if (_page > 0) ...[
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _back,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(
                                    color: Colors.white54, width: 1.5),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50)),
                              ),
                              child: const Text('Back',
                                  style: TextStyle(fontSize: 16)),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _next,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black87,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50)),
                            ),
                            child: Text(
                              _page == _slides.length - 1
                                  ? 'Get Started 🌿'
                                  : 'Next →',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
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
        ],
      ),
    );
  }
}

class _SlidePage extends StatelessWidget {
  final _Slide slide;
  const _SlidePage({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: slide.gradient,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Real photo backdrop, tinted with the slide's brand gradient so
          // each role (farmer/chef/diner) still reads as its own color.
          Opacity(
            opacity: 0.28,
            child: CachedNetworkImage(
              imageUrl: slide.photoUrl,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  slide.gradient.first.withValues(alpha: 0.55),
                  slide.gradient.last.withValues(alpha: 0.85),
                ],
              ),
            ),
          ),
          SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              // Icon circle
              Center(
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.12),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2), width: 1),
                  ),
                  child: Center(
                    child: switch (slide.tag) {
                      'FOR CHEFS' => const ChefCookingIllustration(size: 150),
                      'FOR FARMERS' => const FarmerGrowingIllustration(size: 150),
                      'FOR SHOPPERS & DINERS' => const DinerEatingIllustration(size: 150),
                      _ => AnimatedEmoji(slide.emoji, size: 72),
                    },
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Tag
              Text(
                slide.tag,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 10),
              // Title
              Text(
                slide.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 16),
              // Body
              Text(
                slide.body,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 15,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 28),
              // Features
              ...slide.features.map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: AnimatedEmoji(f.emoji, size: 18),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          f.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )),
              const Spacer(),
            ],
          ),
        ),
      ),
        ],
      ),
    );
  }
}

class _Slide {
  final List<Color> gradient;
  final String photoUrl;
  final String emoji, tag, title, body;
  final List<_Feature> features;
  const _Slide({
    required this.gradient,
    required this.photoUrl,
    required this.emoji,
    required this.tag,
    required this.title,
    required this.body,
    required this.features,
  });
}

class _Feature {
  final String emoji, label;
  const _Feature(this.emoji, this.label);
}
