import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/models.dart';

class FarmerPlanScreen extends StatefulWidget {
  const FarmerPlanScreen({super.key});

  @override
  State<FarmerPlanScreen> createState() => _FarmerPlanScreenState();
}

class _FarmerPlanScreenState extends State<FarmerPlanScreen> {
  int _step = 0;
  final _formKey = GlobalKey<FormState>();
  String _cropName = '';
  FarmingMethod _method = FarmingMethod.organic;
  final SunExposure _sun = SunExposure.fullSun;
  bool _organic = false;

  final List<String> _steps = ['Basics', 'Location', 'Schedule', 'Review'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plan New Crop Batch')),
      body: Column(
        children: [
          _StepperHeader(current: _step, steps: _steps),
          Expanded(
            child: Form(
              key: _formKey,
              child: IndexedStack(
                index: _step,
                children: [
                  _BasicsStep(
                    cropName: _cropName,
                    method: _method,
                    organic: _organic,
                    onCropChanged: (v) => setState(() => _cropName = v),
                    onMethodChanged: (v) => setState(() => _method = v!),
                    onOrganicChanged: (v) => setState(() => _organic = v!),
                  ),
                  const _LocationStep(),
                  const _ScheduleStep(),
                  _ReviewStep(
                    cropName: _cropName,
                    method: _method,
                    organic: _organic,
                    sun: _sun,
                  ),
                ],
              ),
            ),
          ),
          _WizardNav(
            step: _step,
            total: _steps.length,
            onBack: () => setState(() => _step--),
            onNext: () {
              if (_step == _steps.length - 1) {
                // TODO: save batch via provider
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

class _StepperHeader extends StatelessWidget {
  final int current;
  final List<String> steps;
  const _StepperHeader({required this.current, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(
        children: steps.asMap().entries.map((e) {
          final active = e.key == current;
          final done = e.key < current;
          return Expanded(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: done
                      ? AppColors.farmerAccent
                      : active
                          ? AppColors.forest
                          : AppColors.border,
                  child: done
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : Text('${e.key + 1}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    e.value,
                    style: AppTextStyles.label.copyWith(
                        color: active ? AppColors.forest : AppColors.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (e.key < steps.length - 1)
                  Expanded(
                    child: Container(
                        height: 1,
                        color: done ? AppColors.farmerAccent : AppColors.border),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _WizardNav extends StatelessWidget {
  final int step, total;
  final VoidCallback onBack, onNext;
  const _WizardNav(
      {required this.step,
      required this.total,
      required this.onBack,
      required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          if (step > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: onBack,
                child: const Text('Back'),
              ),
            ),
          if (step > 0) const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: ElevatedButton(
              onPressed: onNext,
              child: Text(step == total - 1 ? 'Save Batch' : 'Next'),
            ),
          ),
        ],
      ),
    );
  }
}

// -- Step pages ---------------------------------------------------------------

class _BasicsStep extends StatelessWidget {
  final String cropName;
  final FarmingMethod method;
  final bool organic;
  final ValueChanged<String> onCropChanged;
  final ValueChanged<FarmingMethod?> onMethodChanged;
  final ValueChanged<bool?> onOrganicChanged;

  const _BasicsStep({
    required this.cropName,
    required this.method,
    required this.organic,
    required this.onCropChanged,
    required this.onMethodChanged,
    required this.onOrganicChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Text('Crop Details', style: AppTextStyles.h2),
        const SizedBox(height: AppSpacing.md),
        TextFormField(
          initialValue: cropName,
          decoration: const InputDecoration(labelText: 'Crop Name'),
          onChanged: onCropChanged,
          validator: (v) => v!.isEmpty ? 'Required' : null,
        ),
        const SizedBox(height: AppSpacing.md),
        Text('Farming Method', style: AppTextStyles.label),
        ...FarmingMethod.values.map(
          (m) => RadioListTile<FarmingMethod>(
            value: m,
            groupValue: method,
            title: Text(m.name, style: AppTextStyles.body),
            activeColor: AppColors.farmerAccent,
            onChanged: onMethodChanged,
          ),
        ),
        CheckboxListTile(
          value: organic,
          onChanged: onOrganicChanged,
          title: Text('Organic Certified', style: AppTextStyles.body),
          activeColor: AppColors.farmerAccent,
        ),
      ],
    );
  }
}

class _LocationStep extends StatelessWidget {
  const _LocationStep();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Text('Plot Location', style: AppTextStyles.h2),
        const SizedBox(height: AppSpacing.md),
        TextFormField(
            decoration: const InputDecoration(labelText: 'Plot Name (e.g. Plot A)')),
        const SizedBox(height: AppSpacing.md),
        Container(
          height: 160,
          decoration: BoxDecoration(
            color: AppColors.mint.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.border),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.map, size: 36, color: AppColors.leaf),
                const SizedBox(height: AppSpacing.sm),
                Text('Tap to pin GPS location', style: AppTextStyles.bodyMuted),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        DropdownButtonFormField<SunExposure>(
          decoration: const InputDecoration(labelText: 'Sun Exposure'),
          items: SunExposure.values
              .map((s) => DropdownMenuItem(
                    value: s,
                    child: Text(s.name),
                  ))
              .toList(),
          onChanged: (_) {},
        ),
      ],
    );
  }
}

class _ScheduleStep extends StatelessWidget {
  const _ScheduleStep();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Text('Schedule', style: AppTextStyles.h2),
        const SizedBox(height: AppSpacing.md),
        ListTile(
          tileColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            side: const BorderSide(color: AppColors.border),
          ),
          leading: const Icon(Icons.calendar_today, color: AppColors.leaf),
          title: const Text('Planned Planting Date'),
          subtitle: const Text('Tap to select'),
          onTap: () {},
        ),
        const SizedBox(height: AppSpacing.sm),
        ListTile(
          tileColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            side: const BorderSide(color: AppColors.border),
          ),
          leading: const Icon(Icons.agriculture, color: AppColors.amber),
          title: const Text('Estimated Harvest Date'),
          subtitle: const Text('Tap to select'),
          onTap: () {},
        ),
        const SizedBox(height: AppSpacing.md),
        DropdownButtonFormField<IrrigationSource>(
          decoration:
              const InputDecoration(labelText: 'Primary Irrigation Source'),
          items: IrrigationSource.values
              .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
              .toList(),
          onChanged: (_) {},
        ),
      ],
    );
  }
}

class _ReviewStep extends StatelessWidget {
  final String cropName;
  final FarmingMethod method;
  final bool organic;
  final SunExposure sun;
  const _ReviewStep({
    required this.cropName,
    required this.method,
    required this.organic,
    required this.sun,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Text('Review', style: AppTextStyles.h2),
        const SizedBox(height: AppSpacing.md),
        _ReviewRow('Crop', cropName.isEmpty ? '—' : cropName),
        _ReviewRow('Method', method.name),
        _ReviewRow('Organic', organic ? 'Yes' : 'No'),
        _ReviewRow('Sun', sun.name),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.mint.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Text(
            'Saving this batch will generate a unique Batch ID and QR code. You can update details and log activities from the batch detail screen.',
            style: AppTextStyles.bodyMuted,
          ),
        ),
      ],
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String label, value;
  const _ReviewRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.bodyMuted)),
          Text(value,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
