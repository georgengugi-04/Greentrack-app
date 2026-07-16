<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
=======
﻿import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
>>>>>>> 493c832d1fc8dc6ffa0d63c5c9a92f89984743ca
import '../../../core/session/session_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/models.dart';

<<<<<<< HEAD
const _cropImages = {
  'Tomatoes':    'https://images.unsplash.com/photo-1546470427-f5dcc18e4b0d?w=600&q=80',
  'Lettuce':     'https://images.unsplash.com/photo-1622205313162-be1d5712a43f?w=600&q=80',
  'Carrots':     'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=600&q=80',
  'Avocado':     'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?w=600&q=80',
  'Basil':       'https://images.unsplash.com/photo-1618375569909-3c8616cf7733?w=600&q=80',
};

const _mealImage =
    'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=600&q=80';

class ChefDashboardScreen extends ConsumerStatefulWidget {
  const ChefDashboardScreen({super.key});

  @override
  ConsumerState<ChefDashboardScreen> createState() =>
      _ChefDashboardScreenState();
}

class _ChefDashboardScreenState extends ConsumerState<ChefDashboardScreen> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(sessionProvider);
    final name = user?.restaurantName ?? user?.name ?? 'Chef';

    return Scaffold(
      backgroundColor: AppColors.parchment,
      body: IndexedStack(index: _navIndex, children: [
        _KitchenTab(restaurantName: name),
        const _VerifyTab(),
        const _MealsTab(),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.chefAccent,
        icon: const Icon(Icons.restaurant, color: Colors.white),
        label: const Text('Build Meal',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        onPressed: () {},
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        selectedItemColor: AppColors.chefAccent,
        unselectedItemColor: AppColors.textSecondary,
        onTap: (i) => setState(() => _navIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Kitchen'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: 'Verify'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: 'Meals'),
=======
class ChefDashboardScreen extends ConsumerWidget {
  ChefDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider);
    final meal = MockData.sampleMeal;

    return Scaffold(
      appBar: AppBar(
        title: Text(user?.restaurantName ?? 'Chef Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(sessionProvider.notifier).signOut();
              Navigator.of(context).popUntil((r) => r.isFirst);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.chefAccent,
        onPressed: () {},
        icon: const Icon(Icons.restaurant),
        label: const Text('Build Meal'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Text('Verify suppliers · Build meals · Confirm allergens', style: AppTextStyles.label),
          const SizedBox(height: AppSpacing.md),
          Text('Scan Incoming Batch', style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.chefAccent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                const Icon(Icons.qr_code_scanner, color: AppColors.chefAccent, size: 32),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: Text('Scan a crate QR code to verify farm origin, harvest time and certification.', style: AppTextStyles.body)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Recent Verified Batches', style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.sm),
          _VerifiedBatchTile(batch: MockData.sampleBatch),
          const SizedBox(height: AppSpacing.lg),
          Text('Your Meals', style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.sm),
          _MealCard(meal: meal),
>>>>>>> 493c832d1fc8dc6ffa0d63c5c9a92f89984743ca
        ],
      ),
    );
  }
}

<<<<<<< HEAD
// ── KITCHEN TAB ───────────────────────────────────────────────────────────────

class _KitchenTab extends StatelessWidget {
  final String restaurantName;
  const _KitchenTab({required this.restaurantName});

  @override
  Widget build(BuildContext context) {
    final meal = MockData.sampleMeal;
    final batch = MockData.sampleBatch;

    return CustomScrollView(slivers: [
      SliverToBoxAdapter(child: _ChefHeader(restaurantName: restaurantName)),
      // Stats row
      const SliverToBoxAdapter(child: Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Row(children: [
          _StatChip('📦', '3', 'Batches in'),
          SizedBox(width: 10),
          _StatChip('🍽️', '1', 'Active meals'),
          SizedBox(width: 10),
          _StatChip('✅', '100%', 'Verified'),
        ]),
      )),
      // Scan banner
      SliverToBoxAdapter(child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [AppColors.chefAccent.withValues(alpha: 0.8),
                    AppColors.chefAccent],
                  begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(
                  color: AppColors.chefAccent.withValues(alpha: 0.4),
                  blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Row(children: [
              Container(width: 52, height: 52,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14)),
                child: const Center(child: Icon(Icons.qr_code_scanner,
                    color: Colors.white, size: 28))),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Scan Incoming Batch',
                    style: TextStyle(color: Colors.white,
                        fontSize: 16, fontWeight: FontWeight.w700)),
                Text('Verify farm origin, harvest time & certification',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 13)),
              ])),
              const Icon(Icons.chevron_right, color: Colors.white),
            ]),
          ),
        ),
      )),
      // Recent verified batches with photos
      SliverToBoxAdapter(child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
        child: Text('Verified Batches', style: AppTextStyles.h2),
      )),
      SliverToBoxAdapter(child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
        child: SizedBox(
          height: 160,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _BatchPhotoCard(
                cropName: batch.cropName,
                weight: '${batch.verifiedWeightKg ?? "—"} kg',
                organic: batch.organicCertified,
                harvested: batch.harvestedAt != null
                    ? batch.harvestedAt.toString().split(' ').first
                    : '—',
                imgUrl: _cropImages[batch.cropName] ??
                    'https://images.unsplash.com/photo-1546470427-f5dcc18e4b0d?w=400',
              ),
              _BatchPhotoCard(
                cropName: 'Lettuce',
                weight: '12.0 kg',
                organic: true,
                harvested: '2026-06-19',
                imgUrl: _cropImages['Lettuce']!,
              ),
              _BatchPhotoCard(
                cropName: 'Carrots',
                weight: '8.5 kg',
                organic: false,
                harvested: '2026-06-18',
                imgUrl: _cropImages['Carrots']!,
              ),
            ],
          ),
        ),
      )),
      // Meals
      SliverToBoxAdapter(child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
        child: Row(children: [
          Text('Your Meals', style: AppTextStyles.h2),
          const Spacer(),
          const Text('Add new', style: TextStyle(
              color: AppColors.chefAccent, fontSize: 13,
              fontWeight: FontWeight.w600)),
        ]),
      )),
      SliverToBoxAdapter(child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: _MealPhotoCard(meal: meal),
      )),
      const SliverToBoxAdapter(child: SizedBox(height: 100)),
    ]);
  }
}

class _ChefHeader extends StatelessWidget {
  final String restaurantName;
  const _ChefHeader({required this.restaurantName});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Kitchen Dashboard',
                style: AppTextStyles.label.copyWith(
                    color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 4),
            RichText(text: TextSpan(children: [
              TextSpan(text: restaurantName,
                  style: AppTextStyles.display.copyWith(
                      fontSize: 24, color: AppColors.chefAccent)),
              const TextSpan(text: ' 👨‍🍳',
                  style: TextStyle(fontSize: 22)),
            ])),
          ])),
          Container(width: 44, height: 44,
            decoration: BoxDecoration(
              color: AppColors.chefAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.chefAccent.withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.notifications_outlined,
                color: AppColors.chefAccent, size: 22),
          ),
        ]),
=======
class _VerifiedBatchTile extends StatelessWidget {
  final CropBatch batch;
  const _VerifiedBatchTile({required this.batch});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified, color: AppColors.leaf),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${batch.cropName} · ${batch.verifiedWeightKg ?? "—"} kg', style: AppTextStyles.body),
                Text(batch.organicCertified ? 'Organic certified' : 'Not certified', style: AppTextStyles.bodyMuted),
              ],
            ),
          ),
        ],
>>>>>>> 493c832d1fc8dc6ffa0d63c5c9a92f89984743ca
      ),
    );
  }
}

<<<<<<< HEAD
class _StatChip extends StatelessWidget {
  final String emoji, value, label;
  const _StatChip(this.emoji, this.value, this.label);
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border)),
    child: Column(children: [
      Text(emoji, style: const TextStyle(fontSize: 20)),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(
          fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.textPrimary)),
      Text(label, style: AppTextStyles.bodyMuted.copyWith(fontSize: 11)),
    ]),
  ));
}

class _BatchPhotoCard extends StatelessWidget {
  final String cropName, weight, harvested, imgUrl;
  final bool organic;
  const _BatchPhotoCard({required this.cropName, required this.weight,
      required this.organic, required this.harvested, required this.imgUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppShadows.card),
      clipBehavior: Clip.hardEdge,
      child: Stack(children: [
        Positioned.fill(child: CachedNetworkImage(
          imageUrl: imgUrl, fit: BoxFit.cover,
          placeholder: (_, __) =>
              Container(color: AppColors.mint.withValues(alpha: 0.2)),
          errorWidget: (_, __, ___) =>
              Container(color: AppColors.mint.withValues(alpha: 0.2),
                  child: const Icon(Icons.eco, color: AppColors.leaf)),
        )),
        Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withValues(alpha: 0.75)],
            stops: const [0.4, 1.0],
          ),
        ))),
        // Verified badge
        Positioned(top: 10, left: 10, child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
              color: AppColors.leaf, borderRadius: BorderRadius.circular(20)),
          child: const Row(children: [
            Icon(Icons.verified, color: Colors.white, size: 11),
            SizedBox(width: 3),
            Text('Verified', style: TextStyle(color: Colors.white,
                fontSize: 10, fontWeight: FontWeight.w700)),
          ]),
        )),
        if (organic) Positioned(top: 10, right: 10, child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(20)),
          child: const Text('🌿 Organic',
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                  color: AppColors.leaf)),
        )),
        Positioned(bottom: 0, left: 0, right: 0, child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(cropName, style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
            Row(children: [
              Text(weight, style: const TextStyle(
                  color: AppColors.amber, fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(width: 8),
              Expanded(child: Text(harvested,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 11), overflow: TextOverflow.ellipsis)),
            ]),
          ]),
        )),
      ]),
    );
  }
}

class _MealPhotoCard extends StatelessWidget {
  final Meal meal;
  const _MealPhotoCard({required this.meal});
=======
class _MealCard extends StatelessWidget {
  final Meal meal;
  const _MealCard({required this.meal});
>>>>>>> 493c832d1fc8dc6ffa0d63c5c9a92f89984743ca

  @override
  Widget build(BuildContext context) {
    final n = meal.nutrition;
    return Container(
<<<<<<< HEAD
      decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.card),
      clipBehavior: Clip.hardEdge,
      child: Column(children: [
        // Meal photo
        SizedBox(height: 160, child: Stack(children: [
          Positioned.fill(child: CachedNetworkImage(
            imageUrl: _mealImage, fit: BoxFit.cover,
            placeholder: (_, __) =>
                Container(color: AppColors.chefAccent.withValues(alpha: 0.1)),
            errorWidget: (_, __, ___) =>
                Container(color: AppColors.chefAccent.withValues(alpha: 0.1),
                    child: const Icon(Icons.restaurant, size: 40)),
          )),
          Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
              stops: const [0.4, 1.0],
            ),
          ))),
          Positioned(bottom: 12, left: 14, right: 14, child: Row(children: [
            Expanded(child: Text(meal.name, style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  color: AppColors.leaf.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20)),
              child: const Text('Published',
                  style: TextStyle(color: Colors.white,
                      fontSize: 11, fontWeight: FontWeight.w600)),
            ),
          ])),
        ])),
        // Nutrition row
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _NutrChip('🔥', n.calories.toStringAsFixed(0), 'kcal'),
              _NutrChip('💪', '${n.proteinG.toStringAsFixed(1)}g', 'protein'),
              _NutrChip('🌾', '${n.carbsG.toStringAsFixed(1)}g', 'carbs'),
              _NutrChip('🥑', '${n.fatG.toStringAsFixed(1)}g', 'fat'),
            ]),
            const SizedBox(height: 10),
            // Ingredient photo strip
            Text('Ingredients from your batches',
                style: AppTextStyles.label.copyWith(fontSize: 11)),
            const SizedBox(height: 8),
            SizedBox(height: 50, child: ListView(
              scrollDirection: Axis.horizontal,
              children: meal.ingredients.map((ing) {
                final img = _cropImages[ing.cropName];
                return Container(
                  width: 50, height: 50, margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border)),
                  clipBehavior: Clip.hardEdge,
                  child: img != null
                      ? CachedNetworkImage(imageUrl: img, fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              Container(color: AppColors.mint.withValues(alpha: 0.2)),
                          errorWidget: (_, __, ___) =>
                              const Icon(Icons.eco, size: 20))
                      : Container(color: AppColors.mint.withValues(alpha: 0.2),
                          child: const Icon(Icons.eco, size: 20,
                              color: AppColors.leaf)),
                );
              }).toList(),
            )),
            const SizedBox(height: 10),
            // Allergen chips
            Wrap(spacing: 6, runSpacing: 6, children: meal.allergens.map((a) =>
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: a.contains
                      ? AppColors.error.withValues(alpha: 0.08)
                      : AppColors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: a.contains
                          ? AppColors.error.withValues(alpha: 0.3)
                          : AppColors.amber.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '${a.contains ? "⚠️ Contains" : "May contain"}: ${a.allergenId.label}',
                  style: TextStyle(fontSize: 11,
                      color: a.contains ? AppColors.error : AppColors.amber,
                      fontWeight: FontWeight.w600),
                ),
              )).toList(),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _NutrChip extends StatelessWidget {
  final String emoji, value, label;
  const _NutrChip(this.emoji, this.value, this.label);
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(emoji, style: const TextStyle(fontSize: 18)),
    Text(value, style: const TextStyle(
        fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary)),
    Text(label, style: AppTextStyles.bodyMuted.copyWith(fontSize: 10)),
  ]);
}

// ── VERIFY & MEALS TABS ───────────────────────────────────────────────────────

class _VerifyTab extends StatefulWidget {
  const _VerifyTab();
  @override
  State<_VerifyTab> createState() => _VerifyTabState();
}

class _VerifyTabState extends State<_VerifyTab> {
  bool _scanned = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Padding(
      padding: const EdgeInsets.all(20),
      child: _scanned
          ? _VerifiedResult(
              onReset: () => setState(() => _scanned = false))
          : _ScanPrompt(onScan: () => setState(() => _scanned = true)),
    ));
  }
}

class _ScanPrompt extends StatelessWidget {
  final VoidCallback onScan;
  const _ScanPrompt({required this.onScan});
  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center, children: [
    const Spacer(),
    Container(width: 200, height: 200,
      decoration: BoxDecoration(
        color: AppColors.chefAccent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: AppColors.chefAccent.withValues(alpha: 0.3), width: 2)),
      child: const Center(child: Icon(Icons.qr_code_scanner,
          size: 80, color: AppColors.chefAccent))),
    const SizedBox(height: 24),
    Text('Scan incoming batch QR', style: AppTextStyles.h2),
    Text('Verify farm origin & certification', style: AppTextStyles.bodyMuted),
    const SizedBox(height: 32),
    ElevatedButton.icon(
      icon: const Icon(Icons.flash_on),
      label: const Text('Simulate Scan'),
      style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.chefAccent,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12))),
      onPressed: onScan,
    ),
    const Spacer(),
  ]);
}

class _VerifiedResult extends StatelessWidget {
  final VoidCallback onReset;
  const _VerifiedResult({required this.onReset});

  @override
  Widget build(BuildContext context) {
    final batch = MockData.sampleBatch;
    final imgUrl = _cropImages[batch.cropName] ??
        'https://images.unsplash.com/photo-1546470427-f5dcc18e4b0d?w=600';

    return SingleChildScrollView(child: Column(children: [
      // Batch photo
      Container(height: 200, width: double.infinity,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.hardEdge,
        child: Stack(children: [
          Positioned.fill(child: CachedNetworkImage(
              imageUrl: imgUrl, fit: BoxFit.cover,
              placeholder: (_, __) =>
                  Container(color: AppColors.mint.withValues(alpha: 0.2)),
              errorWidget: (_, __, ___) =>
                  Container(color: AppColors.mint.withValues(alpha: 0.2)))),
          Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
                  stops: const [0.4, 1.0])))),
          Positioned(bottom: 14, left: 14, child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Row(children: [
              Icon(Icons.verified, color: AppColors.leaf, size: 18),
              SizedBox(width: 6),
              Text('Batch Verified', style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
            ]),
            Text('Authentic GreenTrack supply chain',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
          ])),
        ]),
      ),
      const SizedBox(height: 16),
      ...[
        ('Crop', batch.cropName),
        ('Batch ID', batch.id),
        ('Farm Plot', batch.plotName ?? '—'),
        ('Harvested', batch.harvestedAt?.toString().split(' ').first ?? '—'),
        ('Weight', '${batch.verifiedWeightKg ?? "—"} kg'),
        ('Method', batch.farmingMethod.name),
        ('Organic', batch.organicCertified ? 'Certified ✓' : 'No'),
      ].map((r) => Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border)),
        child: Row(children: [
          Text(r.$1, style: AppTextStyles.bodyMuted),
          const Spacer(),
          Text(r.$2, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
        ]),
      )),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.chefAccent,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12))),
          onPressed: onReset,
          child: const Text('Accept into Kitchen',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        )),
        const SizedBox(width: 12),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12))),
          onPressed: onReset,
          child: const Text('Flag Issue'),
        ),
      ]),
    ]));
  }
}

class _MealsTab extends StatelessWidget {
  const _MealsTab();
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('My Meals', style: AppTextStyles.h1),
        const SizedBox(height: 16),
        _MealPhotoCard(meal: MockData.sampleMeal),
      ]),
    ));
  }
}
=======
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(meal.name, style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.xs),
          Text('${n.calories.toStringAsFixed(0)} kcal · ${n.proteinG.toStringAsFixed(1)}g protein · ${n.carbsG.toStringAsFixed(1)}g carbs', style: AppTextStyles.bodyMuted),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: meal.allergens.map((a) => Chip(
              label: Text('${a.contains ? "Contains" : "May contain"}: ${a.allergenId.label}', style: const TextStyle(fontSize: 11)),
              backgroundColor: a.contains ? const Color(0xFFFCE8E6) : const Color(0xFFFFF3DA),
            )).toList(),
          ),
        ],
      ),
    );
  }
}
>>>>>>> 493c832d1fc8dc6ffa0d63c5c9a92f89984743ca
