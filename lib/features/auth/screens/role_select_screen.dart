import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/session/session_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/models.dart';

class RoleSelectScreen extends ConsumerStatefulWidget {
  const RoleSelectScreen({super.key});

  @override
  ConsumerState<RoleSelectScreen> createState() => _RoleSelectScreenState();
}

class _RoleSelectScreenState extends ConsumerState<RoleSelectScreen> {
  UserRole? _selected;
  bool _loading = false;

  Future<void> _confirm() async {
    if (_selected == null) return;
    setState(() => _loading = true);
    try {
      await ref.read(sessionProvider.notifier).setRole(_selected!);
      // Router auto-redirects after session updates
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save role. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.parchment,
      body: SafeArea(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 48),
          Text('From soil to\nyour plate.',
              style: AppTextStyles.display.copyWith(fontSize: 36, height: 1.15)),
          const SizedBox(height: 8),
          Text('Full farm-to-table traceability for everyone in the chain.',
              style: AppTextStyles.bodyMuted.copyWith(fontSize: 15)),
          const SizedBox(height: 36),
          Text('I am a...', style: AppTextStyles.label.copyWith(fontSize: 13)),
          const SizedBox(height: 12),
          Expanded(child: ListView(children: [
            _RoleCard(
              emoji: '🌾', bg: const Color(0xFFEEF5EE), title: 'Farmer',
              subtitle: 'Track batches, log irrigation, manage pest control & generate QR codes',
              selected: _selected == UserRole.farmer,
              onTap: () => setState(() => _selected = UserRole.farmer),
            ),
            _RoleCard(
              emoji: '🛒', bg: const Color(0xFFEEF0FA), title: 'Grocery Shopper',
              subtitle: 'Scan QR codes to verify origin, freshness & journey of your produce',
              selected: _selected == UserRole.consumer,
              onTap: () => setState(() => _selected = UserRole.consumer),
            ),
            _RoleCard(
              emoji: '👨‍🍳', bg: const Color(0xFFFAF0EE), title: 'Chef',
              subtitle: 'Confirm suppliers deliver what they promise — freshness verified',
              selected: _selected == UserRole.chef,
              onTap: () => setState(() => _selected = UserRole.chef),
            ),
            _RoleCard(
              emoji: '🥗', bg: const Color(0xFFF0FAF0), title: 'Diner',
              subtitle: "Know exactly what's in your meal — nutrients, origin, freshness",
              selected: _selected == UserRole.consumer,
              onTap: () => setState(() => _selected = UserRole.consumer),
            ),
          ])),

          // Continue button
          if (_selected != null) ...[
            const SizedBox(height: 12),
            SizedBox(height: 54, child: ElevatedButton(
              onPressed: _loading ? null : _confirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.forest,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: _loading
                  ? const SizedBox(width: 22, height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Text('Continue as ',
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                      Text(_selectedLabel(),
                          style: const TextStyle(color: Colors.white,
                              fontSize: 16, fontWeight: FontWeight.w800)),
                    ]),
            )),
          ],

          Padding(
            padding: const EdgeInsets.only(bottom: 20, top: 12),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('Already have an account? ',
                  style: TextStyle(color: AppColors.textSecondary)),
              GestureDetector(onTap: () => context.go('/login'),
                child: const Text('Sign In', style: TextStyle(
                    color: AppColors.leaf, fontWeight: FontWeight.w700))),
            ]),
          ),
        ]),
      )),
    );
  }

  String _selectedLabel() {
    switch (_selected) {
      case UserRole.farmer: return 'Farmer 🌾';
      case UserRole.chef: return 'Chef 👨‍🍳';
      case UserRole.consumer: return 'Consumer 🛒';
      default: return '';
    }
  }
}

class _RoleCard extends StatelessWidget {
  final String emoji, title, subtitle;
  final Color bg;
  final bool selected;
  final VoidCallback onTap;
  const _RoleCard({required this.emoji, required this.bg, required this.title,
      required this.subtitle, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: selected ? AppColors.forest : AppColors.border,
              width: selected ? 2 : 1),
          boxShadow: selected
              ? [BoxShadow(color: AppColors.forest.withValues(alpha: 0.15),
                  blurRadius: 12, offset: const Offset(0, 4))]
              : AppShadows.card,
        ),
        child: Row(children: [
          Container(width: 52, height: 52,
              decoration: BoxDecoration(color: bg,
                  borderRadius: BorderRadius.circular(14)),
              child: Center(child: Text(emoji,
                  style: const TextStyle(fontSize: 26)))),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: AppTextStyles.h2.copyWith(fontSize: 16)),
            const SizedBox(height: 3),
            Text(subtitle, style: AppTextStyles.bodyMuted.copyWith(fontSize: 13)),
          ])),
          const SizedBox(width: 8),
          Icon(selected ? Icons.check_circle : Icons.chevron_right,
              color: selected ? AppColors.forest : AppColors.textSecondary),
        ]),
      ),
    );
  }
}
