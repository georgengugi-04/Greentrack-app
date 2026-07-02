import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/models.dart';

class FarmerDashboard extends ConsumerWidget {
  const FarmerDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batchesAsync = ref.watch(farmerBatchesProvider);
    final phiLocked = ref.watch(phiLockedBatchesProvider);
    final readyNow = ref.watch(readyToHarvestProvider);
    final totalYield = ref.watch(totalYieldProvider);
    final userAsync = ref.watch(appUserProvider);
    final firstName = userAsync.valueOrNull?.name.split(' ').first ?? 'Farmer';

    return Scaffold(
      backgroundColor: AppColors.night,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TopBar(firstName: firstName),
                    const SizedBox(height: 22),
                    _SearchPanel(),
                    const SizedBox(height: 24),
                    _SectionHeader(
                      title: 'Crop Control Room',
                      action: 'Today',
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    _StatusRail(
                      activeCount: (batchesAsync.valueOrNull ?? [])
                          .where((batch) => batch.status != CropBatchStatus.delivered)
                          .length,
                      phiCount: phiLocked.length,
                      readyCount: readyNow.length,
                      totalYield: totalYield,
                    ),
                    const SizedBox(height: 24),
                    _SectionHeader(
                      title: 'Traceability Flow',
                      action: 'From plot to plate',
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    const _JourneyCards(),
                    const SizedBox(height: 24),
                    if (phiLocked.isNotEmpty) ...[
                      _AlertPanel(
                        icon: Icons.timer_outlined,
                        title: 'Harvest hold active',
                        message:
                            '${phiLocked.length} batch${phiLocked.length == 1 ? '' : 'es'} must finish the safety interval before harvest.',
                        color: AppColors.alert,
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (readyNow.isNotEmpty) ...[
                      _AlertPanel(
                        icon: Icons.shopping_basket_outlined,
                        title: 'Buyer-ready produce',
                        message:
                            '${readyNow.length} batch${readyNow.length == 1 ? '' : 'es'} can be logged and turned into QR labels.',
                        color: AppColors.harvest,
                      ),
                      const SizedBox(height: 12),
                    ],
                    _SectionHeader(
                      title: 'Quick Actions',
                      action: 'Create trace data',
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    _ActionGrid(),
                    const SizedBox(height: 24),
                    _SectionHeader(
                      title: 'Live Batches',
                      action: 'Newest first',
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                  ],
                ).animate().fadeIn(duration: 450.ms).slideY(begin: 0.03),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 110),
              sliver: batchesAsync.when(
                loading: () => const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(color: AppColors.sprout),
                    ),
                  ),
                ),
                error: (error, _) => SliverToBoxAdapter(
                  child: _AlertPanel(
                    icon: Icons.cloud_off_outlined,
                    title: 'Unable to load batches',
                    message: '$error',
                    color: AppColors.alert,
                  ),
                ),
                data: (batches) {
                  final active = batches
                      .where((batch) => batch.status != CropBatchStatus.delivered)
                      .take(5)
                      .toList();
                  if (active.isEmpty) {
                    return const SliverToBoxAdapter(child: _EmptyBatches());
                  }
                  return SliverList.separated(
                    itemBuilder: (_, index) => _BatchCard(batch: active[index]),
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemCount: active.length,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/farmer/batch/new'),
        backgroundColor: AppColors.glow,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'Start Batch',
          style: AppTextStyles.sans(14, color: Colors.white, weight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String firstName;
  const _TopBar({required this.firstName});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'GreenTrack',
                style: AppTextStyles.sans(13, color: AppColors.sprout, weight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                'Good ${_greeting()}, $firstName',
                style: AppTextStyles.serif(28, color: Colors.white),
              ),
            ],
          ),
        ),
        _GlassButton(icon: Icons.notifications_none_rounded, onTap: () {}),
        const SizedBox(width: 10),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [AppShadows.fab],
          ),
          child: const Icon(Icons.eco_rounded, color: Colors.white),
        ),
      ],
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }
}

class _SearchPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glowDecoration(),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: Colors.white54),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Search crop, batch code, buyer alert...',
              style: AppTextStyles.sans(14, color: Colors.white54),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              DateFormat('MMM d').format(DateTime.now()),
              style: AppTextStyles.mono(11, color: AppColors.sprout),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String action;
  final VoidCallback onTap;
  const _SectionHeader({required this.title, required this.action, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: AppTextStyles.serif(21, color: Colors.white)),
        const Spacer(),
        TextButton(onPressed: onTap, child: Text(action)),
      ],
    );
  }
}

class _StatusRail extends StatelessWidget {
  final int activeCount;
  final int phiCount;
  final int readyCount;
  final double totalYield;
  const _StatusRail({
    required this.activeCount,
    required this.phiCount,
    required this.readyCount,
    required this.totalYield,
  });

  @override
  Widget build(BuildContext context) {
    final tiles = [
      _MetricTile('Active', '$activeCount', Icons.spa_outlined, AppColors.sprout),
      _MetricTile('PHI Hold', '$phiCount', Icons.lock_clock_outlined, AppColors.glow),
      _MetricTile('Ready', '$readyCount', Icons.inventory_2_outlined, AppColors.harvest),
      _MetricTile('Yield', '${totalYield.toStringAsFixed(1)}kg', Icons.scale_outlined, AppColors.mint),
    ];

    return SizedBox(
      height: 126,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, index) => tiles[index],
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: tiles.length,
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _MetricTile(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 132,
      padding: const EdgeInsets.all(14),
      decoration: _glowDecoration(accent: color),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const Spacer(),
          Text(value, style: AppTextStyles.mono(22, color: Colors.white)),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.sans(12, color: Colors.white60)),
        ],
      ),
    );
  }
}

class _JourneyCards extends StatelessWidget {
  const _JourneyCards();

  @override
  Widget build(BuildContext context) {
    const cards = [
      _JourneyCardData(
        Icons.pin_drop_outlined, 
        'Farmer',
        'Create a geotagged crop batch and keep water, weather, pest, and harvest records together.',
        'https://images.unsplash.com/photo-1593113598332-cd288d649433?auto=format&fit=crop&q=80&w=400',
      ),
      _JourneyCardData(
        Icons.qr_code_scanner_outlined, 
        'Shopper',
        'Scan the package code and confirm where the produce came from before buying.',
        'https://images.unsplash.com/photo-1543083569-8f55c252f225?auto=format&fit=crop&q=80&w=400',
      ),
      _JourneyCardData(
        Icons.restaurant_menu_outlined, 
        'Chef',
        'Verify freshness, source, and certification before serving a dish.',
        'https://images.unsplash.com/photo-1577219491135-ce391730fb2c?auto=format&fit=crop&q=80&w=400',
      ),
      _JourneyCardData(
        Icons.fitness_center_outlined, 
        'Diner',
        'Open nutrition details connected to the scanned meal record.',
        'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&q=80&w=400',
      ),
    ];

    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, index) => _JourneyCard(data: cards[index], index: index),
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: cards.length,
      ),
    );
  }
}

class _JourneyCardData {
  final IconData icon;
  final String title;
  final String body;
  final String imageUrl;
  const _JourneyCardData(this.icon, this.title, this.body, this.imageUrl);
}

class _JourneyCard extends StatelessWidget {
  final _JourneyCardData data;
  final int index;
  const _JourneyCard({required this.data, required this.index});

  @override
  Widget build(BuildContext context) {
    final accent = [
      AppColors.sprout,
      AppColors.harvest,
      AppColors.glow,
      AppColors.mint
    ][index % 4];
    
    return Container(
      width: 240,
      decoration: _glowDecoration(accent: accent),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.network(
                    data.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(color: AppColors.panel),
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black54, Colors.transparent],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(data.icon, color: accent, size: 20),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: AppTextStyles.sans(15, color: Colors.white, weight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Text(
                      data.body,
                      style: AppTextStyles.sans(11, color: Colors.white60, height: 1.3),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      const _DashboardActionData(
        icon: Icons.add_location_alt_outlined,
        title: 'New Batch',
        subtitle: 'Crop, method, GPS plot',
        route: '/farmer/batch/new',
      ),
      const _DashboardActionData(
        icon: Icons.water_drop_outlined,
        title: 'Irrigation',
        subtitle: 'Water source & timing',
        route: '/farmer/irrigate',
      ),
      const _DashboardActionData(
        icon: Icons.bug_report_outlined,
        title: 'Pest Check',
        subtitle: 'Photo diagnosis & PHI',
        route: '/farmer/pest',
      ),
      const _DashboardActionData(
        icon: Icons.qr_code_2_outlined,
        title: 'Harvest QR',
        subtitle: 'Weights and labels',
        route: '/farmer/harvest',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemBuilder: (_, index) => _ActionCard(action: actions[index]),
    );
  }
}

class _DashboardActionData {
  final IconData icon;
  final String title;
  final String subtitle;
  final String route;
  const _DashboardActionData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
  });
}

class _ActionCard extends StatelessWidget {
  final _DashboardActionData action;
  const _ActionCard({required this.action});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => context.push(action.route),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: _glowDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(action.icon, color: AppColors.sprout, size: 22),
              const Spacer(),
              Text(
                action.title,
                style: AppTextStyles.sans(14, color: Colors.white, weight: FontWeight.w800),
              ),
              const SizedBox(height: 2),
              Text(
                action.subtitle,
                style: AppTextStyles.sans(10, color: Colors.white54),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BatchCard extends StatelessWidget {
  final CropBatch batch;
  const _BatchCard({required this.batch});

  @override
  Widget build(BuildContext context) {
    final progress = (batch.daysInGround /
            (batch.daysInGround + batch.daysToHarvest.clamp(1, 999)))
        .clamp(0.05, 1.0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glowDecoration(accent: batch.status.color),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [batch.status.color.withOpacity(0.28), AppColors.panel],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.eco_rounded, color: batch.status.color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  batch.cropName,
                  style: AppTextStyles.sans(16, color: Colors.white, weight: FontWeight.w800),
                ),
                const SizedBox(height: 3),
                Text(
                  '${batch.variety} • ${batch.farmingMethod.label}',
                  style: AppTextStyles.sans(11, color: Colors.white54),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress.toDouble(),
                    minHeight: 6,
                    color: batch.status.color,
                    backgroundColor: Colors.white10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                batch.phiActive
                    ? '${batch.phiDaysRemaining}d'
                    : batch.daysToHarvest >= 0
                        ? '${batch.daysToHarvest}d'
                        : 'Now',
                style: AppTextStyles.mono(17, color: batch.status.color),
              ),
              Text(
                batch.phiActive ? 'locked' : 'harvest',
                style: AppTextStyles.sans(10, color: Colors.white54),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AlertPanel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Color color;
  const _AlertPanel({
    required this.icon,
    required this.title,
    required this.message,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glowDecoration(accent: color),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.sans(14, color: Colors.white, weight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: AppTextStyles.sans(12, color: Colors.white60),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyBatches extends StatelessWidget {
  const _EmptyBatches();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: _glowDecoration(accent: AppColors.sprout),
      child: Column(
        children: [
          const Icon(Icons.add_location_alt_outlined, color: AppColors.sprout, size: 42),
          const SizedBox(height: 14),
          Text('No crop batches yet', style: AppTextStyles.serif(22, color: Colors.white)),
          const SizedBox(height: 8),
          Text(
            'Create the first batch to begin recording plot, irrigation, pest, harvest, and QR trace data.',
            textAlign: TextAlign.center,
            style: AppTextStyles.sans(13, color: Colors.white60),
          ),
        ],
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _GlassButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: Icon(icon, color: Colors.white70),
        ),
      ),
    );
  }
}

BoxDecoration _glowDecoration({Color accent = AppColors.glow}) {
  return BoxDecoration(
    color: AppColors.charcoal,
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: accent.withValues(alpha: 0.28)),
    boxShadow: [
      BoxShadow(
        color: accent.withValues(alpha: 0.16),
        blurRadius: 22,
        spreadRadius: 1,
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.34),
        blurRadius: 20,
        offset: const Offset(0, 12),
      ),
    ],
  );
}