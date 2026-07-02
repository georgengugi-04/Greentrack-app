import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/models.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = MockData.user;

    return Scaffold(
      backgroundColor: AppColors.parchment,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.forest,
            actions: [
              IconButton(
                  icon:
                      const Icon(Icons.settings_outlined, color: Colors.white),
                  onPressed: () {}),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration:
                    const BoxDecoration(gradient: AppColors.heroGradient),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [AppColors.leaf, AppColors.amber]),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: Center(
                          child: Text('MR',
                              style: AppTextStyles.display(28,
                                  color: Colors.white)),
                        ),
                      )
                          .animate()
                          .scale(curve: Curves.elasticOut, duration: 500.ms),
                      const SizedBox(height: 12),
                      Text(user.name,
                          style:
                              AppTextStyles.display(20, color: Colors.white)),
                      Text('📍 ${user.location}',
                          style: AppTextStyles.body(11,
                              color: Colors.white.withValues(alpha: 0.7))),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Stats row
                  Row(
                    children: [
                      Expanded(
                          child: _ProfileStat(
                              '🌱', '${user.stats.totalCrops}', 'Crops')),
                      Expanded(
                          child: _ProfileStat('⚖️',
                              '${user.stats.totalHarvestKg}kg', 'Harvested')),
                      Expanded(
                          child: _ProfileStat('🗓️', '${user.stats.daysActive}',
                              'Days Active')),
                    ],
                  ).animate().fadeIn(),
                  const SizedBox(height: 24),

                  // Achievement badges
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Achievements',
                        style: Theme.of(context).textTheme.titleLarge),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 90,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: const [
                        _Badge('🏆', 'Top Grower', true),
                        _Badge('🌾', '50kg Club', true),
                        _Badge('💧', 'Water Wise', true),
                        _Badge('📸', 'Documentor', false),
                        _Badge('♻️', 'Zero Waste', false),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Menu sections
                  _MenuSection(title: 'Garden', items: [
                    _MenuItem('🌱', 'My Crops', () => context.go('/crops')),
                    _MenuItem(
                        '📍', 'Garden Plots', () => context.go('/garden')),
                    _MenuItem(
                        '🌾', 'Harvest History', () => context.go('/harvest')),
                  ]),
                  const SizedBox(height: 16),
                  _MenuSection(title: 'Insights', items: [
                    _MenuItem('📊', 'Analytics Dashboard',
                        () => context.go('/analytics')),
                    _MenuItem('📋', 'Generate Reports', () {}),
                    _MenuItem('📅', 'Planting Calendar', () {}),
                  ]),
                  const SizedBox(height: 16),
                  _MenuSection(title: 'Account', items: [
                    _MenuItem('👤', 'Edit Profile', () {}),
                    _MenuItem('🔔', 'Notifications',
                        () => context.push('/notifications')),
                    _MenuItem('🌍', 'Climate Zone Settings', () {}),
                    _MenuItem('🔒', 'Privacy & Security', () {}),
                    _MenuItem('❓', 'Help & Support', () {}),
                  ]),
                  const SizedBox(height: 16),

                  OutlinedButton.icon(
                    onPressed: () => context.go('/login'),
                    icon: const Icon(Icons.logout_rounded,
                        size: 18, color: AppColors.red),
                    label: const Text('Sign Out',
                        style: TextStyle(color: AppColors.red)),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      side: const BorderSide(color: AppColors.redLight),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('GreenTrack v1.0.0',
                      style:
                          AppTextStyles.body(10, color: AppColors.slateLight)),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String emoji, value, label;
  const _ProfileStat(this.emoji, this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 6),
          Text(value,
              style: AppTextStyles.display(16, color: AppColors.forest)),
          Text(label,
              style: AppTextStyles.body(9, color: AppColors.slateLight)),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String emoji, label;
  final bool unlocked;
  const _Badge(this.emoji, this.label, this.unlocked);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: unlocked ? AppColors.amberPale : AppColors.cream,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color:
                unlocked ? AppColors.amber.withValues(alpha: 0.4) : AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity: unlocked ? 1 : 0.3,
            child: Text(emoji, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: AppTextStyles.body(8,
                  weight: FontWeight.w600,
                  color: unlocked ? AppColors.amber : AppColors.slateLight),
              textAlign: TextAlign.center,
              maxLines: 2),
        ],
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;
  const _MenuSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title,
              style: AppTextStyles.label(color: AppColors.slateLight)),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cream,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: items.asMap().entries.map((e) {
              final isLast = e.key == items.length - 1;
              return Column(
                children: [
                  ListTile(
                    leading: Text(e.value.emoji,
                        style: const TextStyle(fontSize: 18)),
                    title: Text(e.value.label,
                        style: AppTextStyles.body(13, weight: FontWeight.w500)),
                    trailing: const Icon(Icons.chevron_right_rounded,
                        color: AppColors.slateLight, size: 20),
                    onTap: e.value.onTap,
                  ),
                  if (!isLast) const Divider(height: 1, indent: 56),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _MenuItem {
  final String emoji, label;
  final VoidCallback onTap;
  const _MenuItem(this.emoji, this.label, this.onTap);
}
