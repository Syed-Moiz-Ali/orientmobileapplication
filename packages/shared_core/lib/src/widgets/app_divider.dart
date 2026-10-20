import 'package:flutter/material.dart';

/// Spec-C8 hairline divider (phase-1c-i).
///
/// 1 px, border token, Directional insets so grouped-tile dividers mirror in
/// RTL. Decorative: excluded from Semantics.
///
/// ```dart
/// Column(children: [
///   AppListTile(title: 'A', onTap: a),
///   AppDivider.inset(), // 72 px start inset between grouped tiles
///   AppListTile(title: 'B', onTap: b),
/// ])
/// ```
class AppDivider extends StatelessWidget {
  /// Start inset (mirrors in RTL). Null = full-bleed.
  final double? indent;

  /// End inset (mirrors in RTL).
  final double? endIndent;

  /// 1 px hairline by spec; override only for emphasis dividers.
  final double thickness;

  const AppDivider({
    super.key,
    this.indent,
    this.endIndent,
    this.thickness = 1,
  });

  /// Grouped-tile divider: 72 px start inset, 1 px border (spec C8).
  /// The inset mirrors in RTL (trailing 72 px instead of leading).
  const AppDivider.inset({
    super.key,
    this.thickness = 1,
  })  : indent = 72, // spec C8: 72 px grouped-tile start inset.
        endIndent = 0;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.outline;
    return ExcludeSemantics(
      child: Container(
        height: thickness,
        margin: EdgeInsetsDirectional.only(
          start: indent ?? 0,
          end: endIndent ?? 0,
        ),
        color: color,
      ),
    );
  }
}
