import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/session/session_provider.dart';
import '../../../data/models/models.dart';
import '../../shared/widgets/animated_emoji.dart';
import '../../shared/widgets/user_avatar.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider);

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.surfaceOf(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
        children: [
          _ProfileHeader(user: user),
          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.only(left: 6, bottom: 8),
            child: Text(
              'ACHIEVEMENTS',
              style: AppTextStyles.body(11.5,
                  weight: FontWeight.w700,
                  color: AppColors.textSecondaryOf(context)).copyWith(letterSpacing: 0.6),
            ),
          ),
          SizedBox(
            height: 92,
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
          const SizedBox(height: 20),

          _ProfileSection(title: 'Account', children: [
            _ProfileTile(
              icon: Icons.settings_outlined,
              iconColor: AppColors.leaf,
              title: 'Settings',
              subtitle: 'Theme, password, notifications',
              onTap: () => context.push('/settings'),
            ),
            _ProfileTile(
              icon: Icons.notifications_outlined,
              iconColor: AppColors.amber,
              title: 'Notifications',
              onTap: () => context.push('/notifications'),
            ),
          ]),
          const SizedBox(height: 28),

          OutlinedButton.icon(
            onPressed: () {
              ref.read(sessionProvider.notifier).signOut();
              context.go('/login');
            },
            icon: const Icon(Icons.logout_rounded, size: 18, color: AppColors.red),
            label: const Text('Sign Out', style: TextStyle(color: AppColors.red)),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              side: const BorderSide(color: AppColors.redLight),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text('GreenTrack v1.0.0',
                style: AppTextStyles.body(10, color: AppColors.slateLight)),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends ConsumerWidget {
  final AppUser user;
  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardOf(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderOf(context)),
        boxShadow: AppShadows.card,
      ),
      child: Column(children: [
        EditableUserAvatar(
          photoUrl: user.photoUrl,
          fallbackText: user.name,
          size: 72,
          onPhotoPicked: (bytes) =>
              ref.read(sessionProvider.notifier).updateProfilePhoto(bytes),
        ).animate().scale(curve: Curves.elasticOut, duration: 500.ms),
        const SizedBox(height: 12),
        Text(user.name,
            style: AppTextStyles.poppins(17, weight: FontWeight.w700,
                color: AppColors.textPrimaryOf(context))),
        const SizedBox(height: 2),
        Text('📍 ${user.farmName ?? user.restaurantName ?? user.organizationName ?? user.vehicleInfo ?? user.role.label}',
            style: AppTextStyles.body(12, color: AppColors.textSecondaryOf(context))),
      ]),
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
        color: unlocked ? AppColors.amber.withValues(alpha: 0.14) : AppColors.cardOf(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: unlocked
                ? AppColors.amber.withValues(alpha: 0.4)
                : AppColors.borderOf(context)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity: unlocked ? 1 : 0.3,
            child: AnimatedEmoji(emoji, size: 22),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: AppTextStyles.body(8.5,
                  weight: FontWeight.w600,
                  color: unlocked ? AppColors.amber : AppColors.textSecondaryOf(context)),
              textAlign: TextAlign.center,
              maxLines: 2),
        ],
      ),
    );
  }
}

// ── Below: mirrors Settings screen's _SettingsSection / _SettingsTile
// exactly (same card style, icon badges, section header typography) so
// Profile and Settings read as one consistent design language.

class _ProfileSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _ProfileSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 6, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: AppTextStyles.body(11.5,
                weight: FontWeight.w700,
                color: AppColors.textSecondaryOf(context)).copyWith(letterSpacing: 0.6),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardOf(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderOf(context)),
            boxShadow: AppShadows.card,
          ),
          child: Column(
            children: List.generate(children.length * 2 - 1, (i) {
              if (i.isOdd) {
                return Divider(height: 1, indent: 56, color: AppColors.borderOf(context));
              }
              return children[i ~/ 2];
            }),
          ),
        ),
      ],
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  const _ProfileTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 18, color: iconColor),
      ),
      title: Text(title,
          style: AppTextStyles.poppins(14, weight: FontWeight.w600,
              color: AppColors.textPrimaryOf(context))),
      subtitle: subtitle == null
          ? null
          : Text(subtitle!,
              style: AppTextStyles.body(11.5, color: AppColors.textSecondaryOf(context))),
      trailing: Icon(Icons.chevron_right_rounded,
          color: AppColors.textSecondaryOf(context), size: 20),
      onTap: onTap,
    );
  }
}
