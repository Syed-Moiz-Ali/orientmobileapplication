import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_radius.dart';
import 'package:shared_core/src/theme/app_spacing.dart';
import 'package:shared_core/src/widgets/app_app_bar.dart';
import 'package:shared_core/src/widgets/app_avatar.dart';
import 'package:shared_core/src/widgets/app_badge.dart';
import 'package:shared_core/src/widgets/app_banner.dart';
import 'package:shared_core/src/widgets/app_bottom_nav.dart';
import 'package:shared_core/src/widgets/app_nav_rail.dart';
import 'package:shared_core/src/widgets/app_scaffold.dart';
import 'package:shared_core/src/widgets/app_segmented_control.dart';
import 'package:shared_core/src/widgets/app_chip.dart';
import 'package:shared_core/src/widgets/app_data_row.dart';
import 'package:shared_core/src/widgets/app_divider.dart';
import 'package:shared_core/src/widgets/app_empty_state.dart';
import 'package:shared_core/src/widgets/app_error_state.dart';
import 'package:shared_core/src/widgets/app_dropdown.dart';
import 'package:shared_core/src/widgets/app_info_tooltip.dart';
import 'package:shared_core/src/widgets/app_list_tile.dart';
import 'package:shared_core/src/widgets/app_loader.dart';
import 'package:shared_core/src/widgets/app_network_image.dart';
import 'package:shared_core/src/widgets/app_progress_bar.dart';
import 'package:shared_core/src/widgets/app_section.dart';
import 'package:shared_core/src/widgets/app_shimmer_skeleton.dart';
import 'package:shared_core/src/widgets/app_settings_tile.dart';
import 'package:shared_core/src/widgets/app_stat_tile.dart';
import 'package:shared_core/src/widgets/app_status_chip.dart';
import 'package:shared_core/src/widgets/app_surface_card.dart';
import 'package:shared_core/src/widgets/app_icon_button.dart';
import 'package:shared_core/src/widgets/app_input_field.dart';
import 'package:shared_core/src/widgets/app_pill_button.dart';
import 'package:shared_core/src/widgets/app_search_bar.dart';
import 'package:shared_core/src/widgets/app_selection_tiles.dart';
import 'package:shared_core/src/widgets/app_text_button.dart';

/// Debug-only design-system gallery (phase 1, grows per part).
///
/// Not exported from the package barrel: open it via
/// `packages/shared_core/example/gallery_main.dart` or pump sections
/// directly in golden tests. Sections are public widgets so capture tests
/// can render one part at a time (keeps goldens small and deterministic).
class DesignSystemGalleryScreen extends StatelessWidget {
  const DesignSystemGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Design System Gallery')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: const [
          GallerySectionTitle('Buttons (1a)'),
          ButtonsGallerySection(),
          GallerySectionTitle('Inputs (1b)'),
          InputsGallerySection(),
          GallerySectionTitle('Surfaces (1c-i)'),
          SurfacesGallerySection(),
          GallerySectionTitle('Identity (1c-ii)'),
          IdentityGallerySection(),
          GallerySectionTitle('Feedback (1d-i)'),
          FeedbackGallerySection(),
          GallerySectionTitle('Loading (1d-ii)'),
          LoadingGallerySection(),
          GallerySectionTitle('Frame & navigation (1e-i)'),
          FrameGallerySection(),
        ],
      ),
    );
  }
}

/// Small section heading used across gallery parts.
class GallerySectionTitle extends StatelessWidget {
  final String text;

  const GallerySectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      // Full-width + start-aligned: identical layout logic in LTR and RTL
      // (right edge in RTL, left edge in LTR), never clipped by the column.
      child: SizedBox(
        width: double.infinity,
        child: Text(
          text,
          textAlign: TextAlign.start,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

/// 1a buttons section: every variant x size x key state, plus icon and text
/// buttons. Kept on one scrollable column for the capture harness.
class ButtonsGallerySection extends StatelessWidget {
  const ButtonsGallerySection({super.key});

  @override
  Widget build(BuildContext context) {
    // Labels are full-width + start-aligned so LTR and RTL use the same
    // layout logic (right edge in RTL); Wrap content follows suit.
    Widget row(String label, List<Widget> children) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                label,
                textAlign: TextAlign.start,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(spacing: AppSpacing.sm, runSpacing: AppSpacing.sm, children: children),
            ],
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        row('Primary sizes', [
          SizedBox(
            width: 220,
            child: AppPillButton.primary(
                label: 'Continue', onPressed: () {}, isExpanded: false),
          ),
          SizedBox(
            width: 220,
            child: AppPillButton.primary(
              label: 'Continue',
              onPressed: () {},
              size: AppPillButtonSize.medium,
              isExpanded: false,
            ),
          ),
          SizedBox(
            width: 220,
            child: AppPillButton.primary(
              label: 'Continue',
              onPressed: () {},
              size: AppPillButtonSize.small,
              isExpanded: false,
            ),
          ),
        ]),
        row('Variants', [
          SizedBox(
            width: 220,
            child: AppPillButton.secondary(
                label: 'Secondary', onPressed: () {}, isExpanded: false),
          ),
          SizedBox(
            width: 220,
            child: AppPillButton.ghost(
                label: 'Ghost link', onPressed: () {}),
          ),
          SizedBox(
            width: 220,
            child: AppPillButton.destructive(
                label: 'Delete', onPressed: () {}, isExpanded: false),
          ),
          SizedBox(
            width: 220,
            child: AppPillButton.success(
                label: 'Approve', onPressed: () {}, isExpanded: false),
          ),
        ]),
        row('States (disabled / loading)', [
          SizedBox(
            width: 220,
            child: const AppPillButton.primary(
                label: 'Disabled', onPressed: null, isExpanded: false),
          ),
          SizedBox(
            width: 220,
            child: AppPillButton.primary(
              label: 'Saving changes',
              onPressed: () {},
              isExpanded: false,
              isLoading: true,
            ),
          ),
        ]),
        row('Leading icons + RTL mirror', [
          SizedBox(
            width: 220,
            child: AppPillButton.primary(
              label: 'Next',
              onPressed: () {},
              icon: Icons.arrow_forward_rounded,
              isExpanded: false,
            ),
          ),
          SizedBox(
            width: 220,
            child: AppPillButton.secondary(
              label: 'Back',
              onPressed: () {},
              icon: Icons.arrow_back_rounded,
              isExpanded: false,
            ),
          ),
        ]),
        row('Icon buttons', [
          AppIconButton(
              icon: Icons.arrow_back_rounded,
              onPressed: () {},
              tooltip: 'Back'),
          AppIconButton(
              icon: Icons.notifications_outlined,
              onPressed: () {},
              tooltip: 'Notifications',
              bordered: true),
          const AppIconButton(
              icon: Icons.add, onPressed: null, tooltip: 'Disabled'),
        ]),
        row('Text buttons', [
          AppTextButton(label: 'See all', onPressed: () {}),
          AppTextButton(label: 'Try again', onPressed: () {}),
          const AppTextButton(label: 'Disabled', onPressed: null),
        ]),
      ],
    );
  }
}

/// 1b inputs section: text field variants, search bars, dropdowns, tiles.
///
/// Includes the Arabic-label + LTR-email `forceLtr` demo: the label follows
/// the locale while the value stays left-aligned LTR (see AppInputField).
class InputsGallerySection extends StatefulWidget {
  const InputsGallerySection({super.key});

  @override
  State<InputsGallerySection> createState() => _InputsGallerySectionState();
}

class _InputsGallerySectionState extends State<InputsGallerySection> {
  final TextEditingController _searchController =
      TextEditingController(text: 'booking');
  String? _branch = 'Deira';
  bool _notify = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppInputField(
          label: 'Email',
          hint: 'name@company.com',
          helper: 'Work email only',
          keyboardType: TextInputType.emailAddress,
          forceLtr: true,
        ),
        const SizedBox(height: AppSpacing.lg),
        const AppInputField(
          label: 'البريد الإلكتروني',
          hint: 'name@company.com',
          keyboardType: TextInputType.emailAddress,
          forceLtr: true,
        ),
        const SizedBox(height: AppSpacing.lg),
        const AppInputField(
          label: 'Password',
          obscureText: true,
          passwordToggle: true,
        ),
        const SizedBox(height: AppSpacing.lg),
        const AppInputField(
          label: 'Phone',
          hint: 'Enter a valid phone number',
          error: 'Enter at least 8 digits',
          keyboardType: TextInputType.phone,
          forceLtr: true,
        ),
        const SizedBox(height: AppSpacing.lg),
        const AppInputField(
          label: 'Disabled field',
          hint: 'Cannot edit',
          enabled: false,
        ),
        const SizedBox(height: AppSpacing.lg),
        const AppInputField(
          label: 'Notes (multiline)',
          hint: 'Add details',
          maxLines: 3,
          showCounter: true,
          maxLength: 280,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppSearchBar(hint: 'Search bookings', onChanged: (_) {}),
        const SizedBox(height: AppSpacing.lg),
        AppSearchBar(controller: _searchController, onChanged: (_) {}),
        const SizedBox(height: AppSpacing.lg),
        AppDropdown<String>(
          label: 'Branch',
          options: const ['Deira', 'Sharjah', 'Ajman'],
          value: _branch,
          onChanged: (v) => setState(() => _branch = v),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppCheckTile(
          title: 'Email notifications',
          subtitle: 'Booking updates and receipts',
          value: _notify,
          onChanged: (v) => setState(() => _notify = v),
        ),
        AppSwitchTile(
          title: 'Dark mode',
          value: false,
          onChanged: (_) {},
        ),
        AppRadioTile<String>(
          title: 'Deira branch',
          value: 'deira',
          groupValue: 'deira',
          onChanged: (_) {},
        ),
        const AppCheckTile(title: 'Disabled option', value: false, onChanged: null),
      ],
    );
  }
}

/// 1c-i surfaces section: cards, sections, list/settings tiles, dividers,
/// data rows. Grouped tiles sit inside one card with 72 px inset dividers;
/// the nesting demo shows the allowed pattern (surfaceAlt block in a card,
/// never a bordered card in a bordered card).
class SurfacesGallerySection extends StatefulWidget {
  const SurfacesGallerySection({super.key});

  @override
  State<SurfacesGallerySection> createState() => _SurfacesGallerySectionState();
}

class _SurfacesGallerySectionState extends State<SurfacesGallerySection> {
  bool _notify = true;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // The ar locale loads the Plex Arabic family (see capture harness); the
    // en locale loads Jakarta only, so the Arabic-script demo row renders
    // ONLY here — LTR captures would otherwise ship tofu boxes.
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSection(
          title: 'Section heading',
          subtitle: 'titleMedium + 12 px gap to content',
          seeAllLabel: 'See all',
          onSeeAll: () {},
          child: AppSurfaceCard(
            headerTitle: 'Bordered card (default)',
            child: Text(
              'Surface, radius 16, 1 px border, padding 20.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppSurfaceCard(
          outlined: false,
          headerTitle: 'Elevated card',
          child: Text(
            'Shadow e1, no border (light). Dark always uses a border.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppSurfaceCard(
          headerTitle: 'Tappable card',
          onTap: () {},
          showChevron: true,
          semanticLabel: 'Open booking details',
          child: Text(
            'Whole card >= 48 dp, ripple + chevron (mirrors in RTL).',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppSurfaceCard(
          headerTitle: 'Nesting rule demo',
          footer: Text(
            'Footer block sits below the body.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Text(
              'Allowed: a surfaceAlt block inside a card. '
              'Never a bordered card inside a bordered card.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppSection(
          title: 'Grouped tiles',
          subtitle: 'One card, 72 px inset dividers',
          seeAllLabel: 'See all',
          onSeeAll: () {},
          child: AppSurfaceCard(
            padding: EdgeInsets.zero,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppListTile(
                  leadingIcon: Icons.build_outlined,
                  title: 'Oil change',
                  subtitle: 'Due in 2 weeks',
                  valueText: 'AED 240',
                  onTap: () {},
                ),
                const AppDivider.inset(),
                AppListTile(
                  leadingIcon: Icons.notifications_outlined,
                  accentLeading: true,
                  title: 'Reminder sent',
                  subtitle: 'Yesterday at 18:04',
                  onTap: () {},
                ),
                const AppDivider.inset(),
                const AppListTile(
                  leadingIcon: Icons.receipt_long_outlined,
                  title: 'Static row',
                  subtitle: 'No tap target, no chevron',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppSection(
          title: 'Settings tiles',
          child: AppSurfaceCard(
            padding: EdgeInsets.zero,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppSettingsTile.switchTile(
                  leadingIcon: Icons.notifications_outlined,
                  title: 'Push notifications',
                  subtitle: 'Booking updates and receipts',
                  value: _notify,
                  onChanged: (v) => setState(() => _notify = v),
                ),
                const AppDivider.inset(),
                const AppSettingsTile.switchTile(
                  leadingIcon: Icons.dark_mode_outlined,
                  title: 'Dark mode',
                  subtitle: 'Disabled variant',
                  value: false,
                  onChanged: null,
                ),
                const AppDivider.inset(),
                AppSettingsTile(
                  leadingIcon: Icons.language_rounded,
                  title: 'Language',
                  subtitle: 'Value + chevron variant',
                  valueText: 'English',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        const AppDivider(),
        const SizedBox(height: AppSpacing.md),
        Text('Dividers: full-bleed hairline above, inset below',
            style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: AppSpacing.md),
        const AppDivider.inset(),
        const SizedBox(height: AppSpacing.xl),
        AppSection(
          title: 'Data rows',
          child: AppSurfaceCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppDataRow(
                    label: 'Invoice total', value: 'AED 1,240.00'),
                const SizedBox(height: AppSpacing.md),
                const AppDataRow(label: 'Status', value: 'Active'),
                const SizedBox(height: AppSpacing.md),
                if (arabic)
                  const AppDataRow(
                      label: 'الحالة', value: 'AED 1,240.00')
                else
                  const AppDataRow(label: 'Reference', value: 'INV-2041'),
                const SizedBox(height: AppSpacing.md),
                const AppDataRow(
                  label: 'A very long label that keeps wrapping instead of '
                      'clipping at large text scales',
                  value: '+AED 240.00',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// 1d-i feedback section: stat tiles (singles, delta rows, 2-col grid),
/// progress bars across the auto-tone thresholds, empty + error states, and
/// all four banner variants (one with an action, one dismissible).
class FeedbackGallerySection extends StatefulWidget {
  const FeedbackGallerySection({super.key});

  @override
  State<FeedbackGallerySection> createState() => _FeedbackGallerySectionState();
}

class _FeedbackGallerySectionState extends State<FeedbackGallerySection> {
  bool _showSyncBanner = true;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    Widget row(String label, Widget child) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '\u2066$label\u2069',
                textAlign: TextAlign.start,
                style: textTheme.labelMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              child,
            ],
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        row(
          'Stat tiles (label + tabular value + caption)',
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppStatTile(
                label: 'Total revenue',
                value: 'AED 12,450',
                caption: 'This month',
              ),
              SizedBox(height: AppSpacing.md),
              AppStatTile(
                label: 'Active jobs',
                value: '24',
                large: true,
              ),
            ],
          ),
        ),
        row(
          'Delta rows (arrow + sign + semantic ink, never color alone)',
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppStatTile(
                label: 'Completion rate',
                value: '86%',
                deltaText: '+4 pts vs last week',
                deltaUp: true,
              ),
              SizedBox(height: AppSpacing.md),
              AppStatTile(
                label: 'Overdue jobs',
                value: '7',
                deltaText: '+2 vs yesterday',
                deltaUp: false,
              ),
              SizedBox(height: AppSpacing.md),
              AppStatTile(
                label: 'Pending review',
                value: '3',
                deltaText: 'No change',
              ),
            ],
          ),
        ),
        row(
          '2-column stat grid (12 px gap)',
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppStatTile(
                  label: 'Open',
                  value: '18',
                  deltaText: '+3 today',
                  deltaUp: true,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppStatTile(
                  label: 'Delayed',
                  value: '5',
                  deltaText: '-1 today',
                  deltaUp: false,
                ),
              ),
            ],
          ),
        ),
        row(
          'Progress bars (auto tone: accent / success / warning / error)',
          const Column(
            children: [
              AppProgressBar(
                value: 0.15,
                label: '15% of 90% limit',
              ),
              SizedBox(height: AppSpacing.md),
              AppProgressBar(
                value: 0.62,
                label: '62% of 90% limit',
              ),
              SizedBox(height: AppSpacing.md),
              AppProgressBar(
                value: 0.82,
                label: '82% of 90% limit',
              ),
              SizedBox(height: AppSpacing.md),
              AppProgressBar(
                value: 0.95,
                label: '95% of 90% limit',
              ),
            ],
          ),
        ),
        row(
          'Empty state (64 px circle, title, 2-line message, action)',
          AppEmptyState(
            icon: Icons.inbox_outlined,
            title: 'No bookings yet',
            message: 'New bookings will appear here once customers book.',
            actionLabel: 'New booking',
            onAction: () {},
          ),
        ),
        row(
          'Error state (friendly message + Try again, live region)',
          AppErrorState(
            title: 'Could not load bookings',
            message: 'Check your connection and try again.',
            onRetry: () {},
          ),
        ),
        row(
          'Banners (info / warning / error / success)',
          Column(
            children: [
              AppBanner(
                kind: AppBannerKind.info,
                message: 'Sync is up to date. Last checked 2 min ago.',
              ),
              const SizedBox(height: AppSpacing.sm),
              AppBanner(
                kind: AppBannerKind.warning,
                message: 'Data is delayed. Showing the last update.',
                actionLabel: 'Retry',
                onAction: () {},
              ),
              const SizedBox(height: AppSpacing.sm),
              AppBanner(
                kind: AppBannerKind.error,
                message: 'Upload failed. Your changes are saved on this device.',
                actionLabel: 'Try again',
                onAction: () {},
                onDismiss: () {},
              ),
              const SizedBox(height: AppSpacing.sm),
              const AppBanner(
                kind: AppBannerKind.success,
                message: 'All changes synced.',
              ),
            ],
          ),
        ),
        if (_showSyncBanner)
          row(
            'Dismissible banner (tap × to hide)',
            AppBanner(
              kind: AppBannerKind.info,
              message: 'You are offline. Changes will sync when you reconnect.',
              onDismiss: () => setState(() => _showSyncBanner = false),
            ),
          ),
      ],
    );
  }
}
/// 1c-ii identity section: avatars, badges, filter chips, status chips,
/// info tooltips. The success/info row places the two closest soft fills
/// side by side on purpose (see the identity tests for the measured colour
/// difference and the dot + label judgement).
class IdentityGallerySection extends StatefulWidget {
  const IdentityGallerySection({super.key});

  @override
  State<IdentityGallerySection> createState() => _IdentityGallerySectionState();
}

class _IdentityGallerySectionState extends State<IdentityGallerySection> {
  bool _openOnly = true;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final arabic = Localizations.localeOf(context).languageCode == 'ar';

    Widget row(String label, Widget child) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                label,
                textAlign: TextAlign.start,
                style: textTheme.labelMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              child,
            ],
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        row(
          'Avatars (initials, 24 / 32 / 40 / 56)',
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const AppAvatar(
                  name: 'Layla Haddad', size: AppAvatarSize.extraSmall),
              const AppAvatar(name: 'Layla Haddad', size: AppAvatarSize.small),
              const AppAvatar(name: 'Layla Haddad'),
              const AppAvatar(name: 'Layla Haddad', size: AppAvatarSize.large),
              if (arabic)
                const AppAvatar(name: 'ليلى حداد')
              else
                const AppAvatar(name: 'Omar Farouk'),
              AppAvatar(name: 'Tappable advisor', onTap: () {}),
            ],
          ),
        ),
        row(
          'Badges (accent 3, error 7, capped 99+)',
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: const [
              AppBadge(count: 3),
              AppBadge(count: 7, kind: AppBadgeKind.error),
              AppBadge(count: 120),
            ],
          ),
        ),
        row(
          'Filter chips (selected carries a check, not just color)',
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              AppChip(
                label: 'Open',
                selected: _openOnly,
                onSelected: (v) => setState(() => _openOnly = v),
              ),
              AppChip(label: 'Delayed', onSelected: (_) {}),
              const AppChip(label: 'Disabled'),
            ],
          ),
        ),
        row(
          'Status chips (dot + human label, all six kinds)',
          const Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              AppStatusChip(label: 'Active', kind: AppStatusKind.success),
              AppStatusChip(label: 'Delayed', kind: AppStatusKind.warning),
              AppStatusChip(label: 'Failed', kind: AppStatusKind.error),
              AppStatusChip(label: 'Syncing', kind: AppStatusKind.info),
              AppStatusChip(label: 'Idle', kind: AppStatusKind.neutral),
              AppStatusChip(label: 'Featured', kind: AppStatusKind.accent),
            ],
          ),
        ),
        row(
          'Closest pair side by side (success-soft vs info-soft)',
          const Row(
            children: [
              AppStatusChip(label: 'Active', kind: AppStatusKind.success),
              SizedBox(width: AppSpacing.sm),
              AppStatusChip(label: 'Syncing', kind: AppStatusKind.info),
            ],
          ),
        ),
        row(
          'Info tooltip (tap the icon; 48 dp target, 16 px glyph)',
          Row(
            children: [
              Flexible(
                child: Text(
                  'Watching the market',
                  style: textTheme.bodyMedium,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              const AppInfoTooltip(
                message: 'The bot is waiting for a clear signal before '
                    'acting. Nothing is wrong with your settings.',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 1d-ii loading section: blocking loader, skeleton shapes mirroring the
/// card/tile layout, and network images (placeholder + error fallback).
///
/// Capture note: the shimmer rows animate (1200 ms loop); the capture harness
/// pumps to a fixed t=900 ms frame (300 ms + 600 ms) so goldens are
/// deterministic. The remote URLs
/// below have no network in `flutter_test`, so captures deterministically
/// show the error fallback; on a real device they load the photos.
class LoadingGallerySection extends StatelessWidget {
  const LoadingGallerySection({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    Widget row(String label, Widget child) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '\u2066$label\u2069',
                textAlign: TextAlign.start,
                style: textTheme.labelMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              child,
            ],
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        row(
          'Blocking loader (28 px accent spinner, short actions only)',
          const AppLoader(label: 'Saving changes'),
        ),
        row(
          'Skeleton bar + card (same radii as the card they stand in for)',
          const Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppShimmerSkeleton(),
              SizedBox(height: AppSpacing.md),
              AppShimmerSkeleton.card(height: 96),
            ],
          ),
        ),
        row(
          'Text block + list rows (mirror the tile layout)',
          const Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppShimmerSkeleton.textBlock(),
              SizedBox(height: AppSpacing.lg),
              AppShimmerSkeleton.listRows(rows: 3),
            ],
          ),
        ),
        row(
          'Network image (shimmer holds the size; error fallback in captures)',
          const AppNetworkImage(
            imageUrl: 'https://example.com/cover.jpg',
            height: 160,
            semanticLabel: 'Service cover photo',
          ),
        ),
        row(
          'Network image radii (circle avatar falls back the same way)',
          const Row(
            children: [
              AppNetworkImage(
                imageUrl: 'https://example.com/avatar.jpg',
                width: 64,
                height: 64,
                radius: AppRadius.pill,
                semanticLabel: 'Advisor photo',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 1e-i frame & navigation section: scaffold frame (sticky action +
/// pull-to-refresh), standard + large app bars, bottom nav (5 items, badge),
/// rail variant at a fixed gallery height, segmented controls + pill tabs.
class FrameGallerySection extends StatefulWidget {
  const FrameGallerySection({super.key});

  @override
  State<FrameGallerySection> createState() => _FrameGallerySectionState();
}

class _FrameGallerySectionState extends State<FrameGallerySection> {
  int _navIndex = 0;
  String _range = 'Week';
  String _longRange = 'Last 30 days';
  String _filter = 'Open';

  static const _navItems = [
    AppBottomNavItem(label: 'Home', icon: Icons.home_outlined),
    AppBottomNavItem(
        label: 'Bookings', icon: Icons.calendar_month_outlined, badgeCount: 3),
    AppBottomNavItem(label: 'Activity', icon: Icons.timeline_outlined),
    AppBottomNavItem(label: 'Wallet', icon: Icons.wallet_outlined),
    AppBottomNavItem(label: 'More', icon: Icons.more_horiz_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    Widget row(String label, Widget child) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '\u2066$label\u2069',
                textAlign: TextAlign.start,
                style: textTheme.labelMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              child,
            ],
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        row(
          'Scaffold frame (sticky action + pull-to-refresh wrapper)',
          SizedBox(
            height: 340,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: AppScaffold(
                appBar: AppAppBar(
                  title: 'Bookings',
                  showBack: true,
                  showDivider: true,
                  onBack: () {},
                ),
                onRefresh: () async {},
                stickyActionLabel: 'Save changes',
                onStickyAction: () {},
                stickySecondaryLabel: 'Discard',
                onStickySecondary: () {},
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Today', style: textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      // Bidi-isolated so edge punctuation never flips in
                      // RTL paragraphs (same rule as the section labels).
                      '\u2066Pull down to refresh. The primary action stays '
                      'pinned above the safe area.\u2069',
                      style: textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        row(
          'App bar (56, left title, centered, back + actions)',
          Column(
            children: [
              AppAppBar(
                title: 'Bookings',
                showBack: true,
                onBack: () {},
              ),
              const SizedBox(height: AppSpacing.sm),
              AppAppBar(
                title: 'Activity',
                centerTitle: true,
                actions: [
                  AppIconButton(
                    icon: Icons.notifications_outlined,
                    onPressed: () {},
                    tooltip: 'Notifications',
                  ),
                ],
              ),
            ],
          ),
        ),
        row(
          'Large collapsing title (32 -> 20, pinned)',
          SizedBox(
            height: 280,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: CustomScrollView(
                slivers: [
                  AppAppBar.large(
                    title: 'Activity',
                    showBack: true,
                    onBack: () {},
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate([
                      for (var i = 0; i < 6; i++)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.sm,
                          ),
                          child: Text(
                            '\u2066Row ${i + 1}: scroll to collapse the '
                            'title.\u2069',
                            style: textTheme.bodyMedium,
                          ),
                        ),
                    ]),
                  ),
                ],
              ),
            ),
          ),
        ),
        row(
          'Bottom nav (5 items, badge, unselected rest)',
          AppBottomNav(
            items: _navItems,
            currentIndex: _navIndex,
            onTap: (i) => setState(() => _navIndex = i),
          ),
        ),
        row(
          'Rail variant (medium/expanded, fixed height in gallery)',
          SizedBox(
            height: 420,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: Row(
                children: [
                  AppNavRail(
                    items: _navItems,
                    currentIndex: _navIndex,
                    onTap: (i) => setState(() => _navIndex = i),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        '\u2066Content beside the rail.\u2069',
                        style: textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        row(
          'Segmented control (few options)',
          AppSegmentedControl<String>(
            options: const [
              AppSegmentedOption(value: 'Day', label: 'Day'),
              AppSegmentedOption(value: 'Week', label: 'Week'),
              AppSegmentedOption(value: 'Month', label: 'Month'),
            ],
            selected: _range,
            onChanged: (v) => setState(() => _range = v),
          ),
        ),
        row(
          'Segmented control (many options, scrollable)',
          AppSegmentedControl<String>.scrollable(
            options: const [
              AppSegmentedOption(value: 'Today', label: 'Today'),
              AppSegmentedOption(value: '7D', label: 'Last 7 days'),
              AppSegmentedOption(value: '30D', label: 'Last 30 days'),
              AppSegmentedOption(value: '90D', label: 'Last 90 days'),
              AppSegmentedOption(value: 'YTD', label: 'Year to date'),
              AppSegmentedOption(value: 'All', label: 'All time'),
            ],
            selected: _longRange,
            onChanged: (v) => setState(() => _longRange = v),
          ),
        ),
        row(
          'Pill tabs (scrollable row)',
          AppPillTabs<String>(
            options: const [
              AppSegmentedOption(value: 'All', label: 'All'),
              AppSegmentedOption(value: 'Open', label: 'Open'),
              AppSegmentedOption(value: 'Delayed', label: 'Delayed'),
              AppSegmentedOption(value: 'Done', label: 'Done'),
              AppSegmentedOption(value: 'Cancelled', label: 'Cancelled'),
            ],
            selected: _filter,
            onChanged: (v) => setState(() => _filter = v),
          ),
        ),
      ],
    );
  }
}
