import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/models.dart';

class FarmerPestDiagnosisScreen extends StatefulWidget {
  final String batchId;
  const FarmerPestDiagnosisScreen({required this.batchId, super.key});

  @override
  State<FarmerPestDiagnosisScreen> createState() =>
      _FarmerPestDiagnosisScreenState();
}

class _FarmerPestDiagnosisScreenState extends State<FarmerPestDiagnosisScreen> {
  PestSeverity _severity = PestSeverity.low;
  bool _treated = false;
  // Simulated auto-detection result
  final String _detectedPest = 'Aphids';
  final String _pesticide = 'Imidacloprid 200SL';
  final String _instructions =
      'Dilute 5 ml per 10L water. Apply in early morning. Avoid harvesting for 14 days.';
  final int _phiDays = 14;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pest Diagnosis')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          GestureDetector(
            onTap: () {},
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.border),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.camera_alt, size: 40, color: AppColors.textSecondary),
                    const SizedBox(height: AppSpacing.sm),
                    Text('Tap to upload pest photo', style: AppTextStyles.bodyMuted),
                    Text('AI will identify the pest automatically',
                        style: AppTextStyles.bodyMuted.copyWith(fontSize: 11)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Simulated diagnosis result
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.bug_report, color: AppColors.error),
                    const SizedBox(width: AppSpacing.sm),
                    Text('Detected: $_detectedPest', style: AppTextStyles.h2),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text('Recommended Treatment', style: AppTextStyles.label),
                Text(_pesticide,
                    style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(_instructions, style: AppTextStyles.bodyMuted),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    const Icon(Icons.timer, size: 16, color: AppColors.amber),
                    const SizedBox(width: 4),
                    Text('PHI: $_phiDays days after treatment',
                        style: AppTextStyles.body.copyWith(color: AppColors.amber)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),
          Text('Severity', style: AppTextStyles.label),
          ...PestSeverity.values.map(
            (s) => RadioListTile<PestSeverity>(
              value: s,
              groupValue: _severity,
              title: Text(s.name, style: AppTextStyles.body),
              activeColor: AppColors.error,
              onChanged: (v) => setState(() => _severity = v!),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),
          CheckboxListTile(
            value: _treated,
            onChanged: (v) => setState(() => _treated = v!),
            title: Text('Treatment applied now', style: AppTextStyles.body),
            subtitle: Text(
                'Logging treatment will start the $_phiDays-day PHI countdown',
                style: AppTextStyles.bodyMuted),
            activeColor: AppColors.farmerAccent,
          ),

          const SizedBox(height: AppSpacing.lg),
          ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: const Text('Save Diagnosis'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
