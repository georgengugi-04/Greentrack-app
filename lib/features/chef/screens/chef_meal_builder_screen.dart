import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/models.dart';

class ChefMealBuilderScreen extends StatefulWidget {
  const ChefMealBuilderScreen({super.key});

  @override
  State<ChefMealBuilderScreen> createState() => _ChefMealBuilderScreenState();
}

class _ChefMealBuilderScreenState extends State<ChefMealBuilderScreen> {
  int _step = 0;
  final List<String> _steps = ['Details', 'Ingredients', 'Allergens', 'Review'];

  String _mealName = '';
  final Map<String, double> _selectedIngredients = {};
  final Map<AllergenType, _AllergenState> _allergens = {
    for (final a in AllergenType.values)
      if (a != AllergenType.none) a: _AllergenState.none,
    AllergenType.none: _AllergenState.none,
  };
  String _otherAllergen = '';

  MealNutritionSnapshot? get _computedNutrition {
    if (_selectedIngredients.isEmpty) return null;
    final ingredients = _selectedIngredients.entries
        .map((e) => MealIngredient(
            cropBatchId: 'batch_001', cropName: e.key, quantityGrams: e.value))
        .toList();
    return MealNutritionSnapshot.calculate(
        ingredients, MockData.nutritionReference);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Build Meal')),
      body: Column(
        children: [
          _StepHeader(step: _step, steps: _steps),
          Expanded(
            child: IndexedStack(
              index: _step,
              children: [
                _DetailsStep(
                  mealName: _mealName,
                  onChanged: (v) => setState(() => _mealName = v),
                ),
                _IngredientsStep(
                  selected: _selectedIngredients,
                  nutrition: _computedNutrition,
                  onAdd: (crop, qty) =>
                      setState(() => _selectedIngredients[crop] = qty),
                  onRemove: (crop) =>
                      setState(() => _selectedIngredients.remove(crop)),
                ),
                _AllergensStep(
                  allergens: _allergens,
                  other: _otherAllergen,
                  onAllergenChanged: (type, state) =>
                      setState(() => _allergens[type] = state),
                  onOtherChanged: (v) => setState(() => _otherAllergen = v),
                ),
                _ReviewStep(
                  mealName: _mealName,
                  ingredients: _selectedIngredients,
                  nutrition: _computedNutrition,
                  allergens: _allergens,
                  other: _otherAllergen,
                ),
              ],
            ),
          ),
          _NavBar(
            step: _step,
            total: _steps.length,
            onBack: () => setState(() => _step--),
            onNext: () {
              if (_step == _steps.length - 1) {
                Navigator.pop(context);
              } else {
                setState(() => _step++);
              }
            },
          ),
        ],
      ),
    );
  }
}

enum _AllergenState { none, contains, mayContain }

// ── Step header ───────────────────────────────────────────────────────────────

class _StepHeader extends StatelessWidget {
  final int step;
  final List<String> steps;
  const _StepHeader({required this.step, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(
        children: steps.asMap().entries.map((e) {
          final active = e.key == step;
          final done = e.key < step;
          return Expanded(
            child: Row(children: [
              CircleAvatar(
                radius: 13,
                backgroundColor: done
                    ? AppColors.chefAccent
                    : active
                        ? AppColors.forest
                        : AppColors.border,
                child: done
                    ? const Icon(Icons.check, size: 12, color: Colors.white)
                    : Text('${e.key + 1}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(e.value,
                    style: AppTextStyles.label.copyWith(
                        color: active
                            ? AppColors.forest
                            : AppColors.textSecondary),
                    overflow: TextOverflow.ellipsis),
              ),
              if (e.key < steps.length - 1)
                Expanded(
                    child: Container(height: 1, color: AppColors.border)),
            ]),
          );
        }).toList(),
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  final int step, total;
  final VoidCallback onBack, onNext;
  const _NavBar(
      {required this.step,
      required this.total,
      required this.onBack,
      required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(children: [
        if (step > 0) ...[
          Expanded(child: OutlinedButton(onPressed: onBack, child: const Text('Back'))),
          const SizedBox(width: AppSpacing.sm),
        ],
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.chefAccent),
            onPressed: onNext,
            child: Text(step == total - 1 ? 'Save Meal' : 'Next'),
          ),
        ),
      ]),
    );
  }
}

// ── Details ───────────────────────────────────────────────────────────────────

class _DetailsStep extends StatelessWidget {
  final String mealName;
  final ValueChanged<String> onChanged;
  const _DetailsStep({required this.mealName, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(AppSpacing.md), children: [
      Text('Meal Details', style: AppTextStyles.h2),
      const SizedBox(height: AppSpacing.md),
      TextFormField(
        initialValue: mealName,
        decoration: const InputDecoration(labelText: 'Meal Name'),
        onChanged: onChanged,
      ),
      const SizedBox(height: AppSpacing.sm),
      TextFormField(
          decoration: const InputDecoration(
              labelText: 'Description (optional)',
              hintText: 'Short description visible to diners')),
    ]);
  }
}

// ── Ingredients ───────────────────────────────────────────────────────────────

class _IngredientsStep extends StatelessWidget {
  final Map<String, double> selected;
  final MealNutritionSnapshot? nutrition;
  final void Function(String crop, double qty) onAdd;
  final void Function(String crop) onRemove;

  const _IngredientsStep({
    required this.selected,
    required this.nutrition,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final available = MockData.nutritionReference.keys.toList();
    return ListView(padding: const EdgeInsets.all(AppSpacing.md), children: [
      Text('Select Ingredients', style: AppTextStyles.h2),
      Text('From verified batches in your kitchen',
          style: AppTextStyles.bodyMuted),
      const SizedBox(height: AppSpacing.md),
      ...available.map((crop) {
        final qty = selected[crop];
        return ListTile(
          tileColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              side: BorderSide(
                  color: qty != null ? AppColors.chefAccent : AppColors.border)),
          contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: 4),
          leading:
              Icon(Icons.eco, color: qty != null ? AppColors.chefAccent : AppColors.textSecondary),
          title: Text(crop, style: AppTextStyles.body),
          subtitle: qty != null ? Text('${qty.toStringAsFixed(0)} g') : null,
          trailing: qty != null
              ? Row(mainAxisSize: MainAxisSize.min, children: [
                  IconButton(
                      icon: const Icon(Icons.remove_circle_outline, size: 20),
                      onPressed: () => onRemove(crop)),
                  const SizedBox(width: 4),
                  IconButton(
                      icon: const Icon(Icons.add_circle_outline, size: 20),
                      onPressed: () => onAdd(crop, qty + 25)),
                ])
              : TextButton(
                  child: const Text('Add'),
                  onPressed: () => onAdd(crop, 80)),
        );
      }),
      if (nutrition != null) ...[
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
<<<<<<< HEAD
              color: AppColors.chefAccent.withValues(alpha: 0.08),
=======
              color: AppColors.chefAccent.withOpacity(0.08),
>>>>>>> 493c832d1fc8dc6ffa0d63c5c9a92f89984743ca
              borderRadius: BorderRadius.circular(AppRadius.md)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Calculated Nutrition', style: AppTextStyles.label),
            const SizedBox(height: 6),
            Text(
              '${nutrition!.calories.toStringAsFixed(0)} kcal · '
              '${nutrition!.proteinG.toStringAsFixed(1)}g protein · '
              '${nutrition!.carbsG.toStringAsFixed(1)}g carbs · '
              '${nutrition!.fatG.toStringAsFixed(1)}g fat · '
              '${nutrition!.fiberG.toStringAsFixed(1)}g fiber',
              style: AppTextStyles.body,
            ),
          ]),
        ),
      ],
    ]);
  }
}

// ── Allergens ─────────────────────────────────────────────────────────────────

class _AllergensStep extends StatelessWidget {
  final Map<AllergenType, _AllergenState> allergens;
  final String other;
  final void Function(AllergenType, _AllergenState) onAllergenChanged;
  final ValueChanged<String> onOtherChanged;

  const _AllergensStep({
    required this.allergens,
    required this.other,
    required this.onAllergenChanged,
    required this.onOtherChanged,
  });

  @override
  Widget build(BuildContext context) {
    final types = AllergenType.values.where((a) => a != AllergenType.none).toList();

    return ListView(padding: const EdgeInsets.all(AppSpacing.md), children: [
      Text('Confirm Allergens', style: AppTextStyles.h2),
      Text('Select status for each of the 14 standard allergens',
          style: AppTextStyles.bodyMuted),
      const SizedBox(height: AppSpacing.sm),
      // None checkbox
      CheckboxListTile(
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm)),
        value: allergens[AllergenType.none] == _AllergenState.contains,
        title: const Text('None'),
        onChanged: (v) => onAllergenChanged(
            AllergenType.none,
            v! ? _AllergenState.contains : _AllergenState.none),
      ),
      const Divider(),
      ...types.map((a) => _AllergenRow(
            label: a.label,
            state: allergens[a]!,
            onChanged: (s) => onAllergenChanged(a, s),
          )),
      const SizedBox(height: AppSpacing.md),
      Text('Other allergens (optional)', style: AppTextStyles.label),
      const SizedBox(height: 6),
      TextFormField(
        initialValue: other,
        onChanged: onOtherChanged,
        decoration: const InputDecoration(
            hintText: 'e.g. Pine nuts, Kiwi...'),
      ),
    ]);
  }
}

class _AllergenRow extends StatelessWidget {
  final String label;
  final _AllergenState state;
  final ValueChanged<_AllergenState> onChanged;
  const _AllergenRow(
      {required this.label, required this.state, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 6),
        decoration: BoxDecoration(
          color: state != _AllergenState.none
<<<<<<< HEAD
              ? AppColors.error.withValues(alpha: 0.05)
=======
              ? AppColors.error.withOpacity(0.05)
>>>>>>> 493c832d1fc8dc6ffa0d63c5c9a92f89984743ca
              : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(child: Text(label, style: AppTextStyles.body)),
            _StateChip(
              label: 'Contains',
              active: state == _AllergenState.contains,
              color: AppColors.error,
              onTap: () => onChanged(state == _AllergenState.contains
                  ? _AllergenState.none
                  : _AllergenState.contains),
            ),
            const SizedBox(width: 6),
            _StateChip(
              label: 'May contain',
              active: state == _AllergenState.mayContain,
              color: AppColors.amber,
              onTap: () => onChanged(state == _AllergenState.mayContain
                  ? _AllergenState.none
                  : _AllergenState.mayContain),
            ),
          ],
        ),
      ),
    );
  }
}

class _StateChip extends StatelessWidget {
  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;
  const _StateChip(
      {required this.label,
      required this.active,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
<<<<<<< HEAD
          color: active ? color.withValues(alpha: 0.15) : Colors.transparent,
=======
          color: active ? color.withOpacity(0.15) : Colors.transparent,
>>>>>>> 493c832d1fc8dc6ffa0d63c5c9a92f89984743ca
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? color : AppColors.border),
        ),
        child: Text(label,
            style: AppTextStyles.label.copyWith(
                color: active ? color : AppColors.textSecondary)),
      ),
    );
  }
}

// ── Review ────────────────────────────────────────────────────────────────────

class _ReviewStep extends StatelessWidget {
  final String mealName;
  final Map<String, double> ingredients;
  final MealNutritionSnapshot? nutrition;
  final Map<AllergenType, _AllergenState> allergens;
  final String other;

  const _ReviewStep({
    required this.mealName,
    required this.ingredients,
    required this.nutrition,
    required this.allergens,
    required this.other,
  });

  @override
  Widget build(BuildContext context) {
    final confirmed = allergens.entries
        .where((e) => e.value == _AllergenState.contains)
        .map((e) => e.key.label)
        .toList();
    final mayContain = allergens.entries
        .where((e) => e.value == _AllergenState.mayContain)
        .map((e) => e.key.label)
        .toList();

    return ListView(padding: const EdgeInsets.all(AppSpacing.md), children: [
      Text('Review Meal', style: AppTextStyles.h2),
      const SizedBox(height: AppSpacing.sm),
      Text(mealName.isEmpty ? '(Unnamed)' : mealName, style: AppTextStyles.h1),
      const SizedBox(height: AppSpacing.md),
      Text('INGREDIENTS', style: AppTextStyles.label),
      ...ingredients.entries.map((e) => Text(
          '• ${e.key} — ${e.value.toStringAsFixed(0)} g',
          style: AppTextStyles.body)),
      if (nutrition != null) ...[
        const SizedBox(height: AppSpacing.md),
        Text('NUTRITION', style: AppTextStyles.label),
        Text(
            '${nutrition!.calories.toStringAsFixed(0)} kcal · '
            '${nutrition!.proteinG.toStringAsFixed(1)}g protein',
            style: AppTextStyles.body),
      ],
      const SizedBox(height: AppSpacing.md),
      Text('ALLERGENS', style: AppTextStyles.label),
      if (confirmed.isNotEmpty)
        Text('Contains: ${confirmed.join(", ")}',
            style: AppTextStyles.body.copyWith(color: AppColors.error)),
      if (mayContain.isNotEmpty)
        Text('May contain: ${mayContain.join(", ")}',
            style: AppTextStyles.body.copyWith(color: AppColors.amber)),
      if (other.isNotEmpty)
        Text('Other: $other', style: AppTextStyles.bodyMuted),
      if (confirmed.isEmpty && mayContain.isEmpty)
        Text('No allergens declared', style: AppTextStyles.bodyMuted),
    ]);
  }
}
