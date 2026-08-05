import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

class AdvisorDivider extends StatelessWidget {
  const AdvisorDivider({super.key});

  @override
  Widget build(BuildContext context) => Container(
    height: 1,
    color: AppColors.line,
    margin: const EdgeInsets.symmetric(vertical: 4),
  );
}
