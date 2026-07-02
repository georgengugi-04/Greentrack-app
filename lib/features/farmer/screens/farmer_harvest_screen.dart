import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/models.dart';

class FarmerHarvestScreen extends StatefulWidget {
  final String batchId;
  const FarmerHarvestScreen({required this.batchId, super.key});

  @override
  State<FarmerHarvestScreen> createState() => _FarmerHarvestScreenState();
}

class _FarmerHarvestScreenState extends State<FarmerHarvestScreen> {
  final _weightCtrl = TextEditingController();
  HarvestDestination _destination = HarvestDestination.sold;
  bool _saved = false;

  @override
  Widget build(BuildContext context) {
    final batch = MockData.sampleBatch;
    final phiLocked = batch.harvestLockedByPHI;

    if (phiLocked) {
      return Scaffold(
        appBar: AppBar(title: const Text('Log Harvest')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock, size: 64, color: AppColors.error),
                const SizedBox(height: AppSpacing.lg),
                Text('Harvest Blocked by PHI', style: AppTextStyles.h1),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'A pesticide treatment is active. Harvest will be unlocked on ${batch.earliestPHIClearDate.toString().split(' ').first}.',
                  style: AppTextStyles.bodyMuted,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_saved) {
      return Scaffold(
        appBar: AppBar(title: const Text('Harvest Logged')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, size: 72, color: AppColors.leaf),
                const SizedBox(height: AppSpacing.lg),
                Text('Harvest Saved!', style: AppTextStyles.h1),
                const SizedBox(height: AppSpacing.sm),
                Text('${_weightCtrl.text} kg of ${batch.cropName} logged.',
                    style: AppTextStyles.bodyMuted),
                const SizedBox(height: AppSpacing.xl),
                ElevatedButton.icon(
                  icon: const Icon(Icons.qr_code),
                  label: const Text('Generate Batch QR Code'),
                  onPressed: () {},
                ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Back to Dashboard'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Harvest: ${batch.cropName}')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.amber),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Date, time and weather are captured automatically when you save.',
                    style: AppTextStyles.bodyMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _weightCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Verified Weight (kg)',
              prefixIcon: Icon(Icons.scale),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Destination', style: AppTextStyles.label),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: HarvestDestination.values.map((d) {
              final selected = _destination == d;
              return ChoiceChip(
                label: Text(d.name),
                selected: selected,
                selectedColor: AppColors.amber.withValues(alpha: 0.2),
                onSelected: (_) => setState(() => _destination = d),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.md),
          if (_destination == HarvestDestination.sold) ...[
            TextFormField(
                decoration: const InputDecoration(
                    labelText: 'Buyer Name (optional)',
                    prefixIcon: Icon(Icons.person))),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Price per kg (optional)',
                    prefixIcon: Icon(Icons.attach_money))),
            const SizedBox(height: AppSpacing.md),
          ],
          TextFormField(
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Notes (optional)',
              hintText: 'Quality observations, field conditions...',
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton.icon(
            icon: const Icon(Icons.agriculture),
            label: const Text('Log Harvest & Generate QR'),
            onPressed: () {
              if (_weightCtrl.text.isEmpty) return;
              setState(() => _saved = true);
            },
          ),
        ],
      ),
    );
  }
}
