import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/app_providers.dart';
import '../../../data/models/models.dart';

class IrrigationScreen extends ConsumerStatefulWidget {
  const IrrigationScreen({super.key});
  @override
  ConsumerState<IrrigationScreen> createState() => _IrrigationScreenState();
}

class _IrrigationScreenState extends ConsumerState<IrrigationScreen> {
  CropBatch? _selectedBatch;
  WaterSource _source = WaterSource.borehole;
  double _volume = 20;
  int _duration = 30;
  String _method = 'Drip irrigation';
  DateTime _nextScheduled = DateTime.now().add(const Duration(days: 2));
  bool _loading = false;

  final _methods = [
    'Drip irrigation',
    'Sprinkler',
    'Hand watering',
    'Flood',
    'Furrow'
  ];

  @override
  Widget build(BuildContext context) {
    final batches = ref.watch(activeBatchesProvider);

    return Scaffold(
      backgroundColor: AppColors.clay,
      appBar: AppBar(
        title: Text('Log Irrigation', style: AppTextStyles.serif(20)),
        leading: IconButton(
            icon: const Icon(Icons.close), onPressed: () => context.pop()),
        actions: [
          TextButton(
              onPressed: _loading ? null : _save,
              child: Text('Save',
                  style: AppTextStyles.sans(15,
                      color: AppColors.leaf, weight: FontWeight.w700))),
        ],
      ),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        // Info banner
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            const Text('💧', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(
                child: Text(
                    'GreenTrack calculates the next irrigation time and recommended volume based on your crop type and weather conditions.',
                    style: AppTextStyles.sans(12,
                        color: const Color(0xFF1565C0)))),
          ]),
        ),
        const SizedBox(height: 20),

        Text('Which batch?', style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 10),
        SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: batches.length,
              itemBuilder: (ctx, i) {
                final b = batches[i];
                final sel = _selectedBatch?.id == b.id;
                return GestureDetector(
                  onTap: () => setState(() => _selectedBatch = b),
                  child: Container(
                    width: 80,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                        color: sel ? AppColors.mist : Colors.white,
                        border: Border.all(
                            color: sel ? AppColors.leaf : AppColors.border,
                            width: sel ? 2 : 1),
                        borderRadius: BorderRadius.circular(12)),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🌿', style: TextStyle(fontSize: 22)),
                          const SizedBox(height: 4),
                          Text(b.cropName,
                              style: AppTextStyles.sans(10,
                                  weight: FontWeight.w600),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                        ]),
                  ),
                );
              },
            )),
        const SizedBox(height: 20),

        Text('Water source', style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 6),
        DropdownButtonFormField<WaterSource>(
            initialValue: _source,
            decoration: const InputDecoration(),
            items: WaterSource.values
                .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                .toList(),
            onChanged: (v) => setState(() => _source = v!)),
        const SizedBox(height: 16),

        Text('Irrigation method',
            style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
            initialValue: _method,
            decoration: const InputDecoration(),
            items: _methods
                .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                .toList(),
            onChanged: (v) => setState(() => _method = v!)),
        const SizedBox(height: 20),

        Text('Volume (litres)', style: Theme.of(context).textTheme.labelMedium),
        Slider(
            value: _volume,
            min: 5,
            max: 1000,
            divisions: 99,
            label: '${_volume.toInt()}L',
            activeColor: AppColors.leaf,
            onChanged: (v) => setState(() => _volume = v)),
        Center(
            child: Text('${_volume.toInt()} litres',
                style: AppTextStyles.mono(22))),
        const SizedBox(height: 16),

        Text('Duration (minutes)',
            style: Theme.of(context).textTheme.labelMedium),
        Slider(
            value: _duration.toDouble(),
            min: 5,
            max: 240,
            divisions: 47,
            label: '${_duration}min',
            activeColor: AppColors.leaf,
            onChanged: (v) => setState(() => _duration = v.toInt())),
        Center(
            child: Text('$_duration minutes', style: AppTextStyles.mono(20))),
        const SizedBox(height: 20),

        Text('Schedule next irrigation',
            style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () async {
            final d = await showDatePicker(
                context: context,
                initialDate: _nextScheduled,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 30)));
            if (d != null) setState(() => _nextScheduled = d);
          },
          child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                const Icon(Icons.schedule_outlined,
                    size: 18, color: AppColors.slateLight),
                const SizedBox(width: 10),
                Text(
                    '${_nextScheduled.day}/${_nextScheduled.month}/${_nextScheduled.year}',
                    style: AppTextStyles.sans(14)),
                const Spacer(),
                Text('Next irrigation',
                    style: AppTextStyles.sans(11, color: AppColors.slateLight)),
              ])),
        ),
        const SizedBox(height: 32),
      ]),
    );
  }

  Future<void> _save() async {
    if (_selectedBatch == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a batch.')));
      return;
    }
    setState(() => _loading = true);
    try {
      await ref.read(batchServiceProvider).logIrrigation(
          batchId: _selectedBatch!.id,
          source: _source,
          volumeLiters: _volume,
          durationMinutes: _duration,
          method: _method,
          nextScheduled: _nextScheduled);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                '💧 ${_selectedBatch!.cropName} irrigated — ${_volume.toInt()}L via $_method. '
                'Next: ${_nextScheduled.day}/${_nextScheduled.month}')));
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
