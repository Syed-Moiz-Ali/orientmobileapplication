import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

class AdvisorSheet extends StatelessWidget {
  final Widget child;
  const AdvisorSheet({super.key, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.r28)),
    ),
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
    child: child,
  );
}

