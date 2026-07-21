import 'package:flutter/material.dart';
import 'package:orientmobileapplication/core/theme/app_colors.dart';
import 'package:orientmobileapplication/core/theme/app_text_styles.dart';

class FormLabel extends StatelessWidget {
  final String text;
  const FormLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: AppTextStyles.rajdhaniBodySmall(color: AppColors.text3),
  );
}
