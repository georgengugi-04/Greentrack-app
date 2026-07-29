// Live notifications, derived from real app state instead of a static mock
// list. Nothing here is stored as a standalone "event" — each notification
// is recomputed from current data every time a dependency changes, so it's
// always in sync with reality: harvest a batch and its reminder disappears
// on its own, no manual dismissal needed for that one.
//
// The one thing that IS session-local state is [dismissedNotificationIdsProvider]
// — swiping a notification away hides it for the rest of the session
// without needing a Firestore write, since these aren't really "messages"
// to persist, they're a live status board. If the underlying condition is
// still true next time you open the app, it'll reappear — which is
// correct: an unharvested batch that's overdue should keep surfacing.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_providers.dart';
import '../session/session_provider.dart';
import '../../data/models/models.dart';

class DismissedNotificationIdsController extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  void dismiss(String id) => state = {...state, id};
  void dismissAll(Iterable<String> ids) => state = {...state, ...ids};
}

final dismissedNotificationIdsProvider = NotifierProvider.autoDispose<
    DismissedNotificationIdsController, Set<String>>(
    DismissedNotificationIdsController.new);

/// Every real, current signal worth surfacing to *this* signed-in user,
/// based on their role. Farmers see harvest timing + PHI holds on their
/// own batches; Aggregator/Transporter/Distributor see batches waiting on
/// them specifically. Ordered most-urgent-first.
final liveNotificationsProvider = Provider.autoDispose<List<AppNotification>>((ref) {
  final user = ref.watch(sessionProvider);
  if (user == null) return const [];

  switch (user.role) {
    case UserRole.farmer:
      return _farmerNotifications(ref);
    case UserRole.aggregator:
      return _supplyChainNotifications(
        ref.watch(incomingForAggregatorProvider),
        verb: 'receive',
        detail: 'Harvested and waiting at the farm',
      );
    case UserRole.transporter:
      return _supplyChainNotifications(
        ref.watch(incomingForTransporterProvider),
        verb: 'pick up',
        detail: 'Waiting with an aggregator',
      );
    case UserRole.distributor:
      return _supplyChainNotifications(
        ref.watch(incomingForDistributorProvider),
        verb: 'receive',
        detail: 'In transit to you',
      );
    case UserRole.chef:
    case UserRole.consumer:
      // No real, derivable per-user signal for these roles yet (no
      // custody-tracked orders/inventory for Chef, no saved-item alerts
      // for Grocery Shopper) — an honest empty feed beats a fake one.
      return const [];
  }
});

/// Notifications actually visible right now — the live list minus
/// whatever's been swiped away this session (see file header).
final visibleNotificationsProvider = Provider.autoDispose<List<AppNotification>>((ref) {
  final live = ref.watch(liveNotificationsProvider);
  final dismissed = ref.watch(dismissedNotificationIdsProvider);
  return live.where((n) => !dismissed.contains(n.id)).toList();
});

final unreadNotificationCountProvider = Provider.autoDispose<int>((ref) {
  return ref.watch(visibleNotificationsProvider).length;
});

List<AppNotification> _farmerNotifications(Ref ref) {
  final batches = ref.watch(farmerBatchesProvider).value ?? const [];
  final now = DateTime.now();
  final items = <_ScoredNotification>[];

  for (final b in batches) {
    // PHI hold — a batch a farmer might otherwise think is ready, but
    // legally/safely isn't yet. Always more urgent than a plain reminder.
    if (b.harvestLockedByPHI) {
      final daysLeft = b.phiDaysRemaining;
      items.add(_ScoredNotification(
        urgency: 0,
        notification: AppNotification(
          id: 'phi_${b.id}',
          title: '${b.cropName} is under a PHI hold',
          body: daysLeft <= 0
              ? 'Clearing today — safe to harvest shortly.'
              : '$daysLeft day${daysLeft == 1 ? '' : 's'} left before it\'s safe to harvest.',
          emoji: '⏳',
          type: NotificationType.phiCountdown,
          scheduledAt: now,
          cropId: b.id,
        ),
      ));
    }

    // Harvest timing — due today/overdue, or coming up within 3 days.
    if (b.stage != CropStage.harvested && b.estimatedHarvestDate != null) {
      final daysLeft = b.estimatedHarvestDate!.difference(now).inDays;
      if (daysLeft <= 3) {
        final overdue = daysLeft < 0;
        items.add(_ScoredNotification(
          urgency: overdue ? 0 : (daysLeft == 0 ? 1 : 2),
          notification: AppNotification(
            id: 'harvest_${b.id}',
            title: overdue
                ? '${b.cropName} is overdue for harvest'
                : daysLeft == 0
                    ? '${b.cropName} is ready to harvest today'
                    : '${b.cropName} harvest in $daysLeft day${daysLeft == 1 ? '' : 's'}',
            body: '${b.plotName ?? 'Your plot'}'
                '${b.estimatedYieldKg != null ? ' · Est. ${b.estimatedYieldKg!.toStringAsFixed(1)}kg' : ''}',
            emoji: '🌾',
            type: NotificationType.harvestReminder,
            scheduledAt: now,
            cropId: b.id,
          ),
        ));
      }
    }
  }

  items.sort((a, b) => a.urgency.compareTo(b.urgency));
  return items.map((s) => s.notification).toList();
}

List<AppNotification> _supplyChainNotifications(
  List<CropBatch> incoming, {
  required String verb,
  required String detail,
}) {
  if (incoming.isEmpty) return const [];
  final now = DateTime.now();
  return incoming
      .map((b) => AppNotification(
            id: 'incoming_${b.id}',
            title: '${b.cropName} ready to $verb',
            body: detail,
            emoji: '📦',
            type: NotificationType.general,
            scheduledAt: now,
            cropId: b.id,
          ))
      .toList();
}

class _ScoredNotification {
  final int urgency; // lower = more urgent
  final AppNotification notification;
  _ScoredNotification({required this.urgency, required this.notification});
}
