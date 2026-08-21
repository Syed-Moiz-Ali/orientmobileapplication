import 'package:flutter/material.dart';
import 'package:shared_core/src/layout/app_responsive.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';

class AppActionBar extends StatelessWidget {
  final Widget primary;
  final List<Widget> secondary;

  const AppActionBar({
    super.key,
    required this.primary,
    this.secondary = const [],
  });

  @override
  Widget build(BuildContext context) {
    if (context.isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...secondary.map(
            (action) => Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.s8),
              child: action,
            ),
          ),
          primary,
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        for (final action in secondary) ...[
          action,
          const SizedBox(width: AppDimensions.s8),
        ],
        primary,
      ],
    );
  }
}
