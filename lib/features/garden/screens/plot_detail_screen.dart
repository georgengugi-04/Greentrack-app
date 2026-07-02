import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/models.dart';

class PlotDetailScreen extends StatelessWidget {
  final String plotId;
  const PlotDetailScreen({super.key, required this.plotId});

  @override
  Widget build(BuildContext context) {
    final plot = MockData.plots
        .firstWhere((p) => p.id == plotId, orElse: () => MockData.plots.first);
    final crops = MockData.crops.where((c) => c.plotId == plot.id).toList();

    return Scaffold(
      backgroundColor: AppColors.parchment,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: AppColors.forest,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.white),
                  onPressed: () {}),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration:
                    const BoxDecoration(gradient: AppColors.heroGradient),
                child: Stack(
                  children: [
                    Positioned(
                        right: -10,
                        top: 30,
                        child: Opacity(
                            opacity: 0.15,
                            child: Text(plot.emoji,
                                style: const TextStyle(fontSize: 140)))),
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 50,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(plot.name,
                              style: AppTextStyles.display(26,
                                  color: Colors.white)),
                          Text(plot.description,
                              style: AppTextStyles.body(12,
                                  color: Colors.white.withValues(alpha: 0.7)),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Plot info grid
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.cream,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [AppShadows.card],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                                child: _InfoTile('📐', plot.sizeLabel, 'Size')),
                            Expanded(
                                child: _InfoTile(
                                    '🧪', plot.soilType.label, 'Soil Type')),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          children: [
                            Expanded(
                                child: _InfoTile(
                                    '☀️',
                                    plot.sunExposure == SunExposure.fullSun
                                        ? 'Full Sun'
                                        : 'Partial',
                                    'Sun Exposure')),
                            Expanded(
                                child: _InfoTile(
                                    '💧',
                                    plot.hasIrrigation ? 'Yes' : 'Manual',
                                    'Irrigation')),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          children: [
                            Expanded(
                                child: _InfoTile(
                                    '🌱', '${crops.length}', 'Active Crops')),
                            Expanded(
                                child: _InfoTile(
                                    '🗓️',
                                    '${DateTime.now().difference(plot.createdAt).inDays}d',
                                    'Days Active')),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn().slideY(begin: 0.1),

                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Text('Crops in This Plot',
                          style: Theme.of(context).textTheme.titleLarge),
                      const Spacer(),
                      Text('${crops.length}',
                          style: AppTextStyles.mono(
                              size: 14, color: AppColors.leaf)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  ...crops.asMap().entries.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _PlotCropTile(crop: e.value, index: e.key),
                      )),

                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => context.push('/crops/add'),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Add Crop to This Plot'),
                    style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50)),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String emoji, value, label;
  const _InfoTile(this.emoji, this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: AppTextStyles.body(13,
                    weight: FontWeight.w700, color: AppColors.forest)),
            Text(label,
                style: AppTextStyles.body(10, color: AppColors.slateLight)),
          ],
        ),
      ],
    );
  }
}

class _PlotCropTile extends StatelessWidget {
  final CropModel crop;
  final int index;
  const _PlotCropTile({required this.crop, required this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/crops/${crop.id}'),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: crop.status.bgColor,
                  borderRadius: BorderRadius.circular(12)),
              child: Center(
                  child:
                      Text(crop.emoji, style: const TextStyle(fontSize: 20))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(crop.name,
                      style: AppTextStyles.body(13,
                          weight: FontWeight.w700, color: AppColors.forest)),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: crop.harvestProgress,
                      minHeight: 4,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation(crop.status.color),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(crop.status.emoji, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 60 * index))
        .fadeIn()
        .slideX(begin: 0.05);
  }
}
