import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/models.dart';

class HarvestScreen extends StatefulWidget {
  const HarvestScreen({super.key});

  @override
  State<HarvestScreen> createState() => _HarvestScreenState();
}

class _HarvestScreenState extends State<HarvestScreen> {
  HarvestDestination? _filterDestination;

  @override
  Widget build(BuildContext context) {
    final harvests = MockData.harvests
        .where((h) =>
            _filterDestination == null || h.destination == _filterDestination)
        .toList()
      ..sort((a, b) => b.harvestDate.compareTo(a.harvestDate));

    final totalKg =
        MockData.harvests.fold<double>(0, (s, h) => s + h.quantityKg);
    final totalValue =
        MockData.harvests.fold<double>(0, (s, h) => s + h.estimatedValue);

    return Scaffold(
      backgroundColor: AppColors.parchment,
      appBar: AppBar(title: const Text('Harvest Log')),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Summary cards
                  Row(
                    children: [
                      Expanded(
                          child: _SummaryCard(
                        emoji: '⚖️',
                        value: '${totalKg.toStringAsFixed(1)}kg',
                        label: 'Total Harvest',
                        color: AppColors.leaf,
                      )),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _SummaryCard(
                        emoji: '🌾',
                        value: '${MockData.harvests.length}',
                        label: 'Harvest Events',
                        color: AppColors.amber,
                      )),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                          child: _SummaryCard(
                        emoji: '🏷️',
                        value: '₱${totalValue.toStringAsFixed(0)}',
                        label: 'Est. Value',
                        color: AppColors.blue,
                      )),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _SummaryCard(
                        emoji: '♻️',
                        value: '3.2kg',
                        label: 'Waste Saved',
                        color: AppColors.purple,
                      )),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Destination filter chips
                  SizedBox(
                    height: 36,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _FilterChip(
                          label: 'All',
                          emoji: '📋',
                          isSelected: _filterDestination == null,
                          onTap: () =>
                              setState(() => _filterDestination = null),
                        ),
                        ...HarvestDestination.values.map((d) => _FilterChip(
                              label: d.label.split(' ')[0],
                              emoji: d.emoji,
                              isSelected: _filterDestination == d,
                              onTap: () =>
                                  setState(() => _filterDestination = d),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final h = harvests[i];
                  final crop = MockData.crops.firstWhere(
                      (c) => c.id == h.cropId,
                      orElse: () => MockData.crops.first);
                  return _HarvestRecordCard(harvest: h, crop: crop, index: i);
                },
                childCount: harvests.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/harvest/log'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Log Harvest'),
        backgroundColor: AppColors.amber,
        foregroundColor: AppColors.forest,
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String emoji, value, label;
  final Color color;
  const _SummaryCard(
      {required this.emoji,
      required this.value,
      required this.label,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [AppShadows.subtle],
      ),
      child: Row(
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
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: AppTextStyles.display(16, color: AppColors.forest)),
                Text(label,
                    style: AppTextStyles.body(9, color: AppColors.slateLight)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label, emoji;
  final bool isSelected;
  final VoidCallback onTap;
  const _FilterChip(
      {required this.label,
      required this.emoji,
      required this.isSelected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.forest : AppColors.cream,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isSelected ? AppColors.forest : AppColors.border),
        ),
        child: Center(
          child: Text('$emoji $label',
              style: AppTextStyles.body(11,
                  weight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.slateMid)),
        ),
      ),
    );
  }
}

class _HarvestRecordCard extends StatelessWidget {
  final HarvestRecord harvest;
  final CropModel crop;
  final int index;
  const _HarvestRecordCard(
      {required this.harvest, required this.crop, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
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
              color: harvest.destination.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
                child: Text(crop.emoji, style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(crop.name,
                          style: AppTextStyles.body(13,
                              weight: FontWeight.w700,
                              color: AppColors.forest)),
                    ),
                    Text('${harvest.quantityKg.toStringAsFixed(1)} kg',
                        style: AppTextStyles.mono(13,
                            weight: FontWeight.w700, color: AppColors.leaf)),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                        '${harvest.destination.emoji} ${harvest.destination.label}',
                        style: AppTextStyles.body(10,
                            color: AppColors.slateLight)),
                    const Text(' · ',
                        style: TextStyle(color: AppColors.slateLight)),
                    Text(
                        '${harvest.harvestDate.day}/${harvest.harvestDate.month}/${harvest.harvestDate.year}',
                        style: AppTextStyles.body(10,
                            color: AppColors.slateLight)),
                  ],
                ),
                if (harvest.notes != null) ...[
                  const SizedBox(height: 4),
                  Text(harvest.notes!,
                      style: AppTextStyles.body(10, color: AppColors.slateMid),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ],
            ),
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: 50 * index))
        .fadeIn()
        .slideX(begin: 0.05);
  }
}
