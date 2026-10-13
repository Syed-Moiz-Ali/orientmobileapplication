import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

/// Centered drag affordance at the top of an advisor sheet.
class AdvisorHandle extends StatelessWidget {
  const AdvisorHandle({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.outlineVariant,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
      ),
    ),
  );
}
