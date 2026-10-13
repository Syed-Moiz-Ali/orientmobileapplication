import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

/// Phase 03A rendered-review gallery.
///
/// Renders every finalized action/input/surface primitive with its real states
/// so the catalog can be reviewed visually (EN/AR × compact/expanded × light/
/// dark). Used by the golden test and the report capture harness; not part of
/// the production app.
class Phase03aGallery extends StatefulWidget {
  const Phase03aGallery({super.key});

  @override
  State<Phase03aGallery> createState() => _Phase03aGalleryState();
}

class _Phase03aGalleryState extends State<Phase03aGallery> {
  final _plain = TextEditingController(text: 'Brake pad replacement');
  final _error = TextEditingController(text: '99200');
  final _ident = TextEditingController(text: 'A 12345');
  final _search = TextEditingController();
  var _obscured = true;
  var _qty = 2.0;

  @override
  void dispose() {
    _plain.dispose();
    _error.dispose();
    _ident.dispose();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sectionStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w800,
      color: theme.colorScheme.primary,
    );

    Widget section(String title, List<Widget> children, {double gap = 12}) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 10),
            child: Text(title.toUpperCase(), style: sectionStyle),
          ),
          for (final child in children) ...[child, SizedBox(height: gap)],
        ],
      );
    }

    return Container(
      color: theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.all(AppDimensions.s20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          section('Buttons', [
            AppButton.primary(label: 'Create job card', onPressed: () {}),
            AppButton.primary(label: 'Submitting', isLoading: true),
            AppButton.primary(label: 'Disabled'),
            AppButton.secondary(
              label: 'Add photos',
              leadingIcon: Icons.add_a_photo_outlined,
              onPressed: () {},
            ),
            AppButton.danger(label: 'Cancel booking', onPressed: () {}),
            Wrap(
              spacing: 4,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                AppButton.tertiary(label: 'Learn more', onPressed: () {}),
                AppButton.quietIcon(
                  icon: Icons.more_vert_rounded,
                  onPressed: () {},
                  tooltip: 'More',
                ),
                AppButton.compactInline(
                  label: 'Inspect',
                  icon: Icons.search_rounded,
                  onPressed: () {},
                ),
              ],
            ),
          ]),
          section('Inputs', [
            AppTextField(
              controller: _plain,
              label: 'Work requested',
              hint: 'Describe the work',
            ),
            AppTextField(
              controller: _error,
              label: 'Odometer (km)',
              hint: '0',
              errorText: 'Odometer must be greater than the last reading',
            ),
            AppTextField(
              controller: _ident,
              label: 'Plate number',
              hint: 'A 12345',
              isIdentifier: true,
              prefixIcon: Icons.directions_car_outlined,
            ),
            AppTextField(
              controller: _plain,
              label: 'Password',
              hint: '••••••',
              obscureText: _obscured,
              onToggleObscure: () => setState(() => _obscured = !_obscured),
            ),
            AppSearchField(controller: _search, hintText: 'Search job cards'),
            const AppDropdownButton(
              value: 'Petrol',
              items: ['Petrol', 'Diesel', 'Hybrid'],
              onChanged: _noopString,
            ),
            AppSelectField<int>(
              label: 'Brand',
              hint: 'Select brand',
              value: 1,
              options: const [
                AppSelectionOption<int>(value: 1, label: 'Toyota'),
                AppSelectionOption<int>(value: 2, label: 'Nissan'),
              ],
              onChanged: (_) {},
            ),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                AppQuantityStepper(
                  value: _qty,
                  onChanged: (v) => setState(() => _qty = v),
                ),
                const AppQuantityStepper(
                  value: 4,
                  onChanged: _noopDouble,
                  enabled: false,
                ),
                const AppQuantityStepper(
                  value: 1,
                  onChanged: _noopDouble,
                  isLoading: true,
                ),
              ],
            ),
          ]),
          section('Surfaces & panels', [
            AppCard.standard(
              child: Text('Standard card', style: theme.textTheme.bodyLarge),
            ),
            AppCard.subtle(
              child: Text('Subtle card', style: theme.textTheme.bodyLarge),
            ),
            AppCard.selected(
              child: Text('Selected card', style: theme.textTheme.bodyLarge),
            ),
            AppCard.semantic(
              baseColor: AppColors.warning,
              child: Text(
                'Semantic warning card',
                style: theme.textTheme.bodyLarge,
              ),
            ),
            AppCard.navy(
              child: Text(
                'Navy hero panel',
                style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
              ),
            ),
            const AppInfoPanel.neutral(
              title: 'Notice',
              message: 'Workshop at standard capacity.',
            ),
            const AppInfoPanel.success(
              title: 'Synced',
              message: 'All queued work items sent.',
            ),
            const AppInfoPanel.warning(
              title: 'Pending approval',
              message: '2 estimates need advisor follow-up.',
            ),
            const AppInfoPanel.danger(
              title: 'Overdue',
              message: 'Invoice INV-2291 is 6 days overdue.',
            ),
            const AppInfoPanel.navy(
              title: 'Orient Cloud',
              message: 'Telemetry synchronized.',
            ),
          ]),
          section('Rows & status', [
            const SectionHeader(
              title: 'Active job cards',
              count: 4,
              action: 'View all',
            ),
            const AppRecordRow(
              identifier: 'JOB-4091',
              title: 'Mercedes-Benz E300',
              subtitle: 'Major 60,000 km service',
              status: StatusPill.inProgress('In progress'),
            ),
            const SizedBox(height: 8),
            const AppRecordRow(
              title: 'Toyota Camry 2022',
              subtitle: 'Brake pad replacement',
              metadata: PendingSyncChip(state: SyncChipState.notSent),
              onTap: _noop,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: const [
                StatusPill.neutral('Draft'),
                StatusPill.info('Review'),
                StatusPill.success('Completed'),
                StatusPill.warning('Waiting parts'),
                StatusPill.danger('Rejected'),
                StatusPill.inProgress('In workshop'),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: const [
                PendingSyncChip(state: SyncChipState.notSent),
                PendingSyncChip(state: SyncChipState.queued),
                PendingSyncChip(state: SyncChipState.failed),
                PendingSyncChip(state: SyncChipState.synced),
              ],
            ),
          ]),
          section('Metrics', [
            Row(
              children: const [
                Expanded(
                  child: AppKpiCard(
                    label: 'Revenue',
                    value: 'AED 42,500',
                    trend: KpiTrend(
                      label: '+12%',
                      isPositive: true,
                      timeFrame: 'vs last week',
                    ),
                    icon: Icons.payments_rounded,
                    semanticState: KpiSemanticState.success,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: AppKpiCard.compact(
                    label: 'Open jobs',
                    value: '24',
                    supportingText: '6 due today',
                    icon: Icons.assignment_rounded,
                  ),
                ),
              ],
            ),
            const AppKpiCard.wide(
              label: 'Goodwill',
              value: '92%',
              trend: KpiTrend(label: '0%', isPositive: true, isFlat: true),
              icon: Icons.favorite_rounded,
            ),
          ]),
          section('Progress', [
            const AppLinearProgress(
              value: 0.65,
              label: 'Inspection checklist',
              showPercentage: true,
            ),
            const AppLinearProgress(value: null, label: 'Syncing'),
            const AppStepProgress(
              currentStep: 1,
              steps: [
                AppProgressStep(label: 'Job card'),
                AppProgressStep(label: 'Inspect'),
                AppProgressStep(label: 'Estimate'),
                AppProgressStep(label: 'Deliver'),
              ],
            ),
          ]),
          section('Identity & actions', [
            Row(
              children: const [
                UserAvatar(initials: 'MA'),
                SizedBox(width: 12),
                Text('Moiz Ali'),
                Spacer(),
                NotificationBell(
                  showBadge: true,
                  badgeCount: 3,
                  onPressed: _noop,
                ),
              ],
            ),
            AppActionBar(
              primary: AppButton.primary(
                label: 'Save changes',
                isExpanded: false,
                onPressed: () {},
              ),
              secondary: [
                AppButton.secondary(
                  label: 'Cancel',
                  isExpanded: false,
                  onPressed: () {},
                ),
              ],
            ),
          ]),
        ],
      ),
    );
  }
}

void _noop() {}

void _noopDouble(double _) {}

void _noopString(String _) {}
