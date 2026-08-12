import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

class FormLabel extends StatelessWidget {
  final String text;
  const FormLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: AppTextStyles.bodySmall(color: AppColors.text3),
  );
}
