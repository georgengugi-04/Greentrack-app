import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/session/session_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/models.dart';

class ConsumerDashboardScreen extends ConsumerWidget {
  const ConsumerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider);
    final meal = MockData.sampleMeal;
    final batch = MockData.sampleBatch;

    return Scaffold(
      appBar: AppBar(
        title: Text('Hi, ${user?.name ?? 'there'}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(sessionProvider.notifier).signOut();
              Navigator.of(context).popUntil((r) => r.isFirst);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          GestureDetector(
            onTap: () {},
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                color: AppColors.consumerAccent,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code_scanner, color: Colors.white, size: 48),
                  SizedBox(height: AppSpacing.sm),
                  Text('Scan a QR code',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600)),
                  Text('Product packaging or restaurant menu',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Recent Scans', style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.sm),
          _MealTraceCard(meal: meal),
          const SizedBox(height: AppSpacing.sm),
          _BatchTraceCard(batch: batch),
        ],
      ),
    );
  }
}

class _MealTraceCard extends StatelessWidget {
  final Meal meal;
  const _MealTraceCard({required this.meal});

  @override
  Widget build(BuildContext context) {
    final n = meal.nutrition;
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
          Row(
            children: [
              const Icon(Icons.verified, color: AppColors.leaf, size: 18),
              const SizedBox(width: 6),
              Text('GreenTrack Verified', style: AppTextStyles.label),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(meal.name, style: AppTextStyles.h2),
          Text('Prepared by ${meal.restaurantName}', style: AppTextStyles.bodyMuted),
          const Divider(height: AppSpacing.lg),
          Text('Nutrition', style: AppTextStyles.label),
          const SizedBox(height: 4),
          Text(
            'Calories: ${n.calories.toStringAsFixed(0)} kcal   '
            'Protein: ${n.proteinG.toStringAsFixed(1)} g\n'
            'Carbs: ${n.carbsG.toStringAsFixed(1)} g   '
            'Fat: ${n.fatG.toStringAsFixed(1)} g   '
            'Fiber: ${n.fiberG.toStringAsFixed(1)} g',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text('Allergens', style: AppTextStyles.label),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: meal.allergens
                .map((a) => Chip(
                      label: Text(
                        '${a.contains ? "✓ Contains" : "May contain"}: ${a.allergenId.label}',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text('Ingredients', style: AppTextStyles.label),
          Text(
            meal.ingredients.map((i) => i.cropName).join(', '),
            style: AppTextStyles.body,
          ),
        ],
      ),
    );
  }
}

class _BatchTraceCard extends StatelessWidget {
  final CropBatch batch;
  const _BatchTraceCard({required this.batch});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${batch.cropName} · ${batch.plotName}', style: AppTextStyles.h2),
          const SizedBox(height: 4),
          Text(
            'Harvested ${batch.harvestedAt != null ? batch.harvestedAt.toString().split(' ').first : '—'} '
            '· ${batch.organicCertified ? "Organic certified" : "Conventional"}',
            style: AppTextStyles.bodyMuted,
          ),
        ],
      ),
    );
  }
}
