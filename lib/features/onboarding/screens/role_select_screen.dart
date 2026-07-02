@'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/session/session_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/models.dart';

class RoleSelectScreen extends ConsumerWidget {
  const RoleSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.parchment,
      body: SafeArea(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 48),
          const Text('From soil to\nyour plate.',
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.w700,
              color: AppColors.textPrimary, height: 1.15,
              fontFamily: 'Playfair Display')),
          const SizedBox(height: 8),
          const Text('Full farm-to-table traceability for everyone in the chain.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
          const SizedBox(height: 36),
          const Text('I am a...', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
            color: AppColors.textSecondary, letterSpacing: 0.4)),
          const SizedBox(height: 12),
          Expanded(child: ListView(children: [
            _RoleCard(emoji: '🌾', bg: const Color(0xFFEEF5EE), title: 'Farmer',
              subtitle: 'Track batches, log irrigation, manage pest control & generate QR codes',
              onTap: () { ref.read(sessionProvider.notifier).signInAs(UserRole.farmer); context.go('/farmer'); }),
            _RoleCard(emoji: '🛒', bg: const Color(0xFFEEF0FA), title: 'Grocery Shopper',
              subtitle: 'Scan QR codes to verify origin, freshness & journey of your produce',
              onTap: () { ref.read(sessionProvider.notifier).signInAs(UserRole.consumer); context.go('/consumer'); }),
            _RoleCard(emoji: '👨‍🍳', bg: const Color(0xFFFAF0EE), title: 'Chef',
              subtitle: 'Confirm suppliers deliver what they promise — freshness verified',
              onTap: () { ref.read(sessionProvider.notifier).signInAs(UserRole.chef); context.go('/chef'); }),
            _RoleCard(emoji: '🥗', bg: const Color(0xFFF0FAF0), title: 'Diner',
              subtitle: 'Know exactly what\'s in your meal — nutrients, origin, freshness',
              onTap: () { ref.read(sessionProvider.notifier).signInAs(UserRole.consumer); context.go('/consumer'); }),
          ])),
          Padding(padding: const EdgeInsets.only(bottom: 20, top: 8),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('Already have an account? ',
                style: TextStyle(color: AppColors.textSecondary)),
              GestureDetector(onTap: () => context.go('/login'),
                child: const Text('Sign In', style: TextStyle(color: AppColors.leaf, fontWeight: FontWeight.w700))),
            ])),
        ]),
      )),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String emoji, title, subtitle;
  final Color bg;
  final VoidCallback onTap;
  const _RoleCard({required this.emoji, required this.bg, required this.title,
    required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
        child: Row(children: [
          Container(width: 52, height: 52,
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 26)))),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 3),
            Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          ])),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ]),
      ),
    );
  }
}
'@ | Set-Content "C:\Users\KOSHE\Documents\greentrack_flutter\lib\features\auth\screens\role_select_screen.dart" -Encoding UTF8