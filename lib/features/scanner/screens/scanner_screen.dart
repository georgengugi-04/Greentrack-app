import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/app_providers.dart';
import '../../../data/models/models.dart';

// ── QR SCANNER SCREEN ─────────────────────────────────
// Used by shoppers, chefs, and diners

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});
  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  bool _scanning = false;
  String? _scannedId;

  @override
  Widget build(BuildContext context) {
    if (_scannedId != null) {
      return TraceResultScreen(
          batchId: _scannedId!,
          onReset: () => setState(() {
                _scannedId = null;
                _scanning = false;
              }));
    }

    return Scaffold(
      backgroundColor: AppColors.night,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text('GreenTrack',
                          style: AppTextStyles.serif(28, color: Colors.white)),
                      const Spacer(),
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                              color: AppColors.glow.withOpacity(0.16),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: AppColors.glow.withOpacity(0.35))),
                          child: Text('Trace mode',
                              style: AppTextStyles.sans(12,
                                  color: Colors.white,
                                  weight: FontWeight.w700))),
                    ]),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                          color: AppColors.charcoal,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: Colors.white12)),
                      child: Row(children: [
                        const Icon(Icons.search_rounded, color: Colors.white38),
                        const SizedBox(width: 10),
                        Expanded(
                            child: Text('Search farm, meal, batch code...',
                                style: AppTextStyles.sans(14,
                                    color: Colors.white54))),
                      ]),
                    ),
                    const SizedBox(height: 24),
                    Text('Choose Your Trace',
                        style: AppTextStyles.serif(22, color: Colors.white)),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 112,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: const [
                          _TraceRoleCard(
                              icon: Icons.shopping_bag_outlined,
                              title: 'Shopper',
                              subtitle: 'Package origin'),
                          _TraceRoleCard(
                              icon: Icons.restaurant_outlined,
                              title: 'Chef',
                              subtitle: 'Kitchen freshness'),
                          _TraceRoleCard(
                              icon: Icons.local_dining_outlined,
                              title: 'Diner',
                              subtitle: 'Meal nutrients'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
                child: Column(children: [
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                        color: AppColors.charcoal,
                        borderRadius: BorderRadius.circular(30),
                        border:
                            Border.all(color: AppColors.glow.withOpacity(0.32)),
                        boxShadow: [
                          BoxShadow(
                              color: AppColors.glow.withOpacity(0.2),
                              blurRadius: 32)
                        ]),
                    child: Stack(alignment: Alignment.center, children: [
                      Container(
                          width: 238,
                          height: 238,
                          decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.white24, width: 1),
                              borderRadius: BorderRadius.circular(24))),
                      ..._corners(),
                      const Icon(Icons.qr_code_2_rounded,
                          color: Colors.white12, size: 112),
                      if (_scanning)
                        Container(
                            width: 204,
                            height: 4,
                            decoration: BoxDecoration(
                                color: AppColors.sprout,
                                borderRadius: BorderRadius.circular(2),
                                boxShadow: [
                                  BoxShadow(
                                      color: AppColors.sprout.withOpacity(0.7),
                                      blurRadius: 14)
                                ])),
                    ]),
                  ),
                  const SizedBox(height: 26),
                  Text('Scan the produce QR',
                      style: AppTextStyles.serif(24, color: Colors.white)),
                  const SizedBox(height: 8),
                  Text(
                      'Open farm source, safety interval, transit timeline, and nutrition details from one code.',
                      style: AppTextStyles.sans(13,
                          color: Colors.white54, height: 1.35),
                      textAlign: TextAlign.center),
                  const Spacer(),
                  ElevatedButton.icon(
                      onPressed: _startScan,
                      icon: const Icon(Icons.qr_code_scanner_rounded),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.glow,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18))),
                      label: Text(_scanning ? 'Scanning...' : 'Scan QR Code',
                          style: AppTextStyles.sans(16,
                              weight: FontWeight.w800, color: Colors.white))),
                  const SizedBox(height: 12),
                  OutlinedButton(
                      onPressed: _demoScan,
                      style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white24),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48)),
                      child: Text('Use demo trace',
                          style:
                              AppTextStyles.sans(14, color: Colors.white70))),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _corners() {
    const c = AppColors.sprout;
    const s = 28.0;
    const t = 3.0;
    return [
      const Positioned(
          top: 0, left: 0, child: _Corner(s, t, c, top: true, left: true)),
      const Positioned(
          top: 0, right: 0, child: _Corner(s, t, c, top: true, left: false)),
      const Positioned(
          bottom: 0, left: 0, child: _Corner(s, t, c, top: false, left: true)),
      const Positioned(
          bottom: 0,
          right: 0,
          child: _Corner(s, t, c, top: false, left: false)),
    ];
  }

  void _startScan() async {
    setState(() => _scanning = true);
    await Future.delayed(const Duration(seconds: 2));
    // In production: use mobile_scanner package
    // For now, simulate a successful scan
    setState(() => _scannedId = 'demo-batch-001');
  }

  void _demoScan() {
    setState(() => _scannedId = 'demo-batch-001');
  }
}

class _TraceRoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _TraceRoleCard(
      {required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 124,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.charcoal,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.glow.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(color: AppColors.glow.withOpacity(0.14), blurRadius: 18)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.sprout),
          const Spacer(),
          Text(title,
              style: AppTextStyles.sans(13,
                  color: Colors.white, weight: FontWeight.w800)),
          Text(subtitle, style: AppTextStyles.sans(10, color: Colors.white54)),
        ],
      ),
    );
  }
}

class _Corner extends StatelessWidget {
  final double size, thickness;
  final Color color;
  final bool top, left;
  const _Corner(this.size, this.thickness, this.color,
      {required this.top, required this.left});

  @override
  Widget build(BuildContext context) => SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _CornerPainter(thickness, color, top, left)));
}

class _CornerPainter extends CustomPainter {
  final double t;
  final Color c;
  final bool top, left;
  _CornerPainter(this.t, this.c, this.top, this.left);

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = c
      ..strokeWidth = t
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final r = 8.0;
    if (top && left) {
      canvas.drawLine(Offset(0, size.height), Offset(0, r), p);
      canvas.drawLine(Offset(0, r), Offset(r, 0), p);
      canvas.drawLine(Offset(r, 0), Offset(size.width, 0), p);
    } else if (top && !left) {
      canvas.drawLine(const Offset(0, 0), Offset(size.width - r, 0), p);
      canvas.drawLine(Offset(size.width - r, 0), Offset(size.width, r), p);
      canvas.drawLine(
          Offset(size.width, r), Offset(size.width, size.height), p);
    } else if (!top && left) {
      canvas.drawLine(const Offset(0, 0), Offset(0, size.height - r), p);
      canvas.drawLine(Offset(0, size.height - r), Offset(r, size.height), p);
      canvas.drawLine(
          Offset(r, size.height), Offset(size.width, size.height), p);
    } else {
      canvas.drawLine(
          Offset(size.width, 0), Offset(size.width, size.height - r), p);
      canvas.drawLine(Offset(size.width, size.height - r),
          Offset(size.width - r, size.height), p);
      canvas.drawLine(
          Offset(size.width - r, size.height), Offset(0, size.height), p);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── TRACE RESULT SCREEN ───────────────────────────────
// Shown after successful QR scan — works for shopper, chef, diner

class TraceResultScreen extends ConsumerWidget {
  final String batchId;
  final VoidCallback onReset;

  const TraceResultScreen(
      {super.key, required this.batchId, required this.onReset});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultAsync = ref.watch(traceResultProvider(batchId));

    return Scaffold(
      backgroundColor: AppColors.clay,
      body: resultAsync.when(
        loading: () => Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text('Tracing batch...', style: AppTextStyles.sans(14)),
        ])),
        error: (e, _) => _NotFound(onReset: onReset),
        data: (result) => result == null
            ? _NotFound(onReset: onReset)
            : _TraceView(result: result, onReset: onReset),
      ),
    );
  }
}

class _TraceView extends StatelessWidget {
  final BatchTraceResult result;
  final VoidCallback onReset;
  const _TraceView({required this.result, required this.onReset});

  @override
  Widget build(BuildContext context) {
    final hoursAgo = DateTime.now().difference(result.harvestedAt).inHours;
    final freshLabel = hoursAgo < 24
        ? 'Harvested ${hoursAgo}h ago'
        : 'Harvested ${DateTime.now().difference(result.harvestedAt).inDays} days ago';

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 200,
          backgroundColor: AppColors.canopy,
          leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: onReset),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(gradient: AppColors.heroGradient),
              padding: const EdgeInsets.fromLTRB(24, 80, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(children: [
                    Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: result.isOrganicCertified
                                ? AppColors.harvest.withOpacity(0.25)
                                : Colors.white12,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: result.isOrganicCertified
                                    ? AppColors.harvest
                                    : Colors.white30)),
                        child: Row(children: [
                          Text(result.isOrganicCertified ? '🌿 ' : '🌱 ',
                              style: const TextStyle(fontSize: 12)),
                          Text(
                              result.isOrganicCertified
                                  ? 'Certified Organic'
                                  : result.farmingMethod.label,
                              style: AppTextStyles.sans(11,
                                  color: result.isOrganicCertified
                                      ? AppColors.harvest
                                      : Colors.white70,
                                  weight: FontWeight.w700)),
                        ])),
                    const SizedBox(width: 8),
                    Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: result.phiCompliant
                                ? Colors.green.withValues(alpha: 0.2)
                                : Colors.red.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20)),
                        child: Text(
                            result.phiCompliant
                                ? '✅ PHI Safe'
                                : '⚠️ PHI Warning',
                            style: AppTextStyles.sans(11,
                                color: Colors.white, weight: FontWeight.w700))),
                  ]),
                  const SizedBox(height: 10),
                  Text(result.cropName,
                      style: AppTextStyles.serif(28, color: Colors.white)),
                  Text('${result.variety} · ${result.farmName}',
                      style: AppTextStyles.sans(13, color: Colors.white70)),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              // Freshness card
              Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: hoursAgo < 48
                          ? AppColors.harvest.withOpacity(0.08)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: hoursAgo < 48
                              ? AppColors.harvest.withOpacity(0.3)
                              : AppColors.border)),
                  child: Row(children: [
                    Text(
                        hoursAgo < 24
                            ? '🟢'
                            : hoursAgo < 72
                                ? '🟡'
                                : '🔴',
                        style: const TextStyle(fontSize: 32)),
                    const SizedBox(width: 14),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text('Freshness Verified',
                              style: AppTextStyles.sans(14,
                                  weight: FontWeight.w700,
                                  color: AppColors.soil)),
                          Text(freshLabel,
                              style: AppTextStyles.sans(13,
                                  color: hoursAgo < 24
                                      ? AppColors.canopy
                                      : AppColors.slate)),
                          Text(
                              DateFormat('d MMM yyyy · HH:mm')
                                  .format(result.harvestedAt),
                              style: AppTextStyles.sans(11,
                                  color: AppColors.slateLight)),
                        ])),
                  ])),
              const SizedBox(height: 14),

              // Farm info card
              _InfoCard(icon: '🏡', title: 'Source Farm', children: [
                _InfoRow('Farm', result.farmName),
                _InfoRow('Farmer', result.farmerName),
                _InfoRow('Location', result.farmLocation),
                _InfoRow('Method', result.farmingMethod.label),
                if (result.certificationNumber != null)
                  _InfoRow('Cert #', result.certificationNumber!),
              ]),
              const SizedBox(height: 14),

              // Yield card
              _InfoCard(icon: '⚖️', title: 'Batch Details', children: [
                _InfoRow('Batch ID', batchId.substring(0, 8).toUpperCase()),
                _InfoRow(
                    'Yield', '${result.actualYieldKg.toStringAsFixed(1)} kg'),
                _InfoRow('PHI Compliance',
                    result.phiCompliant ? 'Compliant ✅' : 'Warning ⚠️'),
              ]),
              const SizedBox(height: 14),

              // Transit chain — the signature element
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Farm-to-Table Journey',
                          style: AppTextStyles.serif(18)),
                      const SizedBox(height: 4),
                      Text('Full chain of custody',
                          style: AppTextStyles.sans(12,
                              color: AppColors.slateLight)),
                      const SizedBox(height: 16),
                      ...result.transitEvents.asMap().entries.map((e) {
                        final isLast = e.key == result.transitEvents.length - 1;
                        return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(children: [
                                Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                        color: isLast
                                            ? AppColors.canopy
                                            : AppColors.mist,
                                        shape: BoxShape.circle),
                                    child: Center(
                                        child: Text(e.value.emoji,
                                            style: const TextStyle(
                                                fontSize: 16)))),
                                if (!isLast)
                                  Container(
                                      width: 2,
                                      height: 36,
                                      color: AppColors.border),
                              ]),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: Padding(
                                padding:
                                    EdgeInsets.only(bottom: isLast ? 0 : 24),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(e.value.description,
                                          style: AppTextStyles.sans(13,
                                              weight: FontWeight.w600,
                                              color: AppColors.soil)),
                                      Text(e.value.location,
                                          style: AppTextStyles.sans(11,
                                              color: AppColors.slate)),
                                      Text(
                                          DateFormat('d MMM yyyy · HH:mm')
                                              .format(e.value.timestamp),
                                          style: AppTextStyles.sans(10,
                                              color: AppColors.slateLight)),
                                    ]),
                              )),
                            ]);
                      }),
                    ]),
              ),
              const SizedBox(height: 14),

              // Nutrition (if available)
              if (result.nutrition != null) ...[
                _NutritionCard(nutrition: result.nutrition!),
                const SizedBox(height: 14),
              ],

              // Actions
              Row(children: [
                Expanded(
                    child: OutlinedButton.icon(
                        onPressed: () {/* share */},
                        icon: const Icon(Icons.share_outlined, size: 18),
                        label: const Text('Share'))),
                const SizedBox(width: 12),
                Expanded(
                    child: ElevatedButton.icon(
                        onPressed: () {/* log to fitness tracker */},
                        icon: const Icon(Icons.fitness_center,
                            size: 18, color: Colors.white),
                        label: const Text('Log Nutrients'))),
              ]),
              const SizedBox(height: 20),

              TextButton(
                  onPressed: onReset, child: const Text('← Scan another code')),
              const SizedBox(height: 40),
            ]),
          ),
        ),
      ],
    );
  }

  String get batchId => result.batchId;
}

class _InfoCard extends StatelessWidget {
  final String icon, title;
  final List<Widget> children;
  const _InfoCard(
      {required this.icon, required this.title, required this.children});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(title,
                style: AppTextStyles.sans(14,
                    weight: FontWeight.w700, color: AppColors.soil)),
          ]),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          ...children,
        ]),
      );
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow(this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [
          SizedBox(
              width: 90,
              child: Text(label,
                  style: AppTextStyles.sans(12, color: AppColors.slateLight))),
          Expanded(
              child: Text(value,
                  style: AppTextStyles.sans(13,
                      weight: FontWeight.w600, color: AppColors.soil))),
        ]),
      );
}

class _NutritionCard extends StatelessWidget {
  final NutritionInfo nutrition;
  const _NutritionCard({required this.nutrition});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Text('🥗', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text('Nutritional Info',
                style: AppTextStyles.sans(14,
                    weight: FontWeight.w700, color: AppColors.soil)),
            const Spacer(),
            Text('per 100g',
                style: AppTextStyles.sans(11, color: AppColors.slateLight)),
          ]),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            _NutriBadge('Calories', '${nutrition.caloriesPer100g.toInt()} kcal',
                AppColors.harvest),
            _NutriBadge('Protein', '${nutrition.proteinG.toStringAsFixed(1)}g',
                AppColors.canopy),
            _NutriBadge('Carbs', '${nutrition.carbsG.toStringAsFixed(1)}g',
                AppColors.leaf),
            _NutriBadge('Fibre', '${nutrition.fibreG.toStringAsFixed(1)}g',
                AppColors.sprout),
            _NutriBadge(
                'Fat', '${nutrition.fatG.toStringAsFixed(1)}g', AppColors.bark),
            ...nutrition.vitamins.entries.map((e) => _NutriBadge(e.key,
                '${e.value.toStringAsFixed(1)}mg', const Color(0xFF6B3FA0))),
          ]),
          const SizedBox(height: 12),
          ElevatedButton.icon(
              onPressed: () {/* log to fitness app */},
              icon: const Icon(Icons.fitness_center,
                  size: 16, color: Colors.white),
              label: const Text('Log to Fitness Tracker'),
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44))),
        ]),
      );
}

class _NutriBadge extends StatelessWidget {
  final String label, value;
  final Color color;
  const _NutriBadge(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: AppTextStyles.mono(13, color: color)),
          Text(label,
              style: AppTextStyles.sans(10, color: AppColors.slateLight)),
        ]),
      );
}

class _NotFound extends StatelessWidget {
  final VoidCallback onReset;
  const _NotFound({required this.onReset});
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.clay,
        body: Center(
            child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('❓', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 20),
            Text('Batch Not Found', style: AppTextStyles.serif(24)),
            const SizedBox(height: 8),
            Text(
                'This QR code doesn\'t match any GreenTrack batch. '
                'Make sure the produce has been registered on the platform.',
                style: AppTextStyles.sans(14, color: AppColors.slate),
                textAlign: TextAlign.center),
            const SizedBox(height: 32),
            ElevatedButton(onPressed: onReset, child: const Text('Scan Again')),
          ]),
        )),
      );
}
