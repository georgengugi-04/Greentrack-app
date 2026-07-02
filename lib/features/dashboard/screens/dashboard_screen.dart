import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/models.dart';
import '../../shared/widgets/app_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _scrollController = ScrollController();
  bool _showStickyHeader = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final show = _scrollController.offset > 100;
      if (show != _showStickyHeader) setState(() => _showStickyHeader = show);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.parchment,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Weather Bar
                _WeatherBar(data: MockData.weather)
                    .animate()
                    .fadeIn(delay: 100.ms)
                    .slideY(begin: 0.1),

                const SizedBox(height: 20),

                // KPI Cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _KpiGrid(stats: MockData.stats),
                ),
                const SizedBox(height: 24),

                // Harvest Chart
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _HarvestChart(),
                ),
                const SizedBox(height: 20),

                // Active Crops Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Text('Active Crops',
                          style: Theme.of(context).textTheme.titleLarge),
                      const Spacer(),
                      TextButton(
                        onPressed: () {},
                        child: const Text('View All →'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Horizontal crop cards
                _HorizontalCropList(
                    crops: MockData.crops
                        .where((c) => c.status != CropStatus.harvested)
                        .toList()),
                const SizedBox(height: 24),

                // Upcoming Harvests
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _UpcomingHarvestsCard(),
                ),
                const SizedBox(height: 20),

                // Destination Donut + Activity split
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _DestinationCard()),
                      const SizedBox(width: 12),
                      Expanded(child: _SeasonProgressCard()),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Activity Feed
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _ActivityFeed(),
                ),

                const SizedBox(height: 120), // bottom nav space
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      snap: true,
      pinned: false,
      backgroundColor: AppColors.cream,
      title: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Good Morning! 🌅',
                  style: AppTextStyles.label(
                    color: AppColors.leaf,
                    letterSpacing: 0.5,
                    size: 11,
                  )),
              Text(
                'Maria\'s Garden',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => context.push('/notifications'),
            child: Stack(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.parchment,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(Icons.notifications_outlined,
                      size: 20, color: AppColors.forest),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.amber,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.leaf, AppColors.amber],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'MR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── WEATHER BAR ──────────────────────────────────────

class _WeatherBar extends StatelessWidget {
  final WeatherData data;
  const _WeatherBar({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [AppShadows.large],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(data.emoji, style: const TextStyle(fontSize: 36)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${data.tempC.toInt()}°C',
                        style: AppTextStyles.display(30, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(data.condition,
                            style: AppTextStyles.body(
                              11,
                              weight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.9),
                            )),
                      ),
                    ],
                  ),
                  Text('📍 Quezon City Garden Zone',
                      style: AppTextStyles.body(11,
                          color: Colors.white.withValues(alpha: 0.6))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _WeatherStat('💧', '${data.humidity.toInt()}%', 'Humidity'),
              _WeatherDivider(),
              _WeatherStat('💨', '${data.windKph.toInt()} kph', 'Wind'),
              _WeatherDivider(),
              _WeatherStat('🌧️', '${data.rainfallMm} mm', 'Rainfall'),
              _WeatherDivider(),
              _WeatherStat(
                data.isGoodForPlanting ? '✅' : '❌',
                'Great',
                'For Planting',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                const Text('🌿', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    data.tip,
                    style: AppTextStyles.body(
                      12,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
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

class _WeatherStat extends StatelessWidget {
  final String emoji, value, label;
  const _WeatherStat(this.emoji, this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 2),
          Text(value,
              style: AppTextStyles.mono(
                size: 12,
                weight: FontWeight.w600,
                color: Colors.white,
              )),
          Text(label,
              style: AppTextStyles.body(
                9,
                color: Colors.white.withValues(alpha: 0.55),
              )),
        ],
      ),
    );
  }
}

class _WeatherDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 36,
        color: Colors.white.withValues(alpha: 0.15),
      );
}

// ── KPI GRID ─────────────────────────────────────────

class _KpiGrid extends StatelessWidget {
  final GardenStats stats;
  const _KpiGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: _KpiCard(
              emoji: '🌱',
              label: 'Active Crops',
              value: stats.activeCrops.toString(),
              sub: '${stats.totalCrops} total planted',
              color: AppColors.leaf,
              trend: '+3 this week',
              trendUp: true,
            ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.2)),
            const SizedBox(width: 12),
            Expanded(
                child: _KpiCard(
              emoji: '⚖️',
              label: 'Season Yield',
              value: '${stats.totalHarvestKg}kg',
              sub: 'Goal: ${stats.seasonGoalKg}kg',
              color: AppColors.amber,
              trend: '↑ 18%',
              trendUp: true,
            ).animate(delay: 150.ms).fadeIn().slideY(begin: 0.2)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: const _KpiCard(
              emoji: '🌾',
              label: 'Near Harvest',
              value: '5',
              sub: 'Next: Tomatoes in 3d',
              color: AppColors.amber,
              trend: '2 this week',
              trendUp: true,
            ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2)),
            const SizedBox(width: 12),
            Expanded(
                child: _KpiCard(
              emoji: '⚠️',
              label: 'Need Attention',
              value: '2',
              sub: 'Kale · Basil',
              color: AppColors.red,
              trend: 'urgent',
              trendUp: false,
            ).animate(delay: 250.ms).fadeIn().slideY(begin: 0.2)),
          ],
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String emoji, label, value, sub, trend;
  final Color color;
  final bool trendUp;

  const _KpiCard({
    required this.emoji,
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
    required this.trend,
    required this.trendUp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [AppShadows.subtle],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(child: Text(emoji)),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color:
                      trendUp ? AppColors.successLight : AppColors.errorLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  trend,
                  style: AppTextStyles.mono(
                    size: 9,
                    color: trendUp ? AppColors.success : AppColors.error,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(value,
              style: AppTextStyles.display(24, color: AppColors.forest)),
          const SizedBox(height: 2),
          Text(label,
              style: AppTextStyles.body(
                12,
                weight: FontWeight.w600,
                color: AppColors.slateMid,
              )),
          const SizedBox(height: 4),
          Text(sub, style: AppTextStyles.body(11, color: AppColors.slateLight)),
        ],
      ),
    );
  }
}

// ── HARVEST CHART ─────────────────────────────────────

class _HarvestChart extends StatefulWidget {
  @override
  State<_HarvestChart> createState() => _HarvestChartState();
}

class _HarvestChartState extends State<_HarvestChart> {
  int _selectedPeriod = 1;

  @override
  Widget build(BuildContext context) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug'];
    final data2024 = [2.1, 1.8, 3.4, 5.2, 6.8, 8.4, 0.0, 0.0];
    final data2023 = [1.6, 1.4, 2.8, 4.1, 5.5, 6.9, 7.2, 6.4];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [AppShadows.card],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Harvest Yield',
                      style: Theme.of(context).textTheme.titleLarge),
                  Text('Monthly kg comparison',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
              const Spacer(),
              _PeriodChip('Week', 0, _selectedPeriod,
                  () => setState(() => _selectedPeriod = 0)),
              _PeriodChip('Month', 1, _selectedPeriod,
                  () => setState(() => _selectedPeriod = 1)),
              _PeriodChip('Year', 2, _selectedPeriod,
                  () => setState(() => _selectedPeriod = 2)),
            ],
          ),
          const SizedBox(height: 20),

          // Legend
          const Row(
            children: [
              _ChartLegend(AppColors.leaf, '2024'),
              SizedBox(width: 16),
              _ChartLegend(AppColors.amber, '2023'),
            ],
          ),
          const SizedBox(height: 16),

          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 12,
                barGroups: List.generate(
                    8,
                    (i) => BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: data2024[i],
                              color: AppColors.leaf,
                              width: 8,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            BarChartRodData(
                              toY: data2023[i],
                              color: AppColors.amber.withValues(alpha: 0.6),
                              width: 8,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                          barsSpace: 4,
                        )),
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: 3,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: AppColors.border,
                    strokeWidth: 1,
                  ),
                  drawVerticalLine: false,
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 3,
                      reservedSize: 32,
                      getTitlesWidget: (v, _) => Text(
                        '${v.toInt()}',
                        style:
                            AppTextStyles.body(10, color: AppColors.slateLight),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) => Text(
                        months[v.toInt()],
                        style:
                            AppTextStyles.body(10, color: AppColors.slateLight),
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.1);
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final int index, selected;
  final VoidCallback onTap;

  const _PeriodChip(this.label, this.index, this.selected, this.onTap);

  @override
  Widget build(BuildContext context) {
    final isSelected = index == selected;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.forest : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: AppTextStyles.body(
              11,
              weight: FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.slateLight,
            )),
      ),
    );
  }
}

class _ChartLegend extends StatelessWidget {
  final Color color;
  final String label;
  const _ChartLegend(this.color, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.body(11, color: AppColors.slateMid)),
      ],
    );
  }
}

// ── HORIZONTAL CROP LIST ─────────────────────────────

class _HorizontalCropList extends StatelessWidget {
  final List<CropModel> crops;
  const _HorizontalCropList({required this.crops});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: crops.length,
        itemBuilder: (_, i) {
          final crop = crops[i];
          return _CropCard(crop: crop, index: i);
        },
      ),
    );
  }
}

class _CropCard extends StatelessWidget {
  final CropModel crop;
  final int index;
  const _CropCard({required this.crop, required this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/crops/${crop.id}'),
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: crop.status == CropStatus.concern
                ? AppColors.red.withOpacity(0.4)
                : crop.status == CropStatus.readyToHarvest
                    ? AppColors.amber.withValues(alpha: 0.4)
                    : AppColors.border,
          ),
          boxShadow: [AppShadows.subtle],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emoji + status badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(crop.emoji, style: const TextStyle(fontSize: 28)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: crop.status.bgColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    crop.status.emoji,
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Text(
              crop.name,
              style: AppTextStyles.body(
                13,
                weight: FontWeight.w700,
                color: AppColors.forest,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              crop.variety,
              style: AppTextStyles.body(10, color: AppColors.slateLight),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: crop.harvestProgress,
                minHeight: 5,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation(crop.status.color),
              ),
            ),
            const SizedBox(height: 6),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  crop.daysToHarvest > 0
                      ? '${crop.daysToHarvest}d left'
                      : 'Overdue!',
                  style: AppTextStyles.mono(
                    size: 10,
                    color: crop.daysToHarvest <= 0
                        ? AppColors.red
                        : AppColors.slateLight,
                  ),
                ),
                Text(crop.estimatedYieldKg.toStringAsFixed(1) + 'kg',
                    style: AppTextStyles.mono(
                      size: 10,
                      color: AppColors.leaf,
                    )),
              ],
            ),
          ],
        ),
      )
          .animate(delay: Duration(milliseconds: 80 * index))
          .fadeIn(duration: 300.ms)
          .slideX(begin: 0.1),
    );
  }
}

// ── UPCOMING HARVESTS ─────────────────────────────────

class _UpcomingHarvestsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final upcoming = MockData.crops.where((c) => c.isNearHarvest).toList()
      ..sort((a, b) => a.daysToHarvest.compareTo(b.daysToHarvest));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [AppShadows.card],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text('Upcoming Harvests',
                  style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${upcoming.length} ready',
                    style: AppTextStyles.body(
                      10,
                      weight: FontWeight.w700,
                      color: AppColors.success,
                    )),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...upcoming.take(4).map((crop) => _HarvestItem(crop: crop)),
        ],
      ),
    ).animate(delay: 400.ms).fadeIn();
  }
}

class _HarvestItem extends StatelessWidget {
  final CropModel crop;
  const _HarvestItem({required this.crop});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.parchment,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${crop.expectedHarvestDate.day}',
                  style: AppTextStyles.display(16, color: AppColors.forest),
                ),
                Text(
                  _monthAbbr(crop.expectedHarvestDate.month),
                  style: AppTextStyles.body(8,
                      weight: FontWeight.w700, color: AppColors.slateLight),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(crop.emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(crop.name,
                    style: AppTextStyles.body(
                      13,
                      weight: FontWeight.w700,
                      color: AppColors.forest,
                    )),
                Text(
                    '${crop.plotId.replaceAll('_', ' ').toUpperCase()} · ~${crop.estimatedYieldKg}kg expected',
                    style: AppTextStyles.body(10, color: AppColors.slateLight)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: crop.daysToHarvest <= 3
                  ? AppColors.amberPale
                  : AppColors.paleGreen,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              crop.daysToHarvest == 0 ? 'Today!' : '${crop.daysToHarvest}d',
              style: AppTextStyles.mono(
                size: 11,
                weight: FontWeight.w700,
                color:
                    crop.daysToHarvest <= 3 ? AppColors.amber : AppColors.leaf,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _monthAbbr(int m) {
    const months = [
      '',
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC'
    ];
    return months[m];
  }
}

// ── DESTINATION CARD ──────────────────────────────────

class _DestinationCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const data = [
      _DestItem('Consumed', 42.0, AppColors.leaf),
      _DestItem('Sold', 28.0, AppColors.amber),
      _DestItem('Donated', 18.0, AppColors.blue),
      _DestItem('Stored', 12.0, AppColors.mint),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [AppShadows.subtle],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Produce Destination',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text('This season', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 14),
          SizedBox(
            height: 100,
            child: PieChart(
              PieChartData(
                sections: data
                    .map((d) => PieChartSectionData(
                          value: d.pct,
                          color: d.color,
                          radius: 30,
                          showTitle: false,
                        ))
                    .toList(),
                centerSpaceRadius: 28,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...data.map((d) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: d.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                        child: Text(d.label,
                            style: AppTextStyles.body(10,
                                color: AppColors.slateMid))),
                    Text('${d.pct.toInt()}%',
                        style: AppTextStyles.mono(10, color: AppColors.forest)),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _DestItem {
  final String label;
  final double pct;
  final Color color;
  const _DestItem(this.label, this.pct, this.color);
}

// ── SEASON PROGRESS CARD ──────────────────────────────

class _SeasonProgressCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final stats = MockData.stats;
    final progress = stats.goalProgress;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [AppShadows.subtle],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Season Goal', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text('Jun 2024', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),

          // Big progress number
          Text(
            '${stats.totalHarvestKg}',
            style: AppTextStyles.display(28, color: AppColors.forest),
          ),
          Text('of ${stats.seasonGoalKg} kg',
              style: AppTextStyles.body(11, color: AppColors.slateLight)),

          const SizedBox(height: 12),

          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation(AppColors.leaf),
            ),
          ),
          const SizedBox(height: 6),
          Text('${(progress * 100).toInt()}% of goal reached',
              style: AppTextStyles.mono(10, color: AppColors.leaf)),

          const SizedBox(height: 14),

          _StatRow('🌱', 'Planted', '${stats.totalCrops} crops'),
          _StatRow('🌾', 'Harvests', '${stats.totalHarvestCount} events'),
          const _StatRow('🏆', 'Top Crop', 'Tomato'),
          const _StatRow('♻️', 'Waste Saved', '~3.2 kg'),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String emoji, label, value;
  const _StatRow(this.emoji, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 6),
          Text(label,
              style: AppTextStyles.body(11, color: AppColors.slateLight)),
          const Spacer(),
          Text(value,
              style: AppTextStyles.body(
                11,
                weight: FontWeight.w700,
                color: AppColors.forest,
              )),
        ],
      ),
    );
  }
}

// ── ACTIVITY FEED ────────────────────────────────────

class _ActivityFeed extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
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
              Text('Recent Activity',
                  style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              TextButton(onPressed: () {}, child: const Text('See All')),
            ],
          ),
          const SizedBox(height: 12),
          ...MockData.activities.take(5).map((a) => _ActivityItem(log: a)),
        ],
      ),
    ).animate(delay: 500.ms).fadeIn();
  }
}

class _ActivityItem extends StatelessWidget {
  final ActivityLog log;
  const _ActivityItem({required this.log});

  @override
  Widget build(BuildContext context) {
    final timeAgo = _timeAgo(log.performedAt);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: log.type.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(log.type.emoji, style: const TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.description,
                  style: AppTextStyles.body(
                    12,
                    weight: FontWeight.w500,
                    color: AppColors.slate,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(timeAgo,
                    style: AppTextStyles.body(11, color: AppColors.slateLight)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}';
  }
}
