import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/app_providers.dart';
import '../../../data/models/models.dart';

class NewBatchScreen extends ConsumerStatefulWidget {
  const NewBatchScreen({super.key});
  @override
  ConsumerState<NewBatchScreen> createState() => _NewBatchScreenState();
}

class _NewBatchScreenState extends ConsumerState<NewBatchScreen> {
  final _nameCtrl = TextEditingController();
  final _varietyCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  FarmingMethod _method = FarmingMethod.conventional;
  DateTime _plantDate = DateTime.now();
  DateTime _harvestDate = DateTime.now().add(const Duration(days: 60));
  double _estYield = 10;
  int _quantity = 100;
  bool _loading = false;
  double _lat = 0, _lng = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.clay,
      appBar: AppBar(
        title: Text('New Crop Batch', style: AppTextStyles.serif(20)),
        leading: IconButton(
            icon: const Icon(Icons.close), onPressed: () => context.pop()),
        actions: [
          TextButton(
              onPressed: _loading ? null : _save,
              child: Text('Plant',
                  style: AppTextStyles.sans(15,
                      color: AppColors.leaf, weight: FontWeight.w700))),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // GPS location banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: AppColors.mist,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.leaf.withValues(alpha: 0.3))),
            child: Row(children: [
              const Icon(Icons.location_on_outlined,
                  color: AppColors.leaf, size: 22),
              const SizedBox(width: 10),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('GPS Location',
                        style: AppTextStyles.sans(13,
                            weight: FontWeight.w600, color: AppColors.canopy)),
                    Text(
                        _lat == 0
                            ? 'Tap to pin your plot location'
                            : '${_lat.toStringAsFixed(4)}, ${_lng.toStringAsFixed(4)}',
                        style: AppTextStyles.sans(12, color: AppColors.slate)),
                  ])),
              TextButton(onPressed: _getLocation, child: const Text('Pin')),
            ]),
          ),
          const SizedBox(height: 20),

          _label('Plot Location Name *'),
          const SizedBox(height: 6),
          TextField(
              controller: _locationCtrl,
              decoration: const InputDecoration(
                  hintText: 'e.g. North Field, Greenhouse B',
                  prefixIcon: Icon(Icons.terrain_outlined, size: 20))),
          const SizedBox(height: 16),

          _label('Crop Name *'),
          const SizedBox(height: 6),
          TextField(
              controller: _nameCtrl,
              decoration:
                  const InputDecoration(hintText: 'e.g. Spinach, Tomatoes')),
          const SizedBox(height: 16),

          _label('Variety'),
          const SizedBox(height: 6),
          TextField(
              controller: _varietyCtrl,
              decoration:
                  const InputDecoration(hintText: 'e.g. Baby Spinach, Cherry')),
          const SizedBox(height: 16),

          _label('Farming Method *'),
          const SizedBox(height: 6),
          DropdownButtonFormField<FarmingMethod>(
              initialValue: _method,
              decoration: const InputDecoration(),
              items: FarmingMethod.values
                  .map((m) => DropdownMenuItem(value: m, child: Text(m.label)))
                  .toList(),
              onChanged: (v) => setState(() => _method = v!)),
          const SizedBox(height: 16),

          Row(children: [
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  _label('Date Planted'),
                  const SizedBox(height: 6),
                  _DatePicker(
                      date: _plantDate,
                      onChanged: (d) => setState(() => _plantDate = d)),
                ])),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  _label('Expected Harvest'),
                  const SizedBox(height: 6),
                  _DatePicker(
                      date: _harvestDate,
                      onChanged: (d) => setState(() => _harvestDate = d)),
                ])),
          ]),
          const SizedBox(height: 16),

          Row(children: [
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  _label('Est. Yield (kg)'),
                  Slider(
                      value: _estYield,
                      min: 1,
                      max: 500,
                      divisions: 99,
                      label: '${_estYield.toInt()}kg',
                      activeColor: AppColors.leaf,
                      onChanged: (v) => setState(() => _estYield = v)),
                  Center(
                      child: Text('${_estYield.toInt()} kg',
                          style: AppTextStyles.mono(14))),
                ])),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  _label('Plants / Units'),
                  const SizedBox(height: 16),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: _quantity > 1
                            ? () => setState(() => _quantity--)
                            : null),
                    Text('$_quantity', style: AppTextStyles.mono(20)),
                    IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => setState(() => _quantity++)),
                  ]),
                ])),
          ]),
          const SizedBox(height: 16),

          _label('Notes'),
          const SizedBox(height: 6),
          TextField(
              controller: _notesCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                  hintText: 'Seed source, soil conditions, observations...')),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _label(String t) =>
      Text(t, style: Theme.of(context).textTheme.labelMedium);

  Future<void> _getLocation() async {
    // Mock GPS for demo — in production use geolocator package
    setState(() {
      _lat = -1.2921;
      _lng = 36.8219;
    });
    if (mounted) {
      _locationCtrl.text.isEmpty
          ? _locationCtrl.text = 'Nairobi County Plot'
          : null;
    }
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty || _locationCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please fill in crop name and plot location.')));
      return;
    }
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) return;

    setState(() => _loading = true);
    try {
      final batch = await ref.read(batchServiceProvider).createBatch(
            farmerId: uid,
            cropName: _nameCtrl.text.trim(),
            variety: _varietyCtrl.text.trim().isEmpty
                ? 'Standard'
                : _varietyCtrl.text.trim(),
            plotLocation: _locationCtrl.text.trim(),
            latitude: _lat,
            longitude: _lng,
            farmingMethod: _method,
            plantedDate: _plantDate,
            expectedHarvestDate: _harvestDate,
            estimatedYieldKg: _estYield,
            quantityPlanted: _quantity,
            notes:
                _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                '🌱 ${batch.cropName} batch created! QR ready at harvest.')));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}

class _DatePicker extends StatelessWidget {
  final DateTime date;
  final ValueChanged<DateTime> onChanged;
  const _DatePicker({required this.date, required this.onChanged});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () async {
          final d = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime(2020),
              lastDate: DateTime.now().add(const Duration(days: 365)));
          if (d != null) onChanged(d);
        },
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 16, color: AppColors.slateLight),
              const SizedBox(width: 8),
              Text('${date.day}/${date.month}/${date.year}',
                  style: AppTextStyles.sans(13)),
            ])),
      );
}
