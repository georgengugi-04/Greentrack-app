import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/models.dart';

class GardenScreen extends StatelessWidget {
  const GardenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final totalArea = MockData.plots.fold<double>(0, (s, p) => s + p.areaM2);
    final totalCrops =
        MockData.plots.fold<int>(0, (s, p) => s + p.activeCropCount);

    return Scaffold(
      backgroundColor: AppColors.parchment,
      appBar: AppBar(
        title: const Text('Garden Plots'),
        actions: [
          IconButton(icon: const Icon(Icons.map_outlined), onPressed: () {}),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                      child: _StatCard('🗺️',
                          '${totalArea.toStringAsFixed(0)}m²', 'Total Area')),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _StatCard(
                          '📍', '${MockData.plots.length}', 'Active Plots')),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _StatCard('🌱', '$totalCrops', 'Total Crops')),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _PlotCard(plot: MockData.plots[i], index: i),
                ),
                childCount: MockData.plots.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Plot'),
        backgroundColor: AppColors.forest,
        foregroundColor: Colors.white,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String emoji, value, label;
  const _StatCard(this.emoji, this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 6),
          Text(value,
              style: AppTextStyles.display(18, color: AppColors.forest)),
          Text(label,
              style: AppTextStyles.body(9, color: AppColors.slateLight)),
        ],
      ),
    );
  }
}

class _PlotCard extends StatelessWidget {
  final GardenPlot plot;
  final int index;
  const _PlotCard({required this.plot, required this.index});

  @override
  Widget build(BuildContext context) {
    final crops = MockData.crops.where((c) => c.plotId == plot.id).toList();
    final needsAttention = crops.any((c) => c.status == CropStatus.concern);

    return GestureDetector(
      onTap: () => context.push('/garden/${plot.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: [AppShadows.card],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                        child: Text(plot.emoji,
                            style: const TextStyle(fontSize: 24))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(plot.name,
                            style:
                                AppTextStyles.display(17, color: Colors.white)),
                        Text('📐 ${plot.sizeLabel}',
                            style: AppTextStyles.body(11,
                                color: Colors.white.withValues(alpha: 0.7))),
                      ],
                    ),
                  ),
                  if (needsAttention)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('⚠️', style: TextStyle(fontSize: 12)),
                    ),
                ],
              ),
            ),

            // Body
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _PlotStat('Soil', plot.soilType.label)),
                      Expanded(
                          child: _PlotStat('Crops', '${plot.activeCropCount}')),
                      Expanded(
                          child: _PlotStat(
                              'Sun',
                              plot.sunExposure == SunExposure.fullSun
                                  ? 'Full'
                                  : 'Partial')),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Crop emoji row
                  if (crops.isNotEmpty) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 6,
                        children: crops
                            .take(6)
                            .map((c) => Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: c.status.bgColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: c.status.color.withOpacity(0.3)),
                                  ),
                                  child: Center(
                                      child: Text(c.emoji,
                                          style:
                                              const TextStyle(fontSize: 14))),
                                ))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => context.push('/garden/${plot.id}'),
                          child: const Text('View Crops'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => context.push('/crops/add'),
                          child: const Text('+ Add Crop'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 100 * index))
        .fadeIn()
        .slideY(begin: 0.05);
  }
}

class _PlotStat extends StatelessWidget {
  final String label, value;
  const _PlotStat(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: AppTextStyles.body(13,
                weight: FontWeight.w700, color: AppColors.forest)),
        Text(label, style: AppTextStyles.body(9, color: AppColors.slateLight)),
      ],
    );
  }
}
