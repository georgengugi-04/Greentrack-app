import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/models.dart';

class FarmerBatchDetailScreen extends StatefulWidget {
  final String batchId;
  const FarmerBatchDetailScreen({required this.batchId, super.key});

  @override
  State<FarmerBatchDetailScreen> createState() => _FarmerBatchDetailScreenState();
}

class _FarmerBatchDetailScreenState extends State<FarmerBatchDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // In a real build: ref.watch(batchProvider(widget.batchId))
    final batch = MockData.sampleBatch;

    return Scaffold(
      appBar: AppBar(
        title: Text(batch.cropName),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: AppColors.farmerAccent,
          labelColor: AppColors.farmerAccent,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Irrigation'),
            Tab(text: 'Pests'),
            Tab(text: 'PHI'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _OverviewTab(batch: batch),
          _IrrigationTab(logs: batch.irrigationLogs),
          _PestTab(diagnoses: batch.pestDiagnoses, batchId: batch.id),
          _PHITab(batch: batch),
        ],
      ),
    );
  }
}

// ── Overview ─────────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  final CropBatch batch;
  const _OverviewTab({required this.batch});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _InfoTile('Batch ID', batch.id),
        _InfoTile('Plot', batch.plotName ?? '—'),
        _InfoTile('Method', batch.farmingMethod.name),
        _InfoTile('Stage', batch.stage.name),
        _InfoTile('Sun', batch.sunExposure.name),
        _InfoTile('Planned', _fmt(batch.plannedDate)),
        if (batch.plantedDate != null) _InfoTile('Planted', _fmt(batch.plantedDate!)),
        if (batch.harvestedAt != null) _InfoTile('Harvested', _fmt(batch.harvestedAt!)),
        if (batch.verifiedWeightKg != null)
          _InfoTile('Weight', '${batch.verifiedWeightKg} kg'),
        if (batch.organicCertified) const _InfoTile('Organic', 'Certified ✓'),
        const SizedBox(height: AppSpacing.md),
        ElevatedButton.icon(
          icon: const Icon(Icons.qr_code),
          label: const Text('View Batch QR Code'),
          onPressed: () {},
        ),
      ],
    );
  }

  String _fmt(DateTime d) => '${d.day}/${d.month}/${d.year}';
}

class _InfoTile extends StatelessWidget {
  final String label, value;
  const _InfoTile(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: AppColors.border)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMuted),
          Text(value,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ── Irrigation ────────────────────────────────────────────────────────────────

class _IrrigationTab extends StatelessWidget {
  final List<IrrigationLog> logs;
  const _IrrigationTab({required this.logs});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.farmerAccent,
        child: const Icon(Icons.add),
        onPressed: () {},
      ),
      body: logs.isEmpty
          ? Center(
              child: Text('No irrigation logs yet', style: AppTextStyles.bodyMuted))
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: logs.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (_, i) {
                final l = logs[i];
                return ListTile(
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      side: const BorderSide(color: AppColors.border)),
                  leading: const Icon(Icons.water_drop,
                      color: AppColors.consumerAccent),
                  title: Text('${l.liters} L · ${l.source.name}'),
                  subtitle: Text(l.timestamp.toString().split(' ').first),
                );
              },
            ),
    );
  }
}

// ── Pests ─────────────────────────────────────────────────────────────────────

class _PestTab extends StatelessWidget {
  final List<PestDiagnosis> diagnoses;
  final String batchId;
  const _PestTab({required this.diagnoses, required this.batchId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.error,
        icon: const Icon(Icons.bug_report),
        label: const Text('New Diagnosis'),
        onPressed: () => Navigator.of(context)
            .pushNamed('/farmer/pest/$batchId'),
      ),
      body: diagnoses.isEmpty
          ? Center(
              child: Text('No pest diagnoses recorded', style: AppTextStyles.bodyMuted))
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: diagnoses.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (_, i) {
                final d = diagnoses[i];
                return Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: d.isHarvestLocked
                          ? AppColors.error
                          : AppColors.border,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d.detectedPest, style: AppTextStyles.h2),
                      Text('Severity: ${d.severity.name}',
                          style: AppTextStyles.bodyMuted),
                      if (d.isHarvestLocked)
                        Text(
                          'PHI locked until ${d.phiClearDate.toString().split(' ').first}',
                          style: AppTextStyles.body
                              .copyWith(color: AppColors.error),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

// ── PHI Countdown ─────────────────────────────────────────────────────────────

class _PHITab extends StatelessWidget {
  final CropBatch batch;
  const _PHITab({required this.batch});

  @override
  Widget build(BuildContext context) {
    final locked = batch.harvestLockedByPHI;
    final clearDate = batch.earliestPHIClearDate;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: locked
                  ? AppColors.error.withValues(alpha: 0.08)
                  : AppColors.leaf.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Column(
              children: [
                Icon(
                  locked ? Icons.lock : Icons.lock_open,
                  size: 48,
                  color: locked ? AppColors.error : AppColors.leaf,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  locked ? 'Harvest Locked' : 'Harvest Cleared',
                  style: AppTextStyles.h1.copyWith(
                      color: locked ? AppColors.error : AppColors.leaf),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  locked && clearDate != null
                      ? 'Safe to harvest after\n${clearDate.toString().split(' ').first}'
                      : batch.pestDiagnoses.isEmpty
                          ? 'No pest treatments recorded'
                          : 'All PHI windows have passed',
                  style: AppTextStyles.bodyMuted,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('PHI (Pre-Harvest Interval)', style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'A PHI lockout is applied automatically when a pesticide treatment is logged. Harvest is blocked until all treatment windows have cleared.',
            style: AppTextStyles.body,
          ),
        ],
      ),
    );
  }
}
