import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crm_app/features/crm_dashboard/domain/entities/crm_entities.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_ui_provider.dart';

class LeadAnalyticsState {
  final LeadStatsEntity stats;
  final List<FollowUpEntity> followUps;
  final List<ActivityFeedEntity> feed;
  final bool isLoading;

  const LeadAnalyticsState({
    this.stats = const LeadStatsEntity(),
    this.followUps = const [],
    this.feed = const [],
    this.isLoading = false,
  });

  LeadAnalyticsState copyWith({
    LeadStatsEntity? stats,
    List<FollowUpEntity>? followUps,
    List<ActivityFeedEntity>? feed,
    bool? isLoading,
  }) => LeadAnalyticsState(
    stats: stats ?? this.stats,
    followUps: followUps ?? this.followUps,
    feed: feed ?? this.feed,
    isLoading: isLoading ?? this.isLoading,
  );
}

class LeadAnalyticsNotifier extends Notifier<LeadAnalyticsState> {
  @override
  LeadAnalyticsState build() {
    _load();
    return const LeadAnalyticsState(isLoading: true);
  }

  Future<void> _load() async {
    final repo = ref.read(crmRepositoryProvider);
    final results = await Future.wait([
      repo.getLeadStats(),
      repo.getFollowUps(),
      repo.getActivityFeed(),
    ]);
    state = LeadAnalyticsState(
      isLoading: false,
      stats: results[0] as LeadStatsEntity,
      followUps: results[1] as List<FollowUpEntity>,
      feed: results[2] as List<ActivityFeedEntity>,
    );
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    await _load();
  }
}

final leadAnalyticsProvider = NotifierProvider<LeadAnalyticsNotifier, LeadAnalyticsState>(
  LeadAnalyticsNotifier.new,
);
