import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class QuickActionSheet extends StatelessWidget {
  const QuickActionSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _Action('🌱', 'Add Crop', 'Record a new planting', AppColors.leaf,
          () => context.go('/crops/add')),
      _Action('💧', 'Log Watering', 'Track water applied', AppColors.blue,
          () => _stub(context, 'Watering logged! 💧')),
      _Action('🌾', 'Log Harvest', 'Record what you picked', AppColors.amber,
          () => context.go('/harvest/log')),
      _Action('📏', 'Growth Update', 'Measure plant height', AppColors.purple,
          () => context.go('/growth/add')),
      _Action('🧪', 'Fertilize', 'Track fertilizer applied', AppColors.forest,
          () => _stub(context, 'Fertilizer logged! 🧪')),
      _Action('📸', 'Add Photo', 'Document plant progress', AppColors.red,
          () => _stub(context, 'Photo added! 📸')),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: AppRadius.bottomSheet,
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Text('Quick Actions',
                  style: Theme.of(context).textTheme.headlineSmall),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 22),
                onPressed: () => Navigator.pop(context),
                color: AppColors.slateLight,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('What would you like to record?',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.9,
            children: actions.asMap().entries.map((e) {
              return _ActionCard(
                action: e.value,
                index: e.key,
              );
            }).toList(),
          ),

          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.paleGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Text('🌤️', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Good growing day today!',
                          style: AppTextStyles.body(13,
                              weight: FontWeight.w600,
                              color: AppColors.forest)),
                      Text('24°C · Humidity 68% · Light winds',
                          style: AppTextStyles.body(11, color: AppColors.leaf)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _stub(BuildContext context, String msg) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final _Action action;
  final int index;

  const _ActionCard({required this.action, required this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        action.onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          color: action.color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: action.color.withValues(alpha: 0.15)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: action.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(action.emoji, style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              action.title,
              style: AppTextStyles.body(
                12,
                weight: FontWeight.w700,
                color: AppColors.slate,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              action.subtitle,
              style: AppTextStyles.body(10, color: AppColors.slateLight),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      )
          .animate(delay: Duration(milliseconds: 50 * index))
          .fadeIn(duration: 300.ms)
          .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOut),
    );
  }
}

class _Action {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _Action(this.emoji, this.title, this.subtitle, this.color, this.onTap);
}
