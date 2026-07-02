import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/models.dart';

class ConsumerScanResultScreen extends StatelessWidget {
  final String targetType; // 'meal' | 'batch'
  final String targetId;

  const ConsumerScanResultScreen({
    required this.targetType,
    required this.targetId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (targetType == 'meal') {
      return _MealResultView(meal: MockData.sampleMeal, batch: MockData.sampleBatch);
    }
    return _BatchResultView(batch: MockData.sampleBatch);
  }
}

// ---------------------------------------------------------------------------
// Meal result — matches the QR mockup from the spec
// ---------------------------------------------------------------------------

class _MealResultView extends StatelessWidget {
  final Meal meal;
  final CropBatch batch;
  const _MealResultView({required this.meal, required this.batch});

  @override
  Widget build(BuildContext context) {
    final n = meal.nutrition;
    final contains = meal.allergens.where((a) => a.contains).toList();
    final mayContain = meal.allergens.where((a) => a.mayContain).toList();

    return Scaffold(
      backgroundColor: AppColors.parchment,
      appBar: AppBar(title: const Text('GreenTrack Verified')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _VerifiedBanner(),
          const SizedBox(height: AppSpacing.md),
          _SectionCard(
            title: 'Meal',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(meal.name, style: AppTextStyles.h1),
                Text('Prepared by ${meal.restaurantName}',
                    style: AppTextStyles.bodyMuted),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _SectionCard(
            title: 'Nutrition',
            child: Column(
              children: [
                _NutrRow('Calories', '${n.calories.toStringAsFixed(0)} kcal'),
                _NutrRow('Protein', '${n.proteinG.toStringAsFixed(1)} g'),
                _NutrRow('Carbohydrates', '${n.carbsG.toStringAsFixed(1)} g'),
                _NutrRow('Fat', '${n.fatG.toStringAsFixed(1)} g'),
                _NutrRow('Fiber', '${n.fiberG.toStringAsFixed(1)} g'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _SectionCard(
            title: 'Allergens',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (contains.isEmpty && mayContain.isEmpty)
                  Text('No allergens declared', style: AppTextStyles.bodyMuted),
                ...contains.map((a) => _AllergenRow(
                    label: a.allergenId.label, confirmed: true)),
                ...mayContain.map((a) => _AllergenRow(
                    label: a.allergenId.label, confirmed: false)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _SectionCard(
            title: 'Ingredients',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: meal.ingredients
                  .map((i) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.eco, size: 14, color: AppColors.leaf),
                            const SizedBox(width: 6),
                            Text(i.cropName, style: AppTextStyles.body),
                            const Spacer(),
                            Text('${i.quantityGrams.toStringAsFixed(0)} g',
                                style: AppTextStyles.bodyMuted),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _SectionCard(
            title: 'Farm Source',
            child: _FarmTraceRow(batch: batch),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Batch result — traceability timeline for grocery shoppers
// ---------------------------------------------------------------------------

class _BatchResultView extends StatelessWidget {
  final CropBatch batch;
  const _BatchResultView({required this.batch});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.parchment,
      appBar: AppBar(title: const Text('Crop Traceability')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _VerifiedBanner(),
          const SizedBox(height: AppSpacing.md),
          _SectionCard(
            title: 'Product',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(batch.cropName, style: AppTextStyles.h1),
                if (batch.organicCertified)
                  Row(
                    children: [
                      const Icon(Icons.verified, size: 14, color: AppColors.leaf),
                      const SizedBox(width: 4),
                      Text('Organic Certified', style: AppTextStyles.bodyMuted),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _SectionCard(
            title: 'Journey',
            child: _TraceabilityTimeline(batch: batch),
          ),
          const SizedBox(height: AppSpacing.sm),
          _SectionCard(
            title: 'Farm Details',
            child: _FarmTraceRow(batch: batch),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared sub-widgets
// ---------------------------------------------------------------------------

class _VerifiedBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.leaf.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_outlined, color: AppColors.leaf),
          const SizedBox(width: AppSpacing.sm),
          Text('GreenTrack Verified', style: AppTextStyles.body.copyWith(
            color: AppColors.leaf, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(), style: AppTextStyles.label),
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );
  }
}

class _NutrRow extends StatelessWidget {
  final String label;
  final String value;
  const _NutrRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.body),
          Text(value,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _AllergenRow extends StatelessWidget {
  final String label;
  final bool confirmed;
  const _AllergenRow({required this.label, required this.confirmed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            confirmed ? Icons.check_circle : Icons.info_outline,
            size: 16,
            color: confirmed ? AppColors.error : AppColors.amber,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '${confirmed ? "Contains" : "May contain"}: $label',
              style: AppTextStyles.body,
            ),
          ),
        ],
      ),
    );
  }
}

class _TraceabilityTimeline extends StatelessWidget {
  final CropBatch batch;
  const _TraceabilityTimeline({required this.batch});

  @override
  Widget build(BuildContext context) {
    final events = <_TimelineEvent>[
      _TimelineEvent(
          icon: Icons.calendar_today,
          label: 'Planned',
          date: batch.plannedDate,
          color: AppColors.textSecondary),
      if (batch.plantedDate != null)
        _TimelineEvent(
            icon: Icons.eco,
            label: 'Planted',
            date: batch.plantedDate!,
            color: AppColors.leaf),
      if (batch.harvestedAt != null)
        _TimelineEvent(
            icon: Icons.agriculture,
            label: 'Harvested · ${batch.verifiedWeightKg ?? "??"} kg',
            date: batch.harvestedAt!,
            color: AppColors.amber),
    ];

    return Column(
      children: events
          .asMap()
          .entries
          .map((e) => _TimelineTile(event: e.value, last: e.key == events.length - 1))
          .toList(),
    );
  }
}

class _TimelineEvent {
  final IconData icon;
  final String label;
  final DateTime date;
  final Color color;
  const _TimelineEvent(
      {required this.icon,
      required this.label,
      required this.date,
      required this.color});
}

class _TimelineTile extends StatelessWidget {
  final _TimelineEvent event;
  final bool last;
  const _TimelineTile({required this.event, required this.last});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: event.color.withValues(alpha: 0.15),
              child: Icon(event.icon, size: 14, color: event.color),
            ),
            if (!last)
              Container(
                  width: 2, height: 28, color: AppColors.border),
          ],
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 6, bottom: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.label, style: AppTextStyles.body),
                Text(
                  '${event.date.day}/${event.date.month}/${event.date.year}',
                  style: AppTextStyles.bodyMuted,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FarmTraceRow extends StatelessWidget {
  final CropBatch batch;
  const _FarmTraceRow({required this.batch});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.place, size: 16, color: AppColors.leaf),
            const SizedBox(width: 6),
            Text(batch.plotName ?? 'Plot', style: AppTextStyles.body),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.eco, size: 16, color: AppColors.leaf),
            const SizedBox(width: 6),
            Text(batch.farmingMethod.name, style: AppTextStyles.body),
          ],
        ),
        if (batch.harvestWeatherConditions != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.wb_sunny_outlined, size: 16, color: AppColors.amber),
              const SizedBox(width: 6),
              Text(batch.harvestWeatherConditions!, style: AppTextStyles.body),
            ],
          ),
        ],
      ],
    );
  }
}
