import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/session/session_provider.dart';
import '../../../core/theme/app_theme.dart';

// Crop image lookup — Unsplash free CDN, no API key needed
const _cropImages = {
  'Cherry Tomatoes': 'https://images.unsplash.com/photo-1546470427-f5dcc18e4b0d?w=600&q=80',
  'Tomatoes':        'https://images.unsplash.com/photo-1546470427-f5dcc18e4b0d?w=600&q=80',
  'Carrots':         'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=600&q=80',
  'Basil':           'https://images.unsplash.com/photo-1618375569909-3c8616cf7733?w=600&q=80',
  'Lettuce':         'https://images.unsplash.com/photo-1622205313162-be1d5712a43f?w=600&q=80',
  'Avocado':         'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?w=600&q=80',
  'Bell Pepper':     'https://images.unsplash.com/photo-1563565375-f3fdfdbefa83?w=600&q=80',
  'Cucumber':        'https://images.unsplash.com/photo-1604977042946-1eecc30f269e?w=600&q=80',
  'Eggplant':        'https://images.unsplash.com/photo-1617692855027-33b14f061079?w=600&q=80',
  'Kale':            'https://images.unsplash.com/photo-1524179091875-bf99a9a6af57?w=600&q=80',
};

const _defaultCropImage =
    'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=600&q=80';

// Mock crop data for the farmer
const _mockCrops = [
  _Crop('Cherry Tomatoes', 'Sweet Million · PLOT A', 'Ready to Harvest',
      Color(0xFFD4A017), 0.92, '2d', '~3.2kg', true),
  _Crop('Carrots', 'Nantes Half-Long · PLOT C', 'Vegetative',
      Color(0xFF40916C), 0.45, '28d', '~2.0kg', false),
  _Crop('Basil', 'Italian Large Leaf · PLOT B', 'Ready to Harvest',
      Color(0xFFD4A017), 0.92, 'Ready!', '~0.8kg', false),
  _Crop('Bell Pepper', 'California Wonder · PLOT B', 'Fruiting',
      Color(0xFF4D8FEF), 0.75, '10d', '~2.8kg', true),
];

class FarmerDashboardScreen extends ConsumerStatefulWidget {
  const FarmerDashboardScreen({super.key});

  @override
  ConsumerState<FarmerDashboardScreen> createState() =>
      _FarmerDashboardScreenState();
}

class _FarmerDashboardScreenState
    extends ConsumerState<FarmerDashboardScreen> {
  int _navIndex = 0;
  bool _showQuickActions = false;
  String _chartPeriod = 'Month';

  final _bars = const [
    _Bar('Jan', 0.3, 0.2), _Bar('Feb', 0.5, 0.4), _Bar('Mar', 0.4, 0.6),
    _Bar('Apr', 0.9, 0.5), _Bar('May', 0.7, 0.8), _Bar('Jun', 0.6, 0.7),
  ];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(sessionProvider);
    final name = user?.name ?? 'Farmer';

    return Scaffold(
      backgroundColor: AppColors.parchment,
      body: Stack(children: [
        IndexedStack(index: _navIndex, children: [
          _HomeTab(name: name, bars: _bars, period: _chartPeriod,
              onPeriod: (p) => setState(() => _chartPeriod = p)),
          const _CropsTab(),
          const _HarvestTab(),
          _ProfileTab(name: name),
        ]),
        if (_showQuickActions)
          _QuickActionsOverlay(
              onClose: () => setState(() => _showQuickActions = false)),
      ]),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.forest,
        elevation: 6,
        onPressed: () =>
            setState(() => _showQuickActions = !_showQuickActions),
        child: AnimatedRotation(
          turns: _showQuickActions ? 0.125 : 0,
          duration: const Duration(milliseconds: 200),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _BottomNav(
        index: _navIndex,
        onTap: (i) => setState(() {
          _navIndex = i;
          _showQuickActions = false;
        }),
      ),
    );
  }
}

// ── HOME TAB ─────────────────────────────────────────────────────────────────

class _HomeTab extends StatelessWidget {
  final String name;
  final List<_Bar> bars;
  final String period;
  final ValueChanged<String> onPeriod;

  const _HomeTab(
      {required this.name,
      required this.bars,
      required this.period,
      required this.onPeriod});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(slivers: [
      SliverToBoxAdapter(child: _WelcomeHeader(name: name)),
      SliverToBoxAdapter(child: _WeatherCard()),
      // Crop photo strip
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 0, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(children: [
                Text('My Crops', style: AppTextStyles.h2),
                const Spacer(),
                const Text('See all', style: TextStyle(color: AppColors.leaf,
                    fontSize: 13, fontWeight: FontWeight.w600)),
              ]),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _mockCrops.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                padding: const EdgeInsets.only(right: 16),
                itemBuilder: (_, i) => _CropPhotoCard(crop: _mockCrops[i]),
              ),
            ),
          ]),
        ),
      ),
      // KPI grid
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
        sliver: SliverGrid(
          delegate: SliverChildListDelegate([
            const _KpiCard('🌱', '+3 this week', true, '12', 'Active Crops', '18 total planted'),
            const _KpiCard('⚖️', '↑ 18%', true, '48.6kg', 'Season Yield', 'Goal: 72.0kg'),
            const _KpiCard('🌾', '2 this week', true, '5', 'Near Harvest', 'Next: Tomatoes in 3d'),
            const _KpiCard('⚠️', 'urgent', false, '2', 'Need Attention', 'Kale · Basil'),
          ]),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 12,
              mainAxisSpacing: 12, childAspectRatio: 1.05),
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _HarvestChart(bars: bars, period: period, onPeriod: onPeriod),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 100)),
    ]);
  }
}

// ── WELCOME HEADER ────────────────────────────────────────────────────────────

class _WelcomeHeader extends StatelessWidget {
  final String name;
  const _WelcomeHeader({required this.name});

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting =
        hour < 12 ? 'Good Morning' : hour < 17 ? 'Good Afternoon' : 'Good Evening';
    final emoji = hour < 12 ? '🌅' : hour < 17 ? '☀️' : '🌙';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('$greeting, $emoji',
                  style: AppTextStyles.label.copyWith(
                      color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 4),
              RichText(
                text: TextSpan(children: [
                  TextSpan(
                    text: name,
                    style: AppTextStyles.display.copyWith(
                        fontSize: 28, color: AppColors.forest),
                  ),
                  const TextSpan(
                    text: '!',
                    style: TextStyle(
                        fontSize: 28, color: AppColors.amber,
                        fontWeight: FontWeight.w900),
                  ),
                ]),
              ),
            ]),
          ),
          // Notification bell
          Stack(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border)),
              child: const Icon(Icons.notifications_outlined,
                  size: 22, color: AppColors.textSecondary),
            ),
            Positioned(top: 8, right: 8,
              child: Container(width: 9, height: 9,
                decoration: const BoxDecoration(
                    color: Colors.orange, shape: BoxShape.circle))),
          ]),
          const SizedBox(width: 10),
          // Avatar
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [AppColors.forest, AppColors.leaf]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'F',
                style: const TextStyle(color: Colors.white,
                    fontWeight: FontWeight.w800, fontSize: 18),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ── CROP PHOTO CARD ───────────────────────────────────────────────────────────

class _CropPhotoCard extends StatelessWidget {
  final _Crop crop;
  const _CropPhotoCard({required this.crop});

  @override
  Widget build(BuildContext context) {
    final imgUrl = _cropImages[crop.name] ?? _defaultCropImage;
    return Container(
      width: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.card,
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(children: [
        // Crop photo
        Positioned.fill(
          child: CachedNetworkImage(
            imageUrl: imgUrl,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(
                color: AppColors.mint.withValues(alpha: 0.3),
                child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2))),
            errorWidget: (_, __, ___) => Container(
                color: AppColors.mint.withValues(alpha: 0.3),
                child: const Icon(Icons.eco, color: AppColors.leaf, size: 40)),
          ),
        ),
        // Gradient overlay
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.3),
                  Colors.black.withValues(alpha: 0.75),
                ],
                stops: const [0.3, 0.6, 1.0],
              ),
            ),
          ),
        ),
        // Favorite heart
        if (crop.isFavorite)
          Positioned(top: 10, right: 10,
            child: Container(
              width: 28, height: 28,
              decoration: const BoxDecoration(
                  color: Colors.white24, shape: BoxShape.circle),
              child: const Center(
                child: Text('❤️', style: TextStyle(fontSize: 14)),
              ),
            )),
        // Stage badge top-left
        Positioned(top: 10, left: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: crop.stageColor.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(crop.stage,
                style: const TextStyle(color: Colors.white,
                    fontSize: 9, fontWeight: FontWeight.w700)),
          )),
        // Bottom info
        Positioned(bottom: 0, left: 0, right: 0,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(crop.name,
                  style: const TextStyle(color: Colors.white,
                      fontWeight: FontWeight.w700, fontSize: 13),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(crop.variety,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 10),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 6),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: crop.progress,
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(crop.stageColor),
                  minHeight: 4,
                ),
              ),
              const SizedBox(height: 4),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(crop.daysLabel,
                    style: TextStyle(color: crop.stageColor,
                        fontSize: 10, fontWeight: FontWeight.w700)),
                Text(crop.yieldLabel,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 10)),
              ]),
            ]),
          )),
      ]),
    );
  }
}

// ── WEATHER CARD ─────────────────────────────────────────────────────────────

class _WeatherCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
            begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(
            color: AppColors.forest.withValues(alpha: 0.3),
            blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(children: [
        Row(children: [
          const Text('⛅', style: TextStyle(fontSize: 36)),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('24°C',
                style: TextStyle(color: Colors.white,
                    fontSize: 32, fontWeight: FontWeight.w800)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20)),
              child: const Text('Partly Cloudy',
                  style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ]),
          const Spacer(),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Row(children: [
              const Icon(Icons.location_on, color: Colors.white54, size: 12),
              const SizedBox(width: 4),
              Text('Farm Zone',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
            ]),
          ]),
        ]),
        const SizedBox(height: 14),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          const _WStat('💧', '68%', 'Humidity'),
          _WDiv(), const _WStat('💨', '12 kph', 'Wind'),
          _WDiv(), const _WStat('🌧️', '8.4 mm', 'Rainfall'),
          _WDiv(), const _WStat('✅', 'Great', 'Planting'),
        ]),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10)),
          child: Row(children: [
            const Text('🌿', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Expanded(child: Text(
              'Ideal conditions for transplanting seedlings. Water tomatoes deeply this morning.',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9), fontSize: 13),
            )),
          ]),
        ),
      ]),
    );
  }
}

class _WStat extends StatelessWidget {
  final String emoji, value, label;
  const _WStat(this.emoji, this.value, this.label);
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(emoji, style: const TextStyle(fontSize: 18)),
    const SizedBox(height: 4),
    Text(value, style: const TextStyle(
        color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
    Text(label, style: TextStyle(
        color: Colors.white.withValues(alpha: 0.6), fontSize: 10)),
  ]);
}

class _WDiv extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 36, color: Colors.white.withValues(alpha: 0.2));
}

// ── KPI CARD ──────────────────────────────────────────────────────────────────

class _KpiCard extends StatelessWidget {
  final String emoji, badge, value, label, sub;
  final bool badgeGreen;
  const _KpiCard(this.emoji, this.badge, this.badgeGreen,
      this.value, this.label, this.sub);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border), boxShadow: AppShadows.card,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: badgeGreen
                  ? AppColors.mint.withValues(alpha: 0.3)
                  : const Color(0xFFFFEDE9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(badge,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                    color: badgeGreen
                        ? AppColors.leaf
                        : Colors.orange.shade700)),
          ),
        ]),
        const Spacer(),
        Text(value,
            style: const TextStyle(
                fontSize: 26, fontWeight: FontWeight.w900,
                color: AppColors.textPrimary)),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
        Text(sub, style: AppTextStyles.bodyMuted.copyWith(fontSize: 11)),
      ]),
    );
  }
}

// ── HARVEST CHART ─────────────────────────────────────────────────────────────

class _HarvestChart extends StatelessWidget {
  final List<_Bar> bars;
  final String period;
  final ValueChanged<String> onPeriod;
  const _HarvestChart(
      {required this.bars, required this.period, required this.onPeriod});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border), boxShadow: AppShadows.card,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Harvest Yield', style: AppTextStyles.h2),
            Text('Monthly kg comparison',
                style: AppTextStyles.bodyMuted.copyWith(fontSize: 12)),
          ])),
          _PeriodToggle(selected: period, onSelect: onPeriod),
        ]),
        const SizedBox(height: 14),
        const Row(children: [
          _Leg(AppColors.forest, '2026'),
          SizedBox(width: 16),
          _Leg(AppColors.amber, '2025'),
        ]),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: CustomPaint(painter: _ChartPainter(bars), size: Size.infinite),
        ),
      ]),
    );
  }
}

class _Leg extends StatelessWidget {
  final Color color; final String label;
  const _Leg(this.color, this.label);
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 12, height: 12,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
    const SizedBox(width: 6),
    Text(label, style: AppTextStyles.bodyMuted.copyWith(fontSize: 12)),
  ]);
}

class _PeriodToggle extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;
  const _PeriodToggle({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.parchment,
          borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.all(3),
      child: Row(mainAxisSize: MainAxisSize.min,
        children: ['Week', 'Month', 'Year'].map((p) {
          final active = p == selected;
          return GestureDetector(
            onTap: () => onSelect(p),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  color: active ? AppColors.forest : Colors.transparent,
                  borderRadius: BorderRadius.circular(16)),
              child: Text(p,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                      color: active ? Colors.white : AppColors.textSecondary)),
            ),
          );
        }).toList()),
    );
  }
}

class _Bar {
  final String month;
  final double v1, v2;
  const _Bar(this.month, this.v1, this.v2);
}

class _ChartPainter extends CustomPainter {
  final List<_Bar> bars;
  const _ChartPainter(this.bars);

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()..color = const Color(0xFFE8E4DC)..strokeWidth = 1;
    final p1 = Paint()..color = AppColors.forest;
    final p2 = Paint()..color = AppColors.amber;
    for (int i = 0; i <= 3; i++) {
      final y = size.height - size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final gw = size.width / bars.length;
    final bw = gw * 0.28;
    final gap = gw * 0.06;
    for (int i = 0; i < bars.length; i++) {
      final b = bars[i];
      final cx = gw * i + gw / 2;
      final h1 = size.height * 0.85 * b.v1;
      final h2 = size.height * 0.85 * b.v2;
      canvas.drawRRect(RRect.fromRectAndCorners(
          Rect.fromLTWH(cx - bw - gap / 2, size.height - h1, bw, h1),
          topLeft: const Radius.circular(4), topRight: const Radius.circular(4)), p1);
      canvas.drawRRect(RRect.fromRectAndCorners(
          Rect.fromLTWH(cx + gap / 2, size.height - h2, bw, h2),
          topLeft: const Radius.circular(4), topRight: const Radius.circular(4)), p2);
      final tp = TextPainter(
          text: TextSpan(text: b.month,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
          textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, Offset(cx - tp.width / 2, size.height + 4));
    }
  }

  @override
  bool shouldRepaint(_ChartPainter old) => false;
}

// ── CROPS TAB ────────────────────────────────────────────────────────────────

class _CropsTab extends StatefulWidget {
  const _CropsTab();
  @override
  State<_CropsTab> createState() => _CropsTabState();
}

class _CropsTabState extends State<_CropsTab> {
  int _filter = 0;
  final _filters = ['All (4)', '🌾 Harvest (2)', '🌿 Growing (2)', '⚠️ Attention (0)'];

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Row(children: [
          Text('My Crops', style: AppTextStyles.h1.copyWith(fontSize: 24)),
          const Spacer(),
          const Icon(Icons.grid_view_rounded, color: AppColors.forest),
          const SizedBox(width: 16),
          const Icon(Icons.sort, color: AppColors.textSecondary),
        ]),
      ),
      const SizedBox(height: 14),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          decoration: BoxDecoration(color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border)),
          child: const TextField(
            decoration: InputDecoration(
              hintText: 'Search crops, varieties...',
              prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ),
      const SizedBox(height: 12),
      SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _filters.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) => GestureDetector(
            onTap: () => setState(() => _filter = i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: _filter == i ? AppColors.forest : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: _filter == i ? AppColors.forest : AppColors.border),
              ),
              alignment: Alignment.center,
              child: Text(_filters[i],
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                      color: _filter == i ? Colors.white : AppColors.textSecondary)),
            ),
          ),
        ),
      ),
      const SizedBox(height: 12),
      Expanded(child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: _mockCrops.map((c) => _CropListCard(crop: c)).toList(),
      )),
    ]));
  }
}

class _CropListCard extends StatelessWidget {
  final _Crop crop;
  const _CropListCard({required this.crop});

  @override
  Widget build(BuildContext context) {
    final imgUrl = _cropImages[crop.name] ?? _defaultCropImage;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border), boxShadow: AppShadows.card),
      clipBehavior: Clip.hardEdge,
      child: Row(children: [
        // Small image on left
        SizedBox(
          width: 80, height: 90,
          child: CachedNetworkImage(
            imageUrl: imgUrl, fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: AppColors.mint.withValues(alpha: 0.2)),
            errorWidget: (_, __, ___) =>
                Container(color: AppColors.mint.withValues(alpha: 0.2),
                    child: const Icon(Icons.eco, color: AppColors.leaf)),
          ),
        ),
        Expanded(child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(crop.name,
                  style: AppTextStyles.h2.copyWith(fontSize: 15))),
              if (crop.isFavorite)
                const Text('❤️', style: TextStyle(fontSize: 13)),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: crop.stageColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20)),
                child: Text(crop.stage,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                        color: crop.stageColor)),
              ),
            ]),
            Text(crop.variety,
                style: AppTextStyles.bodyMuted.copyWith(fontSize: 12)),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: crop.progress,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(crop.stageColor),
                  minHeight: 6,
                ),
              )),
              const SizedBox(width: 8),
              Text('${(crop.progress * 100).toInt()}%',
                  style: AppTextStyles.label),
            ]),
            const SizedBox(height: 4),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              Text(crop.daysLabel,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                      color: crop.stageColor)),
              const SizedBox(width: 12),
              Text(crop.yieldLabel,
                  style: AppTextStyles.bodyMuted.copyWith(fontSize: 12)),
            ]),
          ]),
        )),
      ]),
    );
  }
}

// ── HARVEST & PROFILE TABS ────────────────────────────────────────────────────

class _HarvestTab extends StatelessWidget {
  const _HarvestTab();
  @override
  Widget build(BuildContext context) => SafeArea(child: Padding(
    padding: const EdgeInsets.all(20),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Harvest Log', style: AppTextStyles.h1),
      const SizedBox(height: 20),
      const _HarvestEntry('Tomatoes', 'Plot A', '3.2 kg', '20 Jun 2026',
          'https://images.unsplash.com/photo-1546470427-f5dcc18e4b0d?w=200&q=80'),
      const SizedBox(height: 16),
      Center(child: Text('Tap + to log your next harvest',
          style: AppTextStyles.bodyMuted)),
    ]),
  ));
}

class _HarvestEntry extends StatelessWidget {
  final String name, plot, weight, date, imgUrl;
  const _HarvestEntry(this.name, this.plot, this.weight, this.date, this.imgUrl);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border)),
      clipBehavior: Clip.hardEdge,
      child: Row(children: [
        SizedBox(width: 70, height: 70,
          child: CachedNetworkImage(imageUrl: imgUrl, fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: AppColors.mint.withValues(alpha: 0.2)),
            errorWidget: (_, __, ___) => const Icon(Icons.eco))),
        Expanded(child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
            Text('$plot · $date', style: AppTextStyles.bodyMuted.copyWith(fontSize: 12)),
          ]),
        )),
        Padding(padding: const EdgeInsets.only(right: 14),
          child: Text(weight,
              style: const TextStyle(fontWeight: FontWeight.w800,
                  color: AppColors.amber, fontSize: 16))),
      ]),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  final String name;
  const _ProfileTab({required this.name});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(slivers: [
      SliverToBoxAdapter(child: Container(
        height: 160,
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [Color(0xFF0D3320), Color(0xFF1B4332)],
                begin: Alignment.topLeft, end: Alignment.bottomRight)),
        child: SafeArea(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const SizedBox(height: 20),
          CircleAvatar(radius: 34,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'F',
                  style: const TextStyle(color: Colors.white,
                      fontWeight: FontWeight.w800, fontSize: 22))),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(color: Colors.white,
              fontWeight: FontWeight.w700, fontSize: 16)),
        ])),
      )),
      SliverToBoxAdapter(child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          const Row(children: [
            _SBox('🌱', '4', 'Crops'),
            SizedBox(width: 12),
            _SBox('⚖️', '3.2kg', 'Harvested'),
            SizedBox(width: 12),
            _SBox('📅', '1', 'Days Active'),
          ]),
          const SizedBox(height: 20),
          Align(alignment: Alignment.centerLeft,
              child: Text('Achievements', style: AppTextStyles.h2)),
          const SizedBox(height: 12),
          SizedBox(height: 90, child: ListView(scrollDirection: Axis.horizontal, children: const [
            _Badge('🏆', 'Top Grower', true),
            _Badge('🌾', '50kg Club', false),
            _Badge('💧', 'Water Wise', false),
            _Badge('📷', 'Documentor', false),
            _Badge('♻️', 'Zero Waste', false),
          ])),
          const SizedBox(height: 20),
          const _MenuGroup('Garden', [('🌱','My Crops'),('📍','Garden Plots'),('🌾','Harvest History')]),
          const SizedBox(height: 12),
          const _MenuGroup('Insights', [('📊','Analytics Dashboard'),('📋','Reports'),('📅','Planting Calendar')]),
          const SizedBox(height: 12),
          const _MenuGroup('Account', [('👤','Edit Profile'),('🔔','Notifications'),('🚪','Sign Out')]),
          const SizedBox(height: 100),
        ]),
      )),
    ]);
  }
}

class _SBox extends StatelessWidget {
  final String emoji, value, label;
  const _SBox(this.emoji, this.value, this.label);
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border)),
    child: Column(children: [
      Text(emoji, style: const TextStyle(fontSize: 22)),
      const SizedBox(height: 4),
      Text(value, style: AppTextStyles.h2.copyWith(fontSize: 18)),
      Text(label, style: AppTextStyles.bodyMuted.copyWith(fontSize: 11)),
    ]),
  ));
}

class _Badge extends StatelessWidget {
  final String emoji, label; final bool earned;
  const _Badge(this.emoji, this.label, this.earned);
  @override
  Widget build(BuildContext context) => Container(
    width: 76, margin: const EdgeInsets.only(right: 10),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: earned ? const Color(0xFFFFF8E6) : Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: earned ? const Color(0xFFEDD56A) : AppColors.border),
    ),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(emoji, style: const TextStyle(fontSize: 26)),
      const SizedBox(height: 4),
      Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600,
          color: earned ? const Color(0xFFB7791F) : AppColors.textSecondary),
          textAlign: TextAlign.center),
    ]),
  );
}

class _MenuGroup extends StatelessWidget {
  final String title; final List<(String,String)> items;
  const _MenuGroup(this.title, this.items);
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title, style: AppTextStyles.label.copyWith(fontSize: 12))),
      Container(
        decoration: BoxDecoration(color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border)),
        child: Column(children: items.asMap().entries.map((e) => Column(children: [
          ListTile(
            leading: Text(e.value.$1, style: const TextStyle(fontSize: 20)),
            title: Text(e.value.$2, style: AppTextStyles.body),
            trailing: const Icon(Icons.chevron_right,
                color: AppColors.textSecondary, size: 18),
            dense: true, onTap: () {},
          ),
          if (e.key < items.length - 1)
            const Divider(height: 1, indent: 56),
        ])).toList()),
      ),
    ],
  );
}

// ── QUICK ACTIONS ─────────────────────────────────────────────────────────────

class _QuickActionsOverlay extends StatelessWidget {
  final VoidCallback onClose;
  const _QuickActionsOverlay({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClose,
      child: Container(color: Colors.black.withValues(alpha: 0.45),
        alignment: Alignment.bottomCenter,
        child: GestureDetector(onTap: () {},
          child: Container(
            decoration: const BoxDecoration(color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: AppColors.border,
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: Text('Quick Actions', style: AppTextStyles.h2)),
                IconButton(icon: const Icon(Icons.close), onPressed: onClose),
              ]),
              Text('What would you like to record?', style: AppTextStyles.bodyMuted),
              const SizedBox(height: 16),
              GridView.count(shrinkWrap: true, crossAxisCount: 3,
                  crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1,
                  children: const [
                    _ABtn('🌱', 'Add Crop', 'Record a new planting', Color(0xFFEEF5EE)),
                    _ABtn('💧', 'Log Watering', 'Track water applied', Color(0xFFEEF4FF)),
                    _ABtn('🌾', 'Log Harvest', 'Record what you picked', Color(0xFFFFF8E6)),
                    _ABtn('📏', 'Growth Update', 'Measure plant height', Color(0xFFF5F0FF)),
                    _ABtn('🧪', 'Fertilize', 'Track fertilizer', Color(0xFFEEFBF5)),
                    _ABtn('📸', 'Add Photo', 'Document progress', Color(0xFFFFF0EE)),
                  ]),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFFEEF8F0),
                    borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  const Text('☀️', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Good growing day today!',
                        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                    Text('24°C · Humidity 68% · Light winds',
                        style: AppTextStyles.bodyMuted.copyWith(fontSize: 12)),
                  ])),
                ]),
              ),
            ]),
          )),
    );
  }
}

class _ABtn extends StatelessWidget {
  final String emoji, label, sub; final Color bg;
  const _ABtn(this.emoji, this.label, this.sub, this.bg);
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border)),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(emoji, style: const TextStyle(fontSize: 28)),
      const SizedBox(height: 6),
      Text(label, style: AppTextStyles.label.copyWith(
          fontSize: 11, color: AppColors.textPrimary), textAlign: TextAlign.center),
      Text(sub, style: AppTextStyles.bodyMuted.copyWith(fontSize: 9),
          textAlign: TextAlign.center),
    ]),
  );
}

// ── BOTTOM NAV ────────────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final int index; final ValueChanged<int> onTap;
  const _BottomNav({required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(), notchMargin: 8,
      color: Colors.white, elevation: 8,
      child: SizedBox(height: 60, child: Row(children: [
        Expanded(child: _NI(Icons.home_rounded, 'Home', 0, index, onTap)),
        Expanded(child: _NI(Icons.eco_outlined, 'Crops', 1, index, onTap)),
        const Expanded(child: SizedBox()),
        Expanded(child: _NI(Icons.store_outlined, 'Harvest', 2, index, onTap)),
        Expanded(child: _NI(Icons.person_outline, 'Profile', 3, index, onTap)),
      ])),
    );
  }
}

class _NI extends StatelessWidget {
  final IconData icon; final String label;
  final int idx, cur; final ValueChanged<int> onTap;
  const _NI(this.icon, this.label, this.idx, this.cur, this.onTap);
  @override
  Widget build(BuildContext context) {
    final active = idx == cur;
    return GestureDetector(onTap: () => onTap(idx),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon,
            color: active ? AppColors.forest : AppColors.textSecondary, size: 22),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 10,
            fontWeight: active ? FontWeight.w700 : FontWeight.w400,
            color: active ? AppColors.forest : AppColors.textSecondary)),
        if (active) Container(margin: const EdgeInsets.only(top: 2),
            width: 4, height: 4,
            decoration: const BoxDecoration(
                color: AppColors.forest, shape: BoxShape.circle)),
      ]),
    );
  }
}

// ── DATA MODELS ───────────────────────────────────────────────────────────────

class _Crop {
  final String name, variety, stage, daysLabel, yieldLabel;
  final Color stageColor;
  final double progress;
  final bool isFavorite;
  const _Crop(this.name, this.variety, this.stage, this.stageColor,
      this.progress, this.daysLabel, this.yieldLabel, this.isFavorite);
}