import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

class AdvisorHandle extends StatelessWidget {
  const AdvisorHandle({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.line,
        borderRadius: BorderRadius.circular(AppDimensions.r2),
      ),
    ),
  );
}

