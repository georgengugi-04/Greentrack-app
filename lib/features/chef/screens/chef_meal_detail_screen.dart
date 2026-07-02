import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/models.dart';

class ChefMealDetailScreen extends StatelessWidget {
  final String mealId;
  const ChefMealDetailScreen({required this.mealId, super.key});

  @override
  Widget build(BuildContext context) {
    final meal = MockData.sampleMeal;
    final n = meal.nutrition;
    return Scaffold(
      appBar: AppBar(title: Text(meal.name)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Center(child: Column(children: [
            QrImageView(data: 'greentrack://meal/${meal.id}', version: QrVersions.auto, size: 180, backgroundColor: Colors.white),
            const SizedBox(height: AppSpacing.xs),
            Text('Meal QR · ${meal.id}', style: AppTextStyles.label),
          ])),
          const SizedBox(height: AppSpacing.lg),
          _Card(title: 'NUTRITION', child: Column(children: [
            _NRow('Calories', '${n.calories.toStringAsFixed(0)} kcal'),
            _NRow('Protein', '${n.proteinG.toStringAsFixed(1)} g'),
            _NRow('Carbohydrates', '${n.carbsG.toStringAsFixed(1)} g'),
            _NRow('Fat', '${n.fatG.toStringAsFixed(1)} g'),
            _NRow('Fiber', '${n.fiberG.toStringAsFixed(1)} g'),
          ])),
          const SizedBox(height: AppSpacing.sm),
          _Card(title: 'ALLERGENS', child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: meal.allergens.map((a) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(children: [
                Icon(a.contains ? Icons.check_circle : Icons.info_outline, size: 16, color: a.contains ? AppColors.error : AppColors.amber),
                const SizedBox(width: 6),
                Text('${a.contains ? "Contains" : "May contain"}: ${a.allergenId.label}', style: AppTextStyles.body),
              ]),
            )).toList(),
          )),
          const SizedBox(height: AppSpacing.sm),
          _Card(title: 'INGREDIENTS', child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: meal.ingredients.map((i) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(children: [
                const Icon(Icons.eco, size: 14, color: AppColors.leaf),
                const SizedBox(width: 6),
                Text(i.cropName, style: AppTextStyles.body),
                const Spacer(),
                Text('${i.quantityGrams.toStringAsFixed(0)} g', style: AppTextStyles.bodyMuted),
              ]),
            )).toList(),
          )),
        ],
      ),
    );
  }
}

class _NRow extends StatelessWidget {
  final String label, value;
  const _NRow(this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: AppTextStyles.body),
      Text(value, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
    ]),
  );
}

class _Card extends StatelessWidget {
  final String title;
  final Widget child;
  const _Card({required this.title, required this.child});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSpacing.md),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.md), border: Border.all(color: AppColors.border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: AppTextStyles.label),
      const SizedBox(height: AppSpacing.sm),
      child,
    ]),
  );
}
