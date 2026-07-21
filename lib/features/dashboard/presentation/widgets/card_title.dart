import 'package:flutter/material.dart';
import 'package:orientmobileapplication/core/theme/app_colors.dart';
import 'package:orientmobileapplication/core/theme/app_text_styles.dart';

class CardTitle extends StatelessWidget {
  final String text;
  const CardTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: AppTextStyles.rajdhaniButton(color: AppColors.textPrimary),
  );
}
