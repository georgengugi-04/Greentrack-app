import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/models.dart';

class AddCropScreen extends StatefulWidget {
  const AddCropScreen({super.key});

  @override
  State<AddCropScreen> createState() => _AddCropScreenState();
}

class _AddCropScreenState extends State<AddCropScreen> {
  final PageController _pageController = PageController();
  int _step = 0;

  // Form state
  final _nameCtrl = TextEditingController();
  final _varietyCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  CropCategory _category = CropCategory.vegetable;
  String _selectedEmoji = '🌱';
  String? _selectedPlotId;
  DateTime _plantingDate = DateTime.now();
  DateTime _harvestDate = DateTime.now().add(const Duration(days: 60));
  WateringFrequency _watering = WateringFrequency.everyTwoDays;

  final _emojis = [
    '🍅',
    '🥬',
    '🥒',
    '🫑',
    '🌽',
    '🧅',
    '🌱',
    '🍆',
    '🥕',
    '🌸',
    '🫘',
    '🥦',
    '🍓',
    '🫐',
    '🍇',
    '🌶️',
    '🥔',
    '🧄',
    '🍌',
    '🥑'
  ];

  final _steps = ['Basics', 'Location', 'Schedule', 'Review'];

  void _next() {
    if (_step < _steps.length - 1) {
      setState(() => _step++);
      _pageController.nextPage(duration: 300.ms, curve: Curves.easeInOut);
    } else {
      _submit();
    }
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
      _pageController.previousPage(duration: 300.ms, curve: Curves.easeInOut);
    } else {
      context.pop();
    }
  }

  void _submit() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                    color: AppColors.paleGreen, shape: BoxShape.circle),
                child: const Center(
                    child: Text('🌱', style: TextStyle(fontSize: 36))),
              ).animate().scale(curve: Curves.elasticOut, duration: 500.ms),
              const SizedBox(height: 20),
              Text('Crop Added!',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                  '${_nameCtrl.text.isEmpty ? "Your crop" : _nameCtrl.text} has been planted in your garden.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.pop();
                  },
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.parchment,
      appBar: AppBar(
        title: const Text('Add New Crop'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: _back,
        ),
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _BasicsStep(
                  nameCtrl: _nameCtrl,
                  varietyCtrl: _varietyCtrl,
                  qtyCtrl: _qtyCtrl,
                  category: _category,
                  onCategoryChanged: (c) => setState(() => _category = c),
                  emoji: _selectedEmoji,
                  emojis: _emojis,
                  onEmojiChanged: (e) => setState(() => _selectedEmoji = e),
                ),
                _LocationStep(
                  selectedPlotId: _selectedPlotId,
                  onPlotSelected: (id) => setState(() => _selectedPlotId = id),
                ),
                _ScheduleStep(
                  plantingDate: _plantingDate,
                  harvestDate: _harvestDate,
                  watering: _watering,
                  onPlantingChanged: (d) => setState(() => _plantingDate = d),
                  onHarvestChanged: (d) => setState(() => _harvestDate = d),
                  onWateringChanged: (w) => setState(() => _watering = w),
                  notesCtrl: _notesCtrl,
                ),
                _ReviewStep(
                  emoji: _selectedEmoji,
                  name:
                      _nameCtrl.text.isEmpty ? 'Unnamed Crop' : _nameCtrl.text,
                  variety: _varietyCtrl.text,
                  category: _category,
                  plotId: _selectedPlotId,
                  plantingDate: _plantingDate,
                  harvestDate: _harvestDate,
                  watering: _watering,
                  qty: _qtyCtrl.text,
                ),
              ],
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Row(
        children: List.generate(_steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            final stepIdx = i ~/ 2;
            return Expanded(
              child: Container(
                height: 2,
                color: stepIdx < _step ? AppColors.leaf : AppColors.border,
              ),
            );
          }
          final idx = i ~/ 2;
          final isActive = idx == _step;
          final isDone = idx < _step;
          return Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color:
                      isDone || isActive ? AppColors.forest : AppColors.border,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isDone
                      ? const Icon(Icons.check, color: Colors.white, size: 14)
                      : Text('${idx + 1}',
                          style: AppTextStyles.body(11,
                              weight: FontWeight.w700,
                              color: isActive
                                  ? Colors.white
                                  : AppColors.slateLight)),
                ),
              ),
              const SizedBox(height: 4),
              Text(_steps[idx],
                  style: AppTextStyles.body(9,
                      weight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color:
                          isActive ? AppColors.forest : AppColors.slateLight)),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      decoration: BoxDecoration(
        color: AppColors.cream,
        boxShadow: [
          BoxShadow(
              color: AppColors.slate.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, -4))
        ],
      ),
      child: Row(
        children: [
          if (_step > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _back,
                child: const Text('Back'),
              ),
            ),
          if (_step > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _next,
              child: Text(
                  _step == _steps.length - 1 ? '🌱 Plant Crop' : 'Continue →'),
            ),
          ),
        ],
      ),
    );
  }
}

// ── STEP 1: BASICS ───────────────────────────────────

class _BasicsStep extends StatelessWidget {
  final TextEditingController nameCtrl, varietyCtrl, qtyCtrl;
  final CropCategory category;
  final ValueChanged<CropCategory> onCategoryChanged;
  final String emoji;
  final List<String> emojis;
  final ValueChanged<String> onEmojiChanged;

  const _BasicsStep({
    required this.nameCtrl,
    required this.varietyCtrl,
    required this.qtyCtrl,
    required this.category,
    required this.onCategoryChanged,
    required this.emoji,
    required this.emojis,
    required this.onEmojiChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Let's plant something! 🌱",
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text('Choose an icon and tell us the basics',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 20),
          Text('Choose Icon', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 10),
          SizedBox(
            height: 56,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: emojis.length,
              itemBuilder: (_, i) {
                final e = emojis[i];
                final isSelected = e == emoji;
                return GestureDetector(
                  onTap: () => onEmojiChanged(e),
                  child: Container(
                    width: 48,
                    height: 48,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.paleGreen : AppColors.cream,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? AppColors.leaf : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Center(
                        child: Text(e, style: const TextStyle(fontSize: 22))),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          const _FieldLabel('Crop Name', required: true),
          TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(hintText: 'e.g. Cherry Tomatoes'),
          ),
          const SizedBox(height: 16),
          const _FieldLabel('Variety'),
          TextField(
            controller: varietyCtrl,
            decoration: const InputDecoration(hintText: 'e.g. Sweet Million'),
          ),
          const SizedBox(height: 16),
          const _FieldLabel('Category'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: CropCategory.values.map((c) {
              final isSelected = c == category;
              return GestureDetector(
                onTap: () => onCategoryChanged(c),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.forest : AppColors.cream,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color:
                            isSelected ? AppColors.forest : AppColors.border),
                  ),
                  child: Text('${c.emoji} ${c.label}',
                      style: AppTextStyles.body(12,
                          weight: FontWeight.w600,
                          color:
                              isSelected ? Colors.white : AppColors.slateMid)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const _FieldLabel('Quantity Planted'),
          TextField(
            controller: qtyCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'e.g. 6 seedlings'),
          ),
        ],
      ),
    );
  }
}

// ── STEP 2: LOCATION ─────────────────────────────────

class _LocationStep extends StatelessWidget {
  final String? selectedPlotId;
  final ValueChanged<String> onPlotSelected;

  const _LocationStep(
      {required this.selectedPlotId, required this.onPlotSelected});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Where will it grow? 📍',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text('Select a garden plot for this crop',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 20),
          ...MockData.plots.map((plot) {
            final isSelected = plot.id == selectedPlotId;
            return GestureDetector(
              onTap: () => onPlotSelected(plot.id),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.paleGreen : AppColors.cream,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppColors.leaf : AppColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                          child: Text(plot.emoji,
                              style: const TextStyle(fontSize: 22))),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(plot.name,
                              style: AppTextStyles.body(14,
                                  weight: FontWeight.w700,
                                  color: AppColors.forest)),
                          Text(
                              '${plot.sizeLabel} · ${plot.soilType.label} · ${plot.activeCropCount} crops',
                              style: AppTextStyles.body(11,
                                  color: AppColors.slateLight)),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.leaf),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Create New Plot'),
            style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48)),
          ),
        ],
      ),
    );
  }
}

// ── STEP 3: SCHEDULE ─────────────────────────────────

class _ScheduleStep extends StatelessWidget {
  final DateTime plantingDate, harvestDate;
  final WateringFrequency watering;
  final ValueChanged<DateTime> onPlantingChanged, onHarvestChanged;
  final ValueChanged<WateringFrequency> onWateringChanged;
  final TextEditingController notesCtrl;

  const _ScheduleStep({
    required this.plantingDate,
    required this.harvestDate,
    required this.watering,
    required this.onPlantingChanged,
    required this.onHarvestChanged,
    required this.onWateringChanged,
    required this.notesCtrl,
  });

  Future<void> _pickDate(BuildContext context, DateTime initial,
      ValueChanged<DateTime> onPicked) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) onPicked(picked);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Set the schedule 🗓️',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text('When did you plant and when do you expect to harvest?',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 20),
          const _FieldLabel('Planting Date', required: true),
          GestureDetector(
            onTap: () => _pickDate(context, plantingDate, onPlantingChanged),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded,
                      size: 18, color: AppColors.leaf),
                  const SizedBox(width: 10),
                  Text(
                      '${plantingDate.day}/${plantingDate.month}/${plantingDate.year}',
                      style: AppTextStyles.body(14, weight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const _FieldLabel('Expected Harvest Date'),
          GestureDetector(
            onTap: () => _pickDate(context, harvestDate, onHarvestChanged),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.event_available_rounded,
                      size: 18, color: AppColors.amber),
                  const SizedBox(width: 10),
                  Text(
                      '${harvestDate.day}/${harvestDate.month}/${harvestDate.year}',
                      style: AppTextStyles.body(14, weight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const _FieldLabel('Watering Frequency'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: WateringFrequency.values.map((w) {
              final isSelected = w == watering;
              return GestureDetector(
                onTap: () => onWateringChanged(w),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.blue : AppColors.cream,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: isSelected ? AppColors.blue : AppColors.border),
                  ),
                  child: Text(w.label,
                      style: AppTextStyles.body(12,
                          weight: FontWeight.w600,
                          color:
                              isSelected ? Colors.white : AppColors.slateMid)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const _FieldLabel('Notes (Optional)'),
          TextField(
            controller: notesCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
                hintText: 'Special care instructions, source, etc.'),
          ),
        ],
      ),
    );
  }
}

// ── STEP 4: REVIEW ───────────────────────────────────

class _ReviewStep extends StatelessWidget {
  final String emoji, name, variety, qty;
  final CropCategory category;
  final String? plotId;
  final DateTime plantingDate, harvestDate;
  final WateringFrequency watering;

  const _ReviewStep({
    required this.emoji,
    required this.name,
    required this.variety,
    required this.category,
    required this.plotId,
    required this.plantingDate,
    required this.harvestDate,
    required this.watering,
    required this.qty,
  });

  @override
  Widget build(BuildContext context) {
    final plot = MockData.plots.where((p) => p.id == plotId).firstOrNull;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Review & Confirm ✓',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text('Double-check before adding to your garden',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                      child: Text(emoji, style: const TextStyle(fontSize: 32))),
                ),
                const SizedBox(height: 12),
                Text(name,
                    style: AppTextStyles.display(20, color: Colors.white)),
                if (variety.isNotEmpty)
                  Text(variety,
                      style: AppTextStyles.body(12,
                          color: Colors.white.withValues(alpha: 0.7))),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _ReviewRow('🏷️', 'Category', '${category.emoji} ${category.label}'),
          _ReviewRow('📍', 'Plot',
              plot != null ? '${plot.emoji} ${plot.name}' : 'Not selected'),
          _ReviewRow('🗓️', 'Planted',
              '${plantingDate.day}/${plantingDate.month}/${plantingDate.year}'),
          _ReviewRow('🌾', 'Harvest By',
              '${harvestDate.day}/${harvestDate.month}/${harvestDate.year}'),
          _ReviewRow('💧', 'Watering', watering.label),
          _ReviewRow('🔢', 'Quantity', qty.isEmpty ? 'Not specified' : qty),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.blueLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: AppColors.blue, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                      'You\'ll receive notifications as this crop approaches harvest time.',
                      style: AppTextStyles.body(11, color: AppColors.blue)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String emoji, label, value;
  const _ReviewRow(this.emoji, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 10),
          Text(label,
              style: AppTextStyles.body(12, color: AppColors.slateLight)),
          const Spacer(),
          Text(value,
              style: AppTextStyles.body(12,
                  weight: FontWeight.w700, color: AppColors.forest)),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  final bool required;
  const _FieldLabel(this.text, {this.required = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
                text: text,
                style: AppTextStyles.body(12,
                    weight: FontWeight.w600, color: AppColors.slateMid)),
            if (required)
              TextSpan(
                  text: ' *',
                  style: AppTextStyles.body(12,
                      weight: FontWeight.w600, color: AppColors.red)),
          ],
        ),
      ),
    );
  }
}
