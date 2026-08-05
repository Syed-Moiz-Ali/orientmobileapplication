import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';
import 'package:customer_app/core/router/app_router.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';

class CustomerFeedbackView extends ConsumerStatefulWidget {
  const CustomerFeedbackView({super.key});

  @override
  ConsumerState<CustomerFeedbackView> createState() => _CustomerFeedbackViewState();
}

class _CustomerFeedbackViewState extends ConsumerState<CustomerFeedbackView> {
  int _page = 0;
  bool _isSubmitting = false;
  bool _submitted = false;

  // Page 0
  int _overall = 0;

  // Page 1
  int _workQuality = 0;
  int _communication = 0;
  int _timeliness = 0;
  int _valueForMoney = 0;

  // Page 2
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

    final ok = await ref.read(customerRemoteDataSourceProvider).submitFeedback(data);
    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
      if (ok) {
        _submitted = true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit feedback. Try again.')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.s32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.successBg,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.favorite_rounded, color: AppColors.success, size: 40),
                ),
                const SizedBox(height: AppDimensions.s24),
                const Text(
                  'Thank You!',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                const SizedBox(height: AppDimensions.s12),
                const Text(
                  'Your feedback helps us improve our service.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: AppColors.text3, height: 1.4),
                ),
                const SizedBox(height: AppDimensions.s40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.r12)),
                    ),
                    onPressed: () => context.go(AppRoutes.customerBookService),
                    child: const Text('Book Next Service', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: AppDimensions.s16),
                TextButton(
                  onPressed: () => context.go(AppRoutes.customerDashboard),
                  child: const Text('Back to Home', style: TextStyle(color: AppColors.text2, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              color: AppColors.surface,
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.s18),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (_page > 0) {
                        setState(() => _page--);
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.bg,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: AppDimensions.iconSm,
                        color: AppColors.text3,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.s12),
                  const Expanded(
                    child: Text(
                      'Feedback',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Container(
              height: 4,
              width: double.infinity,
              color: AppColors.surface,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (_page + 1) / 3,
                child: Container(color: AppColors.primary),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.s20),
                child: [_buildPage0(), _buildPage1(), _buildPage2()][_page],
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildPage0() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        const Text(
          'How was your experience?',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return GestureDetector(
              onTap: () => setState(() => _overall = index + 1),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  index < _overall ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 48,
                  color: index < _overall ? AppColors.warning : AppColors.border,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildPage1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rate specific areas',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 24),
        _buildCategoryRating('Work Quality', _workQuality, (v) => setState(() => _workQuality = v)),
        const Divider(height: 32),
        _buildCategoryRating('Communication', _communication, (v) => setState(() => _communication = v)),
        const Divider(height: 32),
        _buildCategoryRating('Timeliness', _timeliness, (v) => setState(() => _timeliness = v)),
        const Divider(height: 32),
        _buildCategoryRating('Value for Money', _valueForMoney, (v) => setState(() => _valueForMoney = v)),
      ],
    );
  }

  Widget _buildCategoryRating(String label, int value, ValueChanged<int> onChanged) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ),
        Row(
          children: List.generate(5, (index) {
            return GestureDetector(
              onTap: () => onChanged(index + 1),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  index < value ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 28,
                  color: index < value ? AppColors.warning : AppColors.border,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildPage2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Any other comments?',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 16),
        AppCard(
          padding: EdgeInsets.zero,
          child: TextField(
            controller: _commentCtrl,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Tell us more (optional)\u2026',
              hintStyle: TextStyle(color: AppColors.text4),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(AppDimensions.s16),
            ),
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Would you recommend us?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _wouldRecommend = true),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: _wouldRecommend == true ? AppColors.primaryBg : AppColors.surface,
                    border: Border.all(color: _wouldRecommend == true ? AppColors.primary : AppColors.border),
                    borderRadius: BorderRadius.circular(AppDimensions.r12),
                  ),
                  alignment: Alignment.center,
                  child: const Text('Yes \u2764\ufe0f', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _wouldRecommend = false),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: _wouldRecommend == false ? AppColors.dangerBg : AppColors.surface,
                    border: Border.all(color: _wouldRecommend == false ? AppColors.danger : AppColors.border),
                    borderRadius: BorderRadius.circular(AppDimensions.r12),
                  ),
                  alignment: Alignment.center,
                  child: const Text('No', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    bool canContinue = true;
    if (_page == 0 && _overall == 0) canContinue = false;
    if (_page == 1 && (_workQuality == 0 || _communication == 0 || _timeliness == 0 || _valueForMoney == 0)) canContinue = false;
    if (_page == 2 && _wouldRecommend == null) canContinue = false;

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(AppDimensions.s20),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.r12)),
            ),
            onPressed: !canContinue || _isSubmitting
                ? null
                : () {
                    if (_page < 2) {
                      setState(() => _page++);
                    } else {
                      _submit();
                    }
                  },
            child: _isSubmitting
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(_page == 2 ? 'Submit' : 'Next', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }
}
