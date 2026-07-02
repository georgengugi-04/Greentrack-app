import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// QR scan screen used by all three roles.
/// When a scan succeeds the resolver determines whether the code points to a
/// CropBatch or a Meal and pushes the right result screen.
/// Replace the Centre widget below with a MobileScanner widget once
/// mobile_scanner is added to pubspec.yaml.
class QRScanScreen extends StatelessWidget {
  const QRScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.qr_code_scanner, size: 96, color: AppColors.leaf),
            const SizedBox(height: AppSpacing.lg),
            Text('Point camera at a GreenTrack QR code', style: AppTextStyles.h2),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Scans a crop batch (product packaging) or meal (restaurant menu)',
              style: AppTextStyles.bodyMuted,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            // Simulate a scan for demo purposes
            ElevatedButton.icon(
              icon: const Icon(Icons.flash_on),
              label: const Text('Simulate Meal Scan'),
              onPressed: () => _simulateScan(context, 'meal', 'meal_001'),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              icon: const Icon(Icons.eco),
              label: const Text('Simulate Batch Scan'),
              onPressed: () => _simulateScan(context, 'batch', 'batch_001'),
            ),
          ],
        ),
      ),
    );
  }

  void _simulateScan(BuildContext context, String type, String id) {
    Navigator.of(context).pushNamed('/consumer/result/$type/$id');
  }
}
