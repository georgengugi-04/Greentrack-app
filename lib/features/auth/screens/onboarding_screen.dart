import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
      emoji: '🌱',
      tag: 'FROM PLANTING TO TABLE',
      title: 'Track Every Seed',
      body:
          'Log every crop you plant, monitor its growth stages, and never lose track of what\'s growing in your garden.',
      features: [
        _Feature('📍', 'Plot Management'),
        _Feature('🌡️', 'Growth Tracking'),
        _Feature('📸', 'Photo Diary'),
      ],
    ),
    _Slide(
      gradient: [Color(0xFF1A3A6B), Color(0xFF2D6CDF), Color(0xFF4D8FEF)],
      emoji: '📊',
      tag: 'ANALYTICS THAT GROW WITH YOU',
      title: 'Data-Driven Garden',
      body:
          'Understand your garden with beautiful charts showing yield trends, water usage, and crop performance over time.',
      features: [
        _Feature('📈', 'Yield Analytics'),
        _Feature('💧', 'Water Tracking'),
        _Feature('🏆', 'Top Performers'),
      ],
    ),
    _Slide(
      gradient: [Color(0xFF7A4200), Color(0xFFB7791F), Color(0xFFD4A017)],
      emoji: '🌾',
      tag: 'KNOW YOUR IMPACT',
      title: 'Harvest With Purpose',
      body:
          'Record every harvest, track where your produce goes, and see how your garden contributes to your family and community.',
      features: [
        _Feature('🍽️', 'Consumed'),
        _Feature('🛒', 'Sold at Market'),
        _Feature('❤️', 'Donated'),
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
      context.go('/login');
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
                  onPressed: () => context.go('/login'),
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
      child: SafeArea(
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
                    child:
                        Text(slide.emoji, style: const TextStyle(fontSize: 72)),
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
                            child: Text(f.emoji,
                                style: const TextStyle(fontSize: 18)),
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
    );
  }
}

class _Slide {
  final List<Color> gradient;
  final String emoji, tag, title, body;
  final List<_Feature> features;
  const _Slide({
    required this.gradient,
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
