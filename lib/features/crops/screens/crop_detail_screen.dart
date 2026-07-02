import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:timeline_tile/timeline_tile.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/models.dart';

class CropDetailScreen extends StatefulWidget {
  final String cropId;
  const CropDetailScreen({super.key, required this.cropId});

  @override
  State<CropDetailScreen> createState() => _CropDetailScreenState();
}

class _CropDetailScreenState extends State<CropDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _favorite = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    final crop = MockData.crops.firstWhere((c) => c.id == widget.cropId,
        orElse: () => MockData.crops.first);
    _favorite = crop.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    final crop = MockData.crops.firstWhere((c) => c.id == widget.cropId,
        orElse: () => MockData.crops.first);
    final plot = MockData.plots.firstWhere((p) => p.id == crop.plotId,
        orElse: () => MockData.plots.first);

    return Scaffold(
      backgroundColor: AppColors.parchment,
      body: CustomScrollView(
        slivers: [
          _buildHeroAppBar(crop, plot),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildLifecycleSection(crop),
                _buildStatsRow(crop),
                _buildTabBar(),
                SizedBox(
                  height: 560,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _OverviewTab(crop: crop, plot: plot),
                      _GrowthTab(crop: crop),
                      _ActivityTab(crop: crop),
                      _PhotosTab(crop: crop),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildActionBar(crop),
    );
  }

  Widget _buildHeroAppBar(CropModel crop, GardenPlot plot) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: AppColors.forest,
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        IconButton(
          icon: Icon(
              _favorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: _favorite ? AppColors.red : Colors.white),
          onPressed: () => setState(() => _favorite = !_favorite),
        ),
        IconButton(
          icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
          onPressed: () => _showMoreOptions(crop),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: AppColors.heroGradient),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: 40,
                child: Opacity(
                  opacity: 0.15,
                  child:
                      Text(crop.emoji, style: const TextStyle(fontSize: 180)),
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 60,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${crop.category.emoji} ${crop.category.label}',
                        style: AppTextStyles.body(11,
                            weight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.9)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(crop.emoji, style: const TextStyle(fontSize: 36)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(crop.name,
                                  style: AppTextStyles.display(24,
                                      color: Colors.white)),
                              Text('${crop.variety} · ${plot.name}',
                                  style: AppTextStyles.body(13,
                                      color: Colors.white.withValues(alpha: 0.7))),
                            ],
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
      ),
    );
  }

  Widget _buildLifecycleSection(CropModel crop) {
    final stages = [
      CropStatus.seedling,
      CropStatus.sprouting,
      CropStatus.vegetative,
      CropStatus.flowering,
      CropStatus.fruiting,
      CropStatus.readyToHarvest,
    ];
    final currentIndex =
        stages.indexOf(crop.status).clamp(0, stages.length - 1);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [AppShadows.card],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Lifecycle Progress',
                  style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              Text('${(crop.harvestProgress * 100).toInt()}%',
                  style: AppTextStyles.display(18, color: crop.status.color)),
            ],
          ),
          const SizedBox(height: 18),

          // Stage dots with connecting line
          SizedBox(
            height: 60,
            child: Stack(
              children: [
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Container(height: 3, color: AppColors.border),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    height: 3,
                    width: (MediaQuery.of(context).size.width - 72) *
                        (currentIndex / (stages.length - 1)),
                    decoration: BoxDecoration(
                      gradient: AppColors.mintGradient,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: stages.asMap().entries.map((e) {
                    final passed = e.key <= currentIndex;
                    return Column(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: passed ? e.value.color : AppColors.border,
                            shape: BoxShape.circle,
                            border: e.key == currentIndex
                                ? Border.all(color: Colors.white, width: 3)
                                : null,
                            boxShadow: e.key == currentIndex
                                ? [
                                    BoxShadow(
                                      color: e.value.color.withOpacity(0.4),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    )
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(e.value.emoji,
                                style: const TextStyle(fontSize: 14)),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: crop.status.bgColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Current Stage: ${crop.status.label}',
                style: AppTextStyles.body(12,
                    weight: FontWeight.w700, color: crop.status.color),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildStatsRow(CropModel crop) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
              child: _MiniStat('📅', '${crop.daysInGround}', 'Days Growing')),
          const SizedBox(width: 10),
          Expanded(
              child: _MiniStat(
                  '⏳',
                  crop.daysToHarvest > 0 ? '${crop.daysToHarvest}' : 'Now',
                  'To Harvest')),
          const SizedBox(width: 10),
          Expanded(
              child:
                  _MiniStat('⚖️', '${crop.estimatedYieldKg}kg', 'Est. Yield')),
          const SizedBox(width: 10),
          Expanded(
              child: _MiniStat('🌱', '${crop.quantityPlanted}', 'Planted')),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.forest,
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.slateMid,
        labelStyle: AppTextStyles.body(11, weight: FontWeight.w700),
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Growth'),
          Tab(text: 'Activity'),
          Tab(text: 'Photos'),
        ],
      ),
    );
  }

  Widget _buildActionBar(CropModel crop) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: AppColors.cream,
        boxShadow: [
          BoxShadow(
            color: AppColors.slate.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => context.push('/growth/add'),
              icon: const Icon(Icons.straighten_rounded, size: 18),
              label: const Text('Growth'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.water_drop_outlined, size: 18),
              label: const Text('Water'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/harvest/log'),
              icon: const Text('🌾', style: TextStyle(fontSize: 16)),
              label: const Text('Log Harvest'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.amber),
            ),
          ),
        ],
      ),
    );
  }

  void _showMoreOptions(CropModel crop) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(4))),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('Edit Crop Details'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.swap_horiz_rounded),
            title: const Text('Move to Different Plot'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.archive_outlined),
            title: const Text('Mark as Harvested'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading:
                const Icon(Icons.delete_outline_rounded, color: AppColors.red),
            title: const Text('Delete Crop',
                style: TextStyle(color: AppColors.red)),
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String emoji, value, label;
  const _MiniStat(this.emoji, this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 4),
          Text(value,
              style: AppTextStyles.display(16, color: AppColors.forest)),
          Text(label,
              style: AppTextStyles.body(9, color: AppColors.slateLight),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ── OVERVIEW TAB ──────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  final CropModel crop;
  final GardenPlot plot;
  const _OverviewTab({required this.crop, required this.plot});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (crop.notes != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: crop.status == CropStatus.concern
                    ? AppColors.errorLight
                    : AppColors.paleGreen,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Text(crop.status == CropStatus.concern ? '⚠️' : '📝',
                      style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text(crop.notes!,
                          style:
                              AppTextStyles.body(12, color: AppColors.slate))),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          _DetailRow('🗓️', 'Planting Date',
              '${crop.plantingDate.day}/${crop.plantingDate.month}/${crop.plantingDate.year}'),
          _DetailRow('🌾', 'Expected Harvest',
              '${crop.expectedHarvestDate.day}/${crop.expectedHarvestDate.month}/${crop.expectedHarvestDate.year}'),
          _DetailRow('💧', 'Watering Schedule', crop.wateringFrequency.label),
          _DetailRow('📍', 'Garden Plot', '${plot.emoji} ${plot.name}'),
          _DetailRow('🧪', 'Soil Type', plot.soilType.label),
          _DetailRow('☀️', 'Sun Exposure', plot.sunExposure.label),
          _DetailRow(
              '🔢', 'Quantity Planted', '${crop.quantityPlanted} plants'),
          const SizedBox(height: 20),
          Text('Yield Tracking', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Estimated',
                              style: AppTextStyles.body(11,
                                  color: AppColors.slateLight)),
                          Text('${crop.estimatedYieldKg} kg',
                              style: AppTextStyles.display(18,
                                  color: AppColors.slate)),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 30, color: AppColors.border),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Actual So Far',
                                style: AppTextStyles.body(11,
                                    color: AppColors.slateLight)),
                            Text('${crop.actualYieldKg} kg',
                                style: AppTextStyles.display(18,
                                    color: AppColors.leaf)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: crop.yieldProgress.clamp(0, 1),
                    minHeight: 8,
                    backgroundColor: AppColors.border,
                    valueColor: const AlwaysStoppedAnimation(AppColors.leaf),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String emoji, label, value;
  const _DetailRow(this.emoji, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 12),
          Text(label,
              style: AppTextStyles.body(13, color: AppColors.slateLight)),
          const Spacer(),
          Text(value,
              style: AppTextStyles.body(13,
                  weight: FontWeight.w700, color: AppColors.forest)),
        ],
      ),
    );
  }
}

// ── GROWTH TAB ────────────────────────────────────────

class _GrowthTab extends StatelessWidget {
  final CropModel crop;
  const _GrowthTab({required this.crop});

  @override
  Widget build(BuildContext context) {
    final records = MockData.growthRecords
        .where((g) => g.cropId == crop.id)
        .toList()
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));

    if (records.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📏', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text('No growth records yet',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text('Add a measurement to start tracking',
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text('Height Over Time',
                        style: Theme.of(context).textTheme.titleLarge),
                    const Spacer(),
                    Text('cm',
                        style: AppTextStyles.body(11,
                            color: AppColors.slateLight)),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 160,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                          show: true,
                          getDrawingHorizontalLine: (_) =>
                              FlLine(color: AppColors.border, strokeWidth: 1)),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (v, _) => Text('${v.toInt()}',
                              style: AppTextStyles.body(9,
                                  color: AppColors.slateLight)),
                        )),
                        bottomTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: records
                              .asMap()
                              .entries
                              .map((e) =>
                                  FlSpot(e.key.toDouble(), e.value.heightCm))
                              .toList(),
                          isCurved: true,
                          color: AppColors.leaf,
                          barWidth: 3,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                              show: true,
                              color: AppColors.leaf.withValues(alpha: 0.1)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Measurement History',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          ...records.reversed.map((r) => _GrowthRecordTile(record: r)),
        ],
      ),
    );
  }
}

class _GrowthRecordTile extends StatelessWidget {
  final GrowthRecord record;
  const _GrowthRecordTile({required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                  '${record.recordedAt.day}/${record.recordedAt.month}/${record.recordedAt.year}',
                  style: AppTextStyles.body(12,
                      weight: FontWeight.w700, color: AppColors.forest)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: record.health == 'Concern'
                      ? AppColors.errorLight
                      : AppColors.successLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(record.health,
                    style: AppTextStyles.body(10,
                        weight: FontWeight.w700,
                        color: record.health == 'Concern'
                            ? AppColors.error
                            : AppColors.success)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _GrowthMetric('📏', '${record.heightCm.toInt()} cm'),
              const SizedBox(width: 16),
              _GrowthMetric('🍃', '${record.leafCount} leaves'),
              if (record.floweringObserved) ...[
                const SizedBox(width: 16),
                const _GrowthMetric('🌸', 'Flowering'),
              ],
            ],
          ),
          if (record.notes != null) ...[
            const SizedBox(height: 8),
            Text(record.notes!,
                style: AppTextStyles.body(11, color: AppColors.slateLight)),
          ],
        ],
      ),
    );
  }
}

class _GrowthMetric extends StatelessWidget {
  final String emoji, value;
  const _GrowthMetric(this.emoji, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 4),
        Text(value, style: AppTextStyles.mono(11, color: AppColors.slateMid)),
      ],
    );
  }
}

// ── ACTIVITY TAB ──────────────────────────────────────

class _ActivityTab extends StatelessWidget {
  final CropModel crop;
  const _ActivityTab({required this.crop});

  @override
  Widget build(BuildContext context) {
    final logs = MockData.activities.where((a) => a.cropId == crop.id).toList();

    if (logs.isEmpty) {
      return const Center(child: Text('No activity logged yet'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: logs.length,
      itemBuilder: (_, i) {
        final log = logs[i];
        return TimelineTile(
          alignment: TimelineAlign.manual,
          lineXY: 0.12,
          isFirst: i == 0,
          isLast: i == logs.length - 1,
          indicatorStyle: IndicatorStyle(
            width: 32,
            color: log.type.color,
            iconStyle: IconStyle(
              iconData: Icons.circle,
              color: log.type.color,
            ),
            padding: const EdgeInsets.all(4),
          ),
          beforeLineStyle: LineStyle(color: AppColors.border, thickness: 2),
          endChild: Container(
            margin: const EdgeInsets.only(left: 12, bottom: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(log.type.emoji, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(log.type.label,
                        style: AppTextStyles.body(11,
                            weight: FontWeight.w700, color: log.type.color)),
                    const Spacer(),
                    Text('${log.performedAt.day}/${log.performedAt.month}',
                        style: AppTextStyles.body(10,
                            color: AppColors.slateLight)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(log.description,
                    style: AppTextStyles.body(12, color: AppColors.slate)),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── PHOTOS TAB ────────────────────────────────────────

class _PhotosTab extends StatelessWidget {
  final CropModel crop;
  const _PhotosTab({required this.crop});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📸', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text('No photos yet', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text('Document your crop\'s journey',
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.camera_alt_outlined, size: 18),
            label: const Text('Add Photo'),
          ),
        ],
      ),
    );
  }
}
