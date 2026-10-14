import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

/// Concept A V2 — Phase 02 rendered component catalog.
///
/// Renders every finalized shared primitive with its real states so the
/// component language can be reviewed visually (EN/AR × compact/tablet/desktop
/// × light/dark). Consumed by `shared_primitives_phase02_visual_test.dart`; it
/// is not part of any production app.
class Phase02ComponentGallery extends StatefulWidget {
  const Phase02ComponentGallery({super.key});

  @override
  State<Phase02ComponentGallery> createState() =>
      _Phase02ComponentGalleryState();
}

class _Phase02ComponentGalleryState extends State<Phase02ComponentGallery> {
  final _plain = TextEditingController(text: 'Brake pad replacement');
  final _error = TextEditingController(text: '99200');
  final _ident = TextEditingController(text: 'A 92481');
  final _search = TextEditingController();
  var _obscured = true;
  var _qty = 2.0;
  var _checkbox = true;
  var _switchOn = true;
  var _radio = 1;
  String _fuel = 'Petrol';
  String _brand = 'Toyota';

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

    Widget section(String title, List<Widget> children, {double gap = 12}) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 10),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 14,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
                  ),
                ),
                const SizedBox(width: AppDimensions.s8),
                Text(
                  title.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.primary,
                    letterSpacing: 0.8,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
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
            AppButton.primary(
              label: 'Submitting for approval',
              isLoading: true,
            ),
            AppButton.primary(label: 'Disabled action'),
            AppButton.primary(
              label: 'Cancel booking',
              icon: Icons.delete_outline_rounded,
              onPressed: () {},
            ),
            AppButton.secondary(
              label: 'Add photos',
              leadingIcon: Icons.add_a_photo_outlined,
              onPressed: () {},
            ),
            AppButton.secondary(
              label: 'View timeline',
              trailingIcon: Icons.chevron_right_rounded,
              onPressed: () {},
            ),
            AppButton.danger(
              label: 'Delete order',
              icon: Icons.delete_forever_rounded,
              onPressed: () {},
            ),
            Wrap(
              spacing: 4,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                AppButton.tertiary(label: 'Learn more', onPressed: () {}),
                AppButton.tertiary(
                  label: 'Manage',
                  icon: Icons.tune_rounded,
                  onPressed: () {},
                ),
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
              hint: 'A 92481',
              isIdentifier: true,
              prefixIcon: Icons.directions_car_outlined,
              prefix: const Padding(
                padding: EdgeInsetsDirectional.only(end: 8),
                child: Text('DXB'),
              ),
            ),
            AppTextField(
              controller: _plain,
              label: 'Password',
              hint: '••••••',
              obscureText: _obscured,
              onToggleObscure: () => setState(() => _obscured = !_obscured),
            ),
            AppSearchField(
              controller: _search,
              hintText: 'Search job cards',
              shortcutLabel: '⌘K',
            ),
            AppDropdownButton(
              value: _fuel,
              items: const ['Petrol', 'Diesel', 'Hybrid'],
              onChanged: (v) => setState(() => _fuel = v),
            ),
            AppSelectField<String>(
              label: 'Brand',
              hint: 'Select brand',
              value: _brand,
              options: const [
                AppSelectionOption<String>(value: 'Toyota', label: 'Toyota'),
                AppSelectionOption<String>(value: 'Nissan', label: 'Nissan'),
                AppSelectionOption<String>(
                  value: 'Mercedes-Benz',
                  label: 'Mercedes-Benz',
                ),
              ],
              onChanged: (v) => setState(() => _brand = v),
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
            Wrap(
              spacing: 20,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Checkbox(
                  value: _checkbox,
                  onChanged: (v) => setState(() => _checkbox = v ?? false),
                ),
                Switch(
                  value: _switchOn,
                  onChanged: (v) => setState(() => _switchOn = v),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioGroup<int>(
                      groupValue: _radio,
                      onChanged: (v) => setState(() => _radio = v ?? 1),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Radio<int>(value: 1),
                          Radio<int>(value: 2),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ]),
          section('Cards & panels', [
            AppCard.standard(
              child: Text('Standard card', style: theme.textTheme.bodyLarge),
            ),
            AppCard.subtle(
              child: Text('Subtle card', style: theme.textTheme.bodyLarge),
            ),
            AppCard.outlined(
              child: Text('Outlined card', style: theme.textTheme.bodyLarge),
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
            const AppInfoPanel.primary(
              title: 'Scheduled',
              message: 'Bay 04 reserved for 10:30.',
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
              subtitle: 'Workshop floor',
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
          section('Progress & loading', [
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
            const AppSkeleton.textBlock(),
            const SizedBox(height: 4),
            const AppSkeleton.listRows(rows: 2),
            const LoadingIndicator(message: 'Loading workshop data'),
          ]),
          section('Identity', [
            Row(
              children: const [
                UserAvatar(initials: 'MA', showOnlineDot: true),
                SizedBox(width: 12),
                UserAvatar(initials: 'SK', size: 44),
                SizedBox(width: 12),
                UserAvatar(initials: 'AH', size: 32),
                Spacer(),
              ],
            ),
          ]),
          section('Forms', [
            AppFormSection(
              title: 'Vehicle intake',
              subtitle: 'Capture the essentials before inspection',
              child: const Column(
                children: [
                  AppFormField(
                    label: 'VIN',
                    isRequired: true,
                    child: SizedBox(height: 48),
                  ),
                  SizedBox(height: 12),
                  AppFormField(
                    label: 'Notes',
                    isOptional: true,
                    helperText: 'Optional service notes',
                    child: SizedBox(height: 48),
                  ),
                  SizedBox(height: 12),
                  AppDateSelectorShell(value: '14 Oct 2026', onTap: _noop),
                  SizedBox(height: 12),
                  AppMediaUploadShell(onTap: _noop),
                ],
              ),
            ),
          ]),
          section('Repository states', [
            AppListSurface(
              isEmpty: true,
              emptyTitle: 'No job cards yet',
              emptyMessage: 'Create the first job card to get started.',
              emptyActionLabel: 'New job card',
              onEmptyAction: _noop,
              child: const SizedBox.shrink(),
            ),
            const SizedBox(height: 8),
            AppListSurface(
              isError: true,
              errorMessage: 'Could not load the workshop queue.',
              errorDetails: 'The service is temporarily unavailable.',
              onRetry: _noop,
              child: const SizedBox.shrink(),
            ),
          ]),
          section('Actions', [
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
