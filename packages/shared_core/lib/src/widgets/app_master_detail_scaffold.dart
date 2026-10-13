import 'package:flutter/material.dart';
import 'package:shared_core/src/layout/app_responsive.dart';

/// Tablet/desktop **master–detail** template (spec §G).
///
/// * medium/expanded/large → list pane ([master], capped width) beside the
///   detail pane ([detail], flexible).
/// * compact (<600 px) → degrades to a single pane: the caller drives push
///   navigation and passes either pane as the visible one via [detailOpen]
///   (false = show [master], true = show [detail]).
///
/// Presentation only: selection, routing and back-stack stay with the caller.
/// Documented default for owner job cards (12/13A), customer bookings (15B/16)
/// and CRM leads (19A).
class AppMasterDetailScaffold extends StatelessWidget {
  final Widget master;
  final Widget detail;

  /// Whether a detail is selected. On compact it selects the visible pane; on
  /// wider layouts it toggles between [detail] and [placeholder].
  final bool detailOpen;

  /// Upper bound for the master pane width on wider layouts.
  final double masterMaxWidth;

  /// Lower bound for the master pane width on wider layouts.
  final double masterMinWidth;

  /// Shown in the detail pane when [detailOpen] is false (wider layouts only).
  final Widget? placeholder;

  const AppMasterDetailScaffold({
    super.key,
    required this.master,
    required this.detail,
    this.detailOpen = true,
    this.masterMaxWidth = 420,
    this.masterMinWidth = 280,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    final adaptive = context.adaptive;

    if (adaptive.isCompact) {
      return detailOpen ? detail : master;
    }

    final colors = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final masterWidth = masterMaxWidth.clamp(
          masterMinWidth,
          (width * 0.45).clamp(masterMinWidth, masterMaxWidth),
        );
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(width: masterWidth, child: master),
            _PaneDivider(color: colors.outline),
            Expanded(
              child: detailOpen
                  ? detail
                  : (placeholder ?? const SizedBox.shrink()),
            ),
          ],
        );
      },
    );
  }
}

/// Tablet/desktop **three-pane** template (catalog | editor | summary),
/// e.g. estimate builder (08), intake on large screens (07A).
///
/// * expanded/large → three panes with capped outer panes.
/// * medium → catalogue + editor (the trailing pane collapses into the editor).
/// * compact → a single pane: [second] when [secondVisible], otherwise [first].
class AppThreePaneScaffold extends StatelessWidget {
  final Widget first;
  final Widget second;
  final Widget third;

  /// Whether the editor pane holds a selection (drives the compact pane).
  final bool secondVisible;

  /// Whether the trailing summary pane is shown (wider layouts only).
  final bool thirdVisible;

  final double firstMaxWidth;
  final double firstMinWidth;
  final double thirdMaxWidth;
  final double thirdMinWidth;

  const AppThreePaneScaffold({
    super.key,
    required this.first,
    required this.second,
    required this.third,
    this.secondVisible = true,
    this.thirdVisible = true,
    this.firstMaxWidth = 300,
    this.firstMinWidth = 220,
    this.thirdMaxWidth = 340,
    this.thirdMinWidth = 240,
  });

  @override
  Widget build(BuildContext context) {
    final adaptive = context.adaptive;

    if (adaptive.isCompact) {
      return secondVisible ? second : first;
    }

    final colors = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final firstWidth = firstMaxWidth.clamp(
          firstMinWidth,
          (width * 0.3).clamp(firstMinWidth, firstMaxWidth),
        );
        final showThird = thirdVisible && adaptive.isExpanded;

        final children = <Widget>[
          SizedBox(width: firstWidth, child: first),
          _PaneDivider(color: colors.outline),
          Expanded(child: second),
        ];

        if (showThird) {
          final thirdWidth = thirdMaxWidth.clamp(
            thirdMinWidth,
            (width * 0.3).clamp(thirdMinWidth, thirdMaxWidth),
          );
          children.add(_PaneDivider(color: colors.outline));
          children.add(SizedBox(width: thirdWidth, child: third));
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        );
      },
    );
  }
}

class _PaneDivider extends StatelessWidget {
  final Color color;

  const _PaneDivider({required this.color});

  @override
  Widget build(BuildContext context) =>
      SizedBox(width: 1, child: ColoredBox(color: color));
}
