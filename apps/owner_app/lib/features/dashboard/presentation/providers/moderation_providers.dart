import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

/// P2 (audit): feedback moderation inbox — approve/reject public visibility.
class FeedbackReview {
  final String id, rating, comment, customerName, date;
  const FeedbackReview({
    required this.id, required this.rating, required this.comment,
    required this.customerName, required this.date,
  });

  factory FeedbackReview.fromJson(Map<String, dynamic> j) {
    final name = j['customerName'] as String?;
    return FeedbackReview(
      id: '${j['id']}',
      rating: '${j['rating'] ?? ''}',
      comment: j['comment'] as String? ?? '',
      customerName: (name == null || name.isEmpty)
          ? 'Customer #${j['customerId'] ?? '?'}'
          : name,
      date: j['createdAt'] as String? ?? '',
    );
  }
}

class ModerationState {
  final bool isLoading;
  final String error;
  final List<FeedbackReview> pending;
  const ModerationState({this.isLoading = true, this.error = '', this.pending = const []});

  ModerationState copyWith({bool? isLoading, String? error, List<FeedbackReview>? pending}) =>
      ModerationState(
        isLoading: isLoading ?? this.isLoading,
        error: error ?? this.error,
        pending: pending ?? this.pending,
      );
}

class ModerationNotifier extends Notifier<ModerationState> {
  ApiClient get _client => ref.read(apiClientProvider);

  @override
  ModerationState build() {
    load();
    return const ModerationState();
  }

  Future<void> load() async {
    try {
      final list = (await _client.get<List<dynamic>>(
        ApiEndpoints.feedbackPending,
        fromJson: (d) => d as List<dynamic>,
      )).when(success: (d) => d, failure: (e) => throw e);
      state = state.copyWith(
        isLoading: false,
        error: '',
        pending: list
            .map((e) => FeedbackReview.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
    } catch (e, st) {
      ref.read(loggerProvider).e('Failed to load pending feedback', error: e, stackTrace: st);
      state = state.copyWith(isLoading: false, error: 'Could not load pending feedback');
    }
  }

  Future<void> moderate(String id, bool isPublic) async {
    try {
      await _client.put('${ApiEndpoints.feedbackModeration(id)}?isPublic=$isPublic');
      state = state.copyWith(pending: state.pending.where((f) => f.id != id).toList());
    } catch (e, st) {
      ref.read(loggerProvider).e('Moderation failed', error: e, stackTrace: st);
    }
  }
}

final moderationProvider =
    NotifierProvider<ModerationNotifier, ModerationState>(ModerationNotifier.new);
