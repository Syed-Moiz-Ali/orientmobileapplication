import 'package:flutter/material.dart';
import 'package:orientmobileapplication/core/theme/app_colors.dart';
import 'package:orientmobileapplication/core/theme/app_dimensions.dart';
import 'package:orientmobileapplication/features/crm_dasboard/presentation/crm_constants.dart';

class CrmSurfaceCard extends StatelessWidget {
  final Widget child;
  const CrmSurfaceCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.s16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.r18),
        border: Border.all(color: CrmColors.border),
        boxShadow: [
          BoxShadow(
            color: CrmColors.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class CrmCardTitle extends StatelessWidget {
  final String text;
  const CrmCardTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      color: CrmColors.textH,
      fontSize: 16,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.3,
    ),
  );
}
