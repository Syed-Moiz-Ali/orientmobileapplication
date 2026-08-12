import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

class CardTitle extends StatelessWidget {
  final String text;
  const CardTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: AppTextStyles.button(color: AppColors.textPrimary),
  );
}
