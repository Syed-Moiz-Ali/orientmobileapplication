import 'package:customer_app/core/router/app_router.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/support/customer_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';

/// Service review as a warm three-step flow: overall stars, per-area stars,
/// then structured tags + comment + recommend.
///
/// The payload keys are exactly the contracted ones. Structured tags travel
/// inside the existing free-text `comment` field (like valet notes in the
/// booking flow) because no tag key exists on the contract. Nothing in the
/// app links here, so no review is ever prompted on an uncompleted job;
/// proper status-gating needs route input, which is a frozen nav semantic
/// and therefore documented, not improvised.
class CustomerFeedbackView extends ConsumerStatefulWidget {
  const CustomerFeedbackView({super.key});

  @override
  ConsumerState<CustomerFeedbackView> createState() =>
      _CustomerFeedbackViewState();
}

class _CustomerFeedbackViewState extends ConsumerState<CustomerFeedbackView> {
  int _page = 0;
  bool _isSubmitting = false;
  bool _submitted = false;
  int _overall = 0;
  int _workQuality = 0;
  int _communication = 0;
  int _timeliness = 0;
  int _valueForMoney = 0;
  final Set<String> _tags = <String>{};
  final _commentCtrl = TextEditingController();
  bool? _wouldRecommend;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  /// The `comment` value: selected tags first, then the typed comment.
  String get _commentText {
    final typed = _commentCtrl.text.trim();
    if (_tags.isEmpty) return _commentCtrl.text;
    final tags = _tags.join(', ');
    if (typed.isEmpty) return tags;
    return '$tags — $typed';
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    final data = {
      'overall': _overall,
      'workQuality': _workQuality,
      'communication': _communication,
      'timeliness': _timeliness,
      'valueForMoney': _valueForMoney,
      'wouldRecommend': _wouldRecommend ?? true,
      'comment': _commentText,
    };

    final ok = await ref
        .read(customerRemoteDataSourceProvider)
        .submitFeedback(data);
    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
      _submitted = ok;
    });

    if (!ok && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.cx.fbSubmitFail)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final t = context.cx;

    if (_submitted) {
      return _SubmittedView(
        onBook: () => context.go(AppRoutes.customerBookService),
        onHome: () => context.go(AppRoutes.customerDashboard),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      // Phase 07.1: bespoke AppTopBar migrated to the shared workspace bar
      // (same title, no back chevron, same close action).
      appBar: WorkspaceAppBar(
        title: t.fbTitle,
        actions: [
          IconButton(
            onPressed: () {
              if (_page > 0) {
                setState(() => _page--);
              } else {
                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_page + 1) / 3,
            minHeight: 4,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(colorScheme.primary),
          ),
          Expanded(
            child: AppResponsivePage(
              maxContentWidth: 640,
              child: switch (_page) {
                0 => _OverallStep(
                  value: _overall,
                  onChanged: (value) => setState(() => _overall = value),
                ),
                1 => _CategoryStep(
                  workQuality: _workQuality,
                  communication: _communication,
                  timeliness: _timeliness,
                  valueForMoney: _valueForMoney,
                  onWorkQuality: (value) =>
                      setState(() => _workQuality = value),
                  onCommunication: (value) =>
                      setState(() => _communication = value),
                  onTimeliness: (value) =>
                      setState(() => _timeliness = value),
                  onValueForMoney: (value) =>
                      setState(() => _valueForMoney = value),
                ),
                _ => _CommentStep(
                  controller: _commentCtrl,
                  wouldRecommend: _wouldRecommend,
                  onRecommend: (value) =>
                      setState(() => _wouldRecommend = value),
                  tags: _tags,
                  onToggleTag: (tag) => setState(() {
                    if (!_tags.remove(tag)) _tags.add(tag);
                  }),
                ),
              },
            ),
          ),
          _BottomBar(
            label: _page == 2 ? t.fbSubmit : t.fbNext,
            loading: _isSubmitting,
            enabled: _canContinue,
            onTap: () {
              if (_page < 2) {
                setState(() => _page++);
              } else {
                _submit();
              }
            },
          ),
        ],
      ),
    );
  }

  bool get _canContinue {
    if (_page == 0) return _overall > 0;
    if (_page == 1) {
      return _workQuality > 0 &&
          _communication > 0 &&
          _timeliness > 0 &&
          _valueForMoney > 0;
    }
    return _wouldRecommend != null;
  }
}

class _SubmittedView extends StatelessWidget {
  final VoidCallback onBook;
  final VoidCallback onHome;

  const _SubmittedView({required this.onBook, required this.onHome});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final t = context.cx;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: AppResponsivePage(
          maxContentWidth: 640,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.favorite_rounded,
                  color: colorScheme.primary,
                  size: 40,
                ),
              ),
              const SizedBox(height: AppDimensions.s24),
              Text(
                t.fbThanks,
                style: textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppDimensions.s12),
              Text(
                t.fbThanksBody,
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppDimensions.s32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onBook,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: Text(t.fbBookNext),
                ),
              ),
              const SizedBox(height: AppDimensions.s12),
              TextButton(onPressed: onHome, child: Text(t.fbBackHome)),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverallStep extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _OverallStep({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final t = context.cx;
    final starOn = context.semanticColors.warning.ink;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          t.fbOverallTitle,
          textAlign: TextAlign.center,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppDimensions.s32),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: AppDimensions.s8,
          children: [
            for (var index = 0; index < 5; index++)
              Semantics(
                button: true,
                selected: index < value,
                label: '${index + 1} of 5',
                excludeSemantics: true,
                child: IconButton(
                  onPressed: () => onChanged(index + 1),
                  iconSize: 48,
                  icon: Icon(
                    index < value
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: index < value ? starOn : colorScheme.outlineVariant,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _CategoryStep extends StatelessWidget {
  final int workQuality;
  final int communication;
  final int timeliness;
  final int valueForMoney;
  final ValueChanged<int> onWorkQuality;
  final ValueChanged<int> onCommunication;
  final ValueChanged<int> onTimeliness;
  final ValueChanged<int> onValueForMoney;

  const _CategoryStep({
    required this.workQuality,
    required this.communication,
    required this.timeliness,
    required this.valueForMoney,
    required this.onWorkQuality,
    required this.onCommunication,
    required this.onTimeliness,
    required this.onValueForMoney,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final t = context.cx;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppDimensions.s20),
        Text(
          t.fbCategoriesTitle,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppDimensions.s24),
        _CategoryRating(
          label: t.fbCatWork,
          value: workQuality,
          onChanged: onWorkQuality,
        ),
        Divider(height: AppDimensions.s32, color: colorScheme.outlineVariant),
        _CategoryRating(
          label: t.fbCatComm,
          value: communication,
          onChanged: onCommunication,
        ),
        Divider(height: AppDimensions.s32, color: colorScheme.outlineVariant),
        _CategoryRating(
          label: t.fbCatTime,
          value: timeliness,
          onChanged: onTimeliness,
        ),
        Divider(height: AppDimensions.s32, color: colorScheme.outlineVariant),
        _CategoryRating(
          label: t.fbCatValue,
          value: valueForMoney,
          onChanged: onValueForMoney,
        ),
      ],
    );
  }
}

class _CategoryRating extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  const _CategoryRating({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final starOn = context.semanticColors.warning.ink;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        Row(
          children: [
            for (var index = 0; index < 5; index++)
              Semantics(
                button: true,
                selected: index < value,
                label: '$label ${index + 1} of 5',
                excludeSemantics: true,
                child: IconButton(
                  onPressed: () => onChanged(index + 1),
                  icon: Icon(
                    index < value
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: index < value ? starOn : colorScheme.outlineVariant,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _CommentStep extends StatelessWidget {
  final TextEditingController controller;
  final bool? wouldRecommend;
  final ValueChanged<bool> onRecommend;
  final Set<String> tags;
  final ValueChanged<String> onToggleTag;

  const _CommentStep({
    required this.controller,
    required this.wouldRecommend,
    required this.onRecommend,
    required this.tags,
    required this.onToggleTag,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final t = context.cx;
    final tagOptions = [t.fbTagFast, t.fbTagClean, t.fbTagClear];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppDimensions.s20),
        Text(
          t.fbTagsTitle,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppDimensions.s12),
        Wrap(
          spacing: AppDimensions.s8,
          runSpacing: AppDimensions.s8,
          children: [
            for (final tag in tagOptions)
              ChoiceChip(
                label: Text(tag),
                selected: tags.contains(tag),
                onSelected: (_) => onToggleTag(tag),
              ),
          ],
        ),
        const SizedBox(height: AppDimensions.s24),
        Text(
          t.fbCommentTitle,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppDimensions.s16),
        AppCard(
          padding: EdgeInsets.zero,
          color: colorScheme.surface,
          borderColor: colorScheme.outlineVariant,
          child: TextField(
            controller: controller,
            maxLines: 4,
            style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: t.fbCommentHint,
              hintStyle: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(AppDimensions.s16),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.s32),
        Text(
          t.fbRecommend,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppDimensions.s16),
        AppAdaptiveGrid(
          minChildWidth: 220,
          childAspectRatio: 4,
          children: [
            _RecommendOption(
              label: t.fbYes,
              selected: wouldRecommend == true,
              color: colorScheme.primary,
              onTap: () => onRecommend(true),
            ),
            _RecommendOption(
              label: t.fbNo,
              selected: wouldRecommend == false,
              color: colorScheme.error,
              onTap: () => onRecommend(false),
            ),
          ],
        ),
      ],
    );
  }
}

class _RecommendOption extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _RecommendOption({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AppCard(
      onTap: onTap,
      color: selected ? color.withValues(alpha: 0.1) : colorScheme.surface,
      borderColor: selected ? color : colorScheme.outlineVariant,
      child: Center(
        child: Text(
          label,
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: selected ? color : colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final String label;
  final bool loading;
  final bool enabled;
  final VoidCallback onTap;

  const _BottomBar({
    required this.label,
    required this.loading,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.surface,
      padding: const EdgeInsets.all(AppDimensions.s20),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: !enabled || loading ? null : onTap,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
            child: loading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.onPrimary,
                    ),
                  )
                : Text(label),
          ),
        ),
      ),
    );
  }
}
