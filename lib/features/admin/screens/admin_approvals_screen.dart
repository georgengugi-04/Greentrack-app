import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/models.dart';

class AdminApprovalsScreen extends ConsumerWidget {
  const AdminApprovalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdminAsync = ref.watch(isAdminProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceOf(context),
      appBar: AppBar(title: const Text('Access Requests')),
      body: isAdminAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.leaf)),
        error: (e, _) => Center(child: Text('Could not verify admin access: $e')),
        data: (isAdmin) {
          if (!isAdmin) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.lock_outline_rounded, size: 40, color: AppColors.slateLight),
                  const SizedBox(height: 12),
                  Text('Not Authorized',
                      style: AppTextStyles.body(16, weight: FontWeight.w700,
                          color: AppColors.textPrimaryOf(context))),
                  const SizedBox(height: 6),
                  Text('This account doesn\'t have admin access.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body(12.5, color: AppColors.textSecondaryOf(context))),
                ]),
              ),
            );
          }
          return const _RequestQueue();
        },
      ),
    );
  }
}

class _RequestQueue extends ConsumerWidget {
  const _RequestQueue();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(pendingRoleRequestsProvider);

    return requestsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.leaf)),
      error: (e, _) => Center(child: Text('Could not load requests: $e')),
      data: (requests) {
        if (requests.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.check_circle_outline, size: 40, color: AppColors.leaf),
                const SizedBox(height: 12),
                Text('No pending requests',
                    style: AppTextStyles.body(14, color: AppColors.textSecondaryOf(context))),
              ]),
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: requests.map((r) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _RequestCard(request: r),
          )).toList(),
        );
      },
    );
  }
}

class _RequestCard extends ConsumerStatefulWidget {
  final RoleRequest request;
  const _RequestCard({required this.request});

  @override
  ConsumerState<_RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends ConsumerState<_RequestCard> {
  bool _busy = false;

  Future<void> _decide(bool approve) async {
    final reviewer = FirebaseAuth.instance.currentUser?.uid;
    if (reviewer == null) return;
    setState(() => _busy = true);
    try {
      await ref.read(verificationServiceProvider).reviewRequest(
            uid: widget.request.uid,
            approve: approve,
            reviewerUid: reviewer,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(approve
                ? '${widget.request.name} approved'
                : '${widget.request.name} rejected')));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not save decision: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.request;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardOf(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderOf(context)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: AppColors.amber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8)),
            child: Text(r.requestedRole.label,
                style: const TextStyle(color: AppColors.amber, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
          const Spacer(),
          Text('${r.requestedAt.day}/${r.requestedAt.month}/${r.requestedAt.year}',
              style: AppTextStyles.body(11, color: AppColors.textSecondaryOf(context))),
        ]),
        const SizedBox(height: 8),
        Text(r.name, style: AppTextStyles.body(14.5, weight: FontWeight.w700,
            color: AppColors.textPrimaryOf(context))),
        Text(r.email, style: AppTextStyles.body(11.5, color: AppColors.textSecondaryOf(context))),
        if (r.organizationDetail != null) ...[
          const SizedBox(height: 4),
          Text(r.organizationDetail!,
              style: AppTextStyles.body(12.5, color: AppColors.textPrimaryOf(context))),
        ],
        const SizedBox(height: 12),
        if (_busy)
          const Center(child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: SizedBox(width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2.2, color: AppColors.leaf)),
          ))
        else
          Row(children: [
            Expanded(child: OutlinedButton(
              onPressed: () => _decide(false),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.redLight),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Reject', style: TextStyle(color: AppColors.red)),
            )),
            const SizedBox(width: 10),
            Expanded(child: ElevatedButton(
              onPressed: () => _decide(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.leaf,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Approve', style: TextStyle(color: Colors.white)),
            )),
          ]),
      ]),
    );
  }
}
