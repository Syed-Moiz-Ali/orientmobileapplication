import 'package:customer_app/core/router/app_router.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';

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
  final _commentCtrl = TextEditingController();
  bool? _wouldRecommend;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
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
      'comment': _commentCtrl.text,
    };

    final ok = await ref
        .read(customerRemoteDataSourceProvider)
        .submitFeedback(data);
    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
      _submitted = ok;
    });

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit feedback. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted) {
      return _SubmittedView(
        onBook: () => context.go(AppRoutes.customerBookService),
        onHome: () => context.go(AppRoutes.customerDashboard),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppTopBar(
              title: 'Feedback',
              showBack: false,
              trailing: IconButton(
                onPressed: () {
                  if (_page > 0) {
                    setState(() => _page--);
                  } else {
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.close_rounded),
              ),
            ),
            const Divider(height: 1),
            LinearProgressIndicator(
              value: (_page + 1) / 3,
              minHeight: 4,
              backgroundColor: AppColors.surface,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
            Expanded(
              child: AppResponsivePage(
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
                  ),
                },
              ),
            ),
            _BottomBar(
              label: _page == 2 ? 'Submit' : 'Next',
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
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: AppResponsivePage(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.successBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: AppColors.success,
                  size: 40,
                ),
              ),
              const SizedBox(height: AppDimensions.s24),
              Text(
                'Thank You',
                style: textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppDimensions.s12),
              Text(
                'Your feedback helps us improve our service.',
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(
                  color: AppColors.text3,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppDimensions.s32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onBook,
                  child: const Text('Book Next Service'),
                ),
              ),
              const SizedBox(height: AppDimensions.s12),
              TextButton(onPressed: onHome, child: const Text('Back to Home')),
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
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'How was your experience?',
          textAlign: TextAlign.center,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.s32),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: AppDimensions.s8,
          children: [
            for (var index = 0; index < 5; index++)
              IconButton(
                onPressed: () => onChanged(index + 1),
                iconSize: 48,
                icon: Icon(
                  index < value
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  color: index < value ? AppColors.warning : AppColors.border,
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
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rate specific areas',
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.s24),
        _CategoryRating(
          label: 'Work Quality',
          value: workQuality,
          onChanged: onWorkQuality,
        ),
        const Divider(height: AppDimensions.s32),
        _CategoryRating(
          label: 'Communication',
          value: communication,
          onChanged: onCommunication,
        ),
        const Divider(height: AppDimensions.s32),
        _CategoryRating(
          label: 'Timeliness',
          value: timeliness,
          onChanged: onTimeliness,
        ),
        const Divider(height: AppDimensions.s32),
        _CategoryRating(
          label: 'Value for Money',
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
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Row(
          children: [
            for (var index = 0; index < 5; index++)
              IconButton(
                onPressed: () => onChanged(index + 1),
                icon: Icon(
                  index < value
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  color: index < value ? AppColors.warning : AppColors.border,
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

  const _CommentStep({
    required this.controller,
    required this.wouldRecommend,
    required this.onRecommend,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Any other comments?',
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.s16),
        AppCard(
          padding: EdgeInsets.zero,
          child: TextField(
            controller: controller,
            maxLines: 4,
            style: textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Tell us more (optional)',
              hintStyle: textTheme.bodyLarge?.copyWith(color: AppColors.text4),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(AppDimensions.s16),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.s32),
        Text(
          'Would you recommend us?',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.s16),
        AppAdaptiveGrid(
          minChildWidth: 220,
          childAspectRatio: 4,
          children: [
            _RecommendOption(
              label: 'Yes',
              selected: wouldRecommend == true,
              color: AppColors.primary,
              onTap: () => onRecommend(true),
            ),
            _RecommendOption(
              label: 'No',
              selected: wouldRecommend == false,
              color: AppColors.danger,
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
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      onTap: onTap,
      color: selected ? color.withValues(alpha: 0.1) : AppColors.surface,
      borderColor: selected ? color : AppColors.border,
      child: Center(
        child: Text(
          label,
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: selected ? color : AppColors.textPrimary,
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
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(AppDimensions.s20),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: !enabled || loading ? null : onTap,
            child: loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(label),
          ),
        ),
      ),
    );
  }
}
