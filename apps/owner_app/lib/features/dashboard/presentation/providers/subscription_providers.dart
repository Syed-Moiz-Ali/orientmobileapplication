import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

/// P3 (audit): SaaS subscription — current plan + plan switcher.
class SubscriptionState {
  final bool isLoading;
  final String plan;
  final String status;
  final String renewsAt;
  const SubscriptionState({
    this.isLoading = true,
    this.plan = 'starter',
    this.status = 'trial',
    this.renewsAt = '',
  });

  SubscriptionState copyWith({bool? isLoading, String? plan, String? status, String? renewsAt}) =>
      SubscriptionState(
        isLoading: isLoading ?? this.isLoading,
        plan: plan ?? this.plan,
        status: status ?? this.status,
        renewsAt: renewsAt ?? this.renewsAt,
      );
}

class SubscriptionNotifier extends Notifier<SubscriptionState> {
  ApiClient get _client => ref.read(apiClientProvider);

  @override
  SubscriptionState build() {
    load();
    return const SubscriptionState();
  }

  Future<void> load() async {
    try {
      final data = (await _client.get<Map<String, dynamic>>(
        ApiEndpoints.ownerSubscription,
        fromJson: (d) => d as Map<String, dynamic>,
      )).when(success: (d) => d, failure: (e) => throw e);
      state = state.copyWith(
        isLoading: false,
        plan: data['plan'] as String? ?? 'starter',
        status: data['status'] as String? ?? 'trial',
        renewsAt: data['renewsAt'] as String? ?? '',
      );
    } catch (e, st) {
      ref.read(loggerProvider).e('Failed to load subscription', error: e, stackTrace: st);
      state = state.copyWith(isLoading: false);
    }
  }

  Future<String?> setPlan(String plan) async {
    try {
      await _client.put('${ApiEndpoints.ownerSubscription}?plan=$plan');
      await load();
      return null;
    } catch (e, st) {
      ref.read(loggerProvider).e('Failed to set plan', error: e, stackTrace: st);
      return 'Could not update the plan';
    }
  }
}

final subscriptionProvider =
    NotifierProvider<SubscriptionNotifier, SubscriptionState>(SubscriptionNotifier.new);
