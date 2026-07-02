import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/models.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.parchment,
      appBar: AppBar(
        title: const Text('Analytics'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Yield'),
            Tab(text: 'Resources'),
            Tab(text: 'Reports'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _OverviewTab(),
          _YieldTab(),
          _ResourcesTab(),
          _ReportsTab(),
        ],
      ),
    );
  }
}

// ── OVERVIEW TAB ──────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Big stat cards
          const Row(
            children: [
              Expanded(
                  child: _BigStat('48.6kg', 'Total Yield',
                      '↑18% vs last season', AppColors.leaf)),
              SizedBox(width: 12),
              Expanded(
                  child: _BigStat('₱2,840', 'Est. Value', '↑12% vs last season',
                      AppColors.amber)),
            ],
          ),
          const SizedBox(height: 20),

          Text('Crop Status Distribution',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
              boxShadow: [AppShadows.card],
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 36,
                      sections: _statusSections(),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _statusLegend(),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: 0.1),

          const SizedBox(height: 20),
          Text('Growth Rate Comparison',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Container(
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
                    _Legend(AppColors.red, 'Tomato'),
                    const SizedBox(width: 12),
                    const _Legend(AppColors.leaf, 'Basil'),
                    const SizedBox(width: 12),
                    _Legend(AppColors.blue, 'Lettuce'),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 180,
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
                                        color: AppColors.slateLight)))),
                        bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (v, _) => Text(
                                    'W${v.toInt() + 1}',
                                    style: AppTextStyles.body(9,
                                        color: AppColors.slateLight)))),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        _growthLine(
                            [8, 14, 22, 32, 42, 52, 60, 68], AppColors.red),
                        _growthLine(
                            [5, 10, 16, 22, 26, 29, 31, 32], AppColors.leaf),
                        _growthLine(
                            [4, 9, 14, 19, 24, 28, 29, 30], AppColors.blue),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.1),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  LineChartBarData _growthLine(List<double> data, Color color) =>
      LineChartBarData(
        spots: data
            .asMap()
            .entries
            .map((e) => FlSpot(e.key.toDouble(), e.value))
            .toList(),
        isCurved: true,
        color: color,
        barWidth: 2.5,
        dotData: const FlDotData(show: false),
      );

  List<PieChartSectionData> _statusSections() {
    final counts = <CropStatus, int>{};
    for (var c in MockData.crops) {
      counts[c.status] = (counts[c.status] ?? 0) + 1;
    }
    return counts.entries
        .map((e) => PieChartSectionData(
              value: e.value.toDouble(),
              color: e.key.color,
              radius: 24,
              showTitle: false,
            ))
        .toList();
  }

  List<Widget> _statusLegend() {
    final counts = <CropStatus, int>{};
    for (var c in MockData.crops) {
      counts[c.status] = (counts[c.status] ?? 0) + 1;
    }
    return counts.entries
        .map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                          color: e.key.color, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(e.key.label,
                          style: AppTextStyles.body(11,
                              color: AppColors.slateMid))),
                  Text('${e.value}',
                      style: AppTextStyles.mono(11, color: AppColors.forest)),
                ],
              ),
            ))
        .toList();
  }
}

class _BigStat extends StatelessWidget {
  final String value, label, trend;
  final Color color;
  const _BigStat(this.value, this.label, this.trend, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [color, color.withValues(alpha: 0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: AppTextStyles.display(24, color: Colors.white)),
          Text(label,
              style:
                  AppTextStyles.body(11, color: Colors.white.withValues(alpha: 0.8))),
          const SizedBox(height: 8),
          Text(trend,
              style: AppTextStyles.body(10,
                  weight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.9))),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend(this.color, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 5),
        Text(label, style: AppTextStyles.body(11, color: AppColors.slateMid)),
      ],
    );
  }
}

// ── YIELD TAB ─────────────────────────────────────────

class _YieldTab extends StatelessWidget {
  const _YieldTab();

  @override
  Widget build(BuildContext context) {
    final data = MockData.yieldByCrop;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Yield by Crop Type',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
              boxShadow: [AppShadows.card],
            ),
            child: SizedBox(
              height: 280,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 14,
                  barGroups: data
                      .asMap()
                      .entries
                      .map((e) => BarChartGroupData(
                            x: e.key,
                            barRods: [
                              BarChartRodData(
                                toY: e.value['kg'],
                                color: Color(e.value['color']),
                                width: 18,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ],
                          ))
                      .toList(),
                  gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (_) =>
                          FlLine(color: AppColors.border, strokeWidth: 1)),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            getTitlesWidget: (v, _) => Text('${v.toInt()}',
                                style: AppTextStyles.body(9,
                                    color: AppColors.slateLight)))),
                    bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, _) => Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(data[v.toInt()]['emoji'],
                                      style: const TextStyle(fontSize: 16)),
                                ))),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                ),
              ),
            ),
          ).animate().fadeIn(),
          const SizedBox(height: 20),
          Text('Top Performers', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          ...data.take(5).toList().asMap().entries.map((e) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: e.key == 0
                            ? AppColors.amberPale
                            : AppColors.parchment,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                          child: Text('${e.key + 1}',
                              style: AppTextStyles.body(12,
                                  weight: FontWeight.w800,
                                  color: e.key == 0
                                      ? AppColors.amber
                                      : AppColors.slateMid))),
                    ),
                    const SizedBox(width: 12),
                    Text(e.value['emoji'],
                        style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text(e.value['crop'],
                            style: AppTextStyles.body(13,
                                weight: FontWeight.w700,
                                color: AppColors.forest))),
                    Text('${e.value['kg']} kg',
                        style: AppTextStyles.mono(13,
                            weight: FontWeight.w700, color: AppColors.leaf)),
                  ],
                ),
              )),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ── RESOURCES TAB ─────────────────────────────────────

class _ResourcesTab extends StatelessWidget {
  const _ResourcesTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: _ResourceCard(
                      '💧', '342 L', 'Total Water Used', AppColors.blue)),
              const SizedBox(width: 12),
              Expanded(
                  child: _ResourceCard(
                      '🧪', '12', 'Fertilizer Applications', AppColors.purple)),
            ],
          ),
          const SizedBox(height: 20),
          Text('Weekly Water Usage',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
              boxShadow: [AppShadows.card],
            ),
            child: SizedBox(
              height: 200,
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
                            reservedSize: 32,
                            getTitlesWidget: (v, _) => Text('${v.toInt()}L',
                                style: AppTextStyles.body(9,
                                    color: AppColors.slateLight)))),
                    bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, _) => Text('W${v.toInt() + 1}',
                                style: AppTextStyles.body(9,
                                    color: AppColors.slateLight)))),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [38, 45, 42, 52, 48, 55, 51, 58]
                          .asMap()
                          .entries
                          .map((e) =>
                              FlSpot(e.key.toDouble(), e.value.toDouble()))
                          .toList(),
                      isCurved: true,
                      color: AppColors.blue,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                          show: true, color: AppColors.blue.withOpacity(0.1)),
                    ),
                  ],
                ),
              ),
            ),
          ).animate().fadeIn(),
          const SizedBox(height: 20),
          Text('Water Usage by Crop',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          ...MockData.crops.take(6).map((c) {
            final liters = (c.daysInGround * 0.8).clamp(2, 50);
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Text(c.emoji, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: Text(c.name,
                        style: AppTextStyles.body(12, weight: FontWeight.w600)),
                  ),
                  Expanded(
                    flex: 3,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (liters / 50).toDouble(),
                        minHeight: 6,
                        backgroundColor: AppColors.border,
                        valueColor:
                            const AlwaysStoppedAnimation(AppColors.blue),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${liters}L',
                      style: AppTextStyles.mono(11, color: AppColors.blue)),
                ],
              ),
            );
          }),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _ResourceCard extends StatelessWidget {
  final String emoji, value, label;
  final Color color;
  const _ResourceCard(this.emoji, this.value, this.label, this.color);

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
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10)),
            child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 16))),
          ),
          const SizedBox(height: 10),
          Text(value,
              style: AppTextStyles.display(20, color: AppColors.forest)),
          Text(label,
              style: AppTextStyles.body(10, color: AppColors.slateLight)),
        ],
      ),
    );
  }
}

// ── REPORTS TAB ───────────────────────────────────────

class _ReportsTab extends StatelessWidget {
  const _ReportsTab();

  @override
  Widget build(BuildContext context) {
    final reports = [
      (
        '📄',
        'Season Summary Report',
        'Complete overview of planting, growth, and yield'
      ),
      (
        '📈',
        'Yield Analysis',
        'Crop-by-crop performance comparison with trends'
      ),
      (
        '💧',
        'Resource Usage Report',
        'Water and fertilizer consumption metrics'
      ),
      (
        '🍽️',
        'Produce Destination Report',
        'Consumed, sold, donated, stored breakdown'
      ),
      (
        '📅',
        'Planting Calendar',
        'Recommended schedule based on past performance'
      ),
      ('🏆', 'Top Performers Report', 'Ranked list of best yielding crops'),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reports.length,
      itemBuilder: (_, i) {
        final (emoji, title, desc) = reports[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cream,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [AppShadows.subtle],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                    color: AppColors.paleGreen,
                    borderRadius: BorderRadius.circular(14)),
                child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 22))),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: AppTextStyles.body(13,
                            weight: FontWeight.w700, color: AppColors.forest)),
                    const SizedBox(height: 2),
                    Text(desc,
                        style:
                            AppTextStyles.body(10, color: AppColors.slateLight),
                        maxLines: 2),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.download_rounded, color: AppColors.leaf),
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Generating $title…'))),
              ),
            ],
          ),
        )
            .animate(delay: Duration(milliseconds: 60 * i))
            .fadeIn()
            .slideX(begin: 0.05);
      },
    );
  }
}
