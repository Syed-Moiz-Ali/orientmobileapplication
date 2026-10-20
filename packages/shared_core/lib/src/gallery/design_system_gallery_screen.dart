import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_spacing.dart';
import 'package:shared_core/src/widgets/app_icon_button.dart';
import 'package:shared_core/src/widgets/app_pill_button.dart';
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
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.w700),
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
    Widget row(String label, List<Widget> children) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelMedium),
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
