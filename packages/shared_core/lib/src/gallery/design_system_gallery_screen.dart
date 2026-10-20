import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_spacing.dart';
import 'package:shared_core/src/widgets/app_dropdown.dart';
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
