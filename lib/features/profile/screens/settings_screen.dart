import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_mode_provider.dart';
import '../../../core/session/session_provider.dart';
import '../../../core/providers/app_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceOf(context),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(children: [
        // Gradient hero band behind the top of the list, so the account
        // header "floats" over something with a bit more presence than a
        // flat background — same visual family as Login/Splash.
        Positioned(
          top: 0, left: 0, right: 0, height: 220,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0D3320), Color(0xFF1B4332), Color(0xFF2D6A4F)],
              ),
            ),
          ),
        ),
        Positioned(
          top: -60, right: -50,
          child: Container(
            width: 200, height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                AppColors.mint.withValues(alpha: 0.18),
                Colors.transparent,
              ]),
            ),
          ),
        ),
        ListView(
        padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 70, 16, 40),
        children: [
          if (user != null) _AccountHeader(user: user)
              .animate().fadeIn(duration: 400.ms).slideY(begin: 0.06, end: 0),
          const SizedBox(height: 20),

          _SettingsSection(title: 'Appearance', children: [
            const _ThemeModeTile(),
          ]).animate().fadeIn(delay: 80.ms, duration: 400.ms),
          const SizedBox(height: 20),

          _SettingsSection(title: 'Account', children: [
            _SettingsTile(
              icon: Icons.person_outline_rounded,
              iconColor: AppColors.leaf,
              title: 'Edit Profile',
              subtitle: 'Tap your photo on the profile page to change it',
              onTap: () => context.push('/profile'),
            ),
            _SettingsTile(
              icon: Icons.lock_reset_rounded,
              iconColor: AppColors.leaf,
              title: 'Change Password',
              subtitle: user?.email == null
                  ? 'No email on file'
                  : 'Send a reset link to ${user!.email}',
              onTap: () => _sendPasswordReset(context, user?.email),
            ),
          ]).animate().fadeIn(delay: 140.ms, duration: 400.ms),
          const SizedBox(height: 20),

          _SettingsSection(title: 'Notifications', children: [
            _SettingsTile(
              icon: Icons.notifications_outlined,
              iconColor: AppColors.amber,
              title: 'Notification Center',
              subtitle: 'Batch alerts, PHI reminders, and updates',
              onTap: () => context.push('/notifications'),
            ),
          ]).animate().fadeIn(delay: 200.ms, duration: 400.ms),
          const SizedBox(height: 20),

          _SettingsSection(title: 'Privacy & Support', children: [
            _SettingsTile(
              icon: Icons.privacy_tip_outlined,
              iconColor: AppColors.consumerAccent,
              title: 'Privacy & Security',
              subtitle: 'Data usage, permissions, manage crops',
              onTap: () => context.push('/settings/privacy-security'),
            ),
            _SettingsTile(
              icon: Icons.help_outline_rounded,
              iconColor: AppColors.consumerAccent,
              title: 'Help & Support',
              subtitle: 'FAQs and contact',
              onTap: () => context.push('/settings/help-support'),
            ),
          ]).animate().fadeIn(delay: 260.ms, duration: 400.ms),
          const SizedBox(height: 20),

          _SettingsSection(title: 'About', children: [
            _SettingsTile(
              icon: Icons.description_outlined,
              iconColor: AppColors.textSecondaryOf(context),
              title: 'Terms of Service',
              onTap: () => context.push('/settings/terms'),
            ),
            _SettingsTile(
              icon: Icons.policy_outlined,
              iconColor: AppColors.textSecondaryOf(context),
              title: 'Privacy Policy',
              onTap: () => context.push('/settings/privacy-policy'),
            ),
          ]).animate().fadeIn(delay: 320.ms, duration: 400.ms),
          const SizedBox(height: 20),

          Consumer(builder: (context, ref, _) {
            final isAdminAsync = ref.watch(isAdminProvider);
            return isAdminAsync.maybeWhen(
              data: (isAdmin) => !isAdmin
                  ? const SizedBox.shrink()
                  : Column(children: [
                      _SettingsSection(title: 'Admin', children: [
                        _SettingsTile(
                          icon: Icons.fact_check_outlined,
                          iconColor: AppColors.amber,
                          title: 'Access Requests',
                          subtitle: 'Review pending supply-chain sign-ups',
                          onTap: () => context.push('/admin/approvals'),
                        ),
                      ]),
                      const SizedBox(height: 20),
                    ]),
              orElse: () => const SizedBox.shrink(),
            );
          }),
          const SizedBox(height: 8),

          OutlinedButton.icon(
            onPressed: () => _confirmSignOut(context, ref),
            icon: const Icon(Icons.logout_rounded, size: 18, color: AppColors.red),
            label: const Text('Sign Out', style: TextStyle(color: AppColors.red)),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              side: const BorderSide(color: AppColors.redLight),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 24),

          Center(
            child: Column(children: [
              Image.asset('assets/images/logo_icon.png', width: 32, height: 32),
              const SizedBox(height: 8),
              Text('GreenTrack',
                  style: AppTextStyles.body(12, weight: FontWeight.w700,
                      color: AppColors.textSecondaryOf(context))),
              const SizedBox(height: 2),
              Text('Version 1.0.0',
                  style: AppTextStyles.body(10, color: AppColors.slateLight)),
            ]),
          ),
        ],
        ),
      ]),
    );
  }

  Future<void> _sendPasswordReset(BuildContext context, String? email) async {
    if (email == null || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No email on file for this account')),
      );
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset link sent to $email')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not send reset email. Please try again.')),
      );
    }
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You\'ll need to sign in again to access your account.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ref.read(sessionProvider.notifier).signOut();
              context.go('/login');
            },
            child: const Text('Sign Out', style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
  }
}

class _AccountHeader extends StatelessWidget {
  final dynamic user;
  const _AccountHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    final initials = (user.name as String).trim().isEmpty
        ? '?'
        : (user.name as String)
            .trim()
            .split(RegExp(r'\s+'))
            .take(2)
            .map((s) => s[0].toUpperCase())
            .join();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardOf(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderOf(context)),
        boxShadow: AppShadows.card,
      ),
      child: Row(children: [
        Container(
          width: 52,
          height: 52,
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.leaf, AppColors.amber]),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(initials,
              style: AppTextStyles.display(18, color: Colors.white)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.name as String,
                  style: AppTextStyles.poppins(15, weight: FontWeight.w700,
                      color: AppColors.textPrimaryOf(context))),
              const SizedBox(height: 2),
              Text((user.email as String?) ?? '',
                  style: AppTextStyles.body(12,
                      color: AppColors.textSecondaryOf(context)),
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ]),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 6, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: AppTextStyles.poppins(11.5,
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
                return Divider(
                    height: 1, indent: 56, color: AppColors.borderOf(context));
              }
              return children[i ~/ 2];
            }),
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  const _SettingsTile({
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

/// Segmented Light / Dark / System picker — more transparent than a plain
/// on/off switch about what "following system" actually means.
class _ThemeModeTile extends ConsumerWidget {
  const _ThemeModeTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.leaf.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.dark_mode_outlined, size: 18, color: AppColors.leaf),
            ),
            const SizedBox(width: 12),
            Text('Theme',
                style: AppTextStyles.poppins(14, weight: FontWeight.w600,
                    color: AppColors.textPrimaryOf(context))),
          ]),
          const SizedBox(height: 12),
          Row(
            children: [
              _ThemeOption(
                label: 'Light',
                icon: Icons.light_mode_outlined,
                selected: mode == ThemeMode.light,
                onTap: () => ref.read(themeModeProvider.notifier).setMode(ThemeMode.light),
              ),
              const SizedBox(width: 8),
              _ThemeOption(
                label: 'Dark',
                icon: Icons.dark_mode_outlined,
                selected: mode == ThemeMode.dark,
                onTap: () => ref.read(themeModeProvider.notifier).setMode(ThemeMode.dark),
              ),
              const SizedBox(width: 8),
              _ThemeOption(
                label: 'System',
                icon: Icons.brightness_auto_outlined,
                selected: mode == ThemeMode.system,
                onTap: () => ref.read(themeModeProvider.notifier).setMode(ThemeMode.system),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _ThemeOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.leaf.withValues(alpha: 0.14)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.leaf : AppColors.borderOf(context),
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Column(children: [
            Icon(icon, size: 18,
                color: selected ? AppColors.leaf : AppColors.textSecondaryOf(context)),
            const SizedBox(height: 4),
            Text(label,
                style: AppTextStyles.body(11.5,
                    weight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? AppColors.leaf : AppColors.textSecondaryOf(context))),
          ]),
        ),
      ),
    );
  }
}
