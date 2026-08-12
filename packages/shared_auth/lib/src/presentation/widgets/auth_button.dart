import 'package:flutter/material.dart';
import 'package:shared_auth/src/presentation/widgets/auth_surface.dart';

class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const AuthButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AuthPrimaryButton(
      label: text,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
    );
  }
}
