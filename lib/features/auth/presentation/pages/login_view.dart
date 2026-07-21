import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:orientmobileapplication/core/router/app_router.dart';
import 'package:orientmobileapplication/core/theme/app_colors.dart';
import 'package:orientmobileapplication/core/theme/app_dimensions.dart';
import 'package:orientmobileapplication/core/widgets/app_text_field.dart';
import 'package:orientmobileapplication/core/widgets/primary_button.dart';
import 'package:orientmobileapplication/features/auth/domain/entities/user_role.dart';
import 'package:orientmobileapplication/features/auth/presentation/providers/auth_providers.dart';
import 'package:orientmobileapplication/features/auth/presentation/providers/login_provider.dart';

class LoginView extends ConsumerWidget {
  final UserRole role;

  const LoginView({super.key, required this.role});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configs = ref.watch(roleConfigsProvider);
    final config = configs.firstWhere((c) => c.role == role);
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primary, AppColors.navy],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _LoginCard(
                config: config,
                role: role,
                usernameController: usernameController,
                passwordController: passwordController,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginCard extends ConsumerWidget {
  final dynamic config;
  final UserRole role;
  final TextEditingController usernameController;
  final TextEditingController passwordController;

  const _LoginCard({
    required this.config,
    required this.role,
    required this.usernameController,
    required this.passwordController,
  });

  String _getDashboardRoute(UserRole role) {
    switch (role) {
      case UserRole.advisor:
        return AppRoutes.advisorDashboard;
      case UserRole.technician:
        return AppRoutes.technicianDashboard;
      case UserRole.customer:
        return AppRoutes.customerPortal;
      case UserRole.supervisor:
        return AppRoutes.supervisorDashboard;
      case UserRole.owner:
        return AppRoutes.ownerDashboard;
      case UserRole.crmDashboard:
        return AppRoutes.crmDashboard;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginState = ref.watch(loginNotifierProvider);

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.r20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: config.iconBackgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(config.icon, color: Colors.white, size: 34),
                ),
                const SizedBox(height: 16),
                Text(
                  config.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  config.subtitle,
                  style: const TextStyle(fontSize: 13, color: AppColors.text3),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text(
            role == UserRole.customer ? 'Login ID / Mobile Number' : 'Username',
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          AppTextField(
            controller: usernameController,
            hint: config.usernamePlaceholder ?? 'Enter your username',
            prefixIcon: Icons.person_outline_rounded,
            onChanged: (_) =>
                ref.read(loginNotifierProvider.notifier).clearError(),
          ),
          const SizedBox(height: 16),
          const Text(
            'Password',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          AppTextField(
            controller: passwordController,
            hint: 'Enter your password',
            prefixIcon: Icons.lock_outline_rounded,
            obscureText: !loginState.isPasswordVisible,
            suffixIcon: GestureDetector(
              onTap: () => ref
                  .read(loginNotifierProvider.notifier)
                  .togglePasswordVisibility(),
              child: Icon(
                loginState.isPasswordVisible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.text4,
                size: 20,
              ),
            ),
            onChanged: (_) =>
                ref.read(loginNotifierProvider.notifier).clearError(),
          ),
          if (loginState.errorMessage != null) ...[
            const SizedBox(height: 10),
            Text(
              loginState.errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 12.5),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  context.push('/forgot-password/${role.name}');
                },
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'Login',
            isLoading: loginState.isLoading,
            backgroundColor: config.buttonColor,
            onPressed: () async {
              final success = await ref
                  .read(loginNotifierProvider.notifier)
                  .login(
                    role: role,
                    username: usernameController.text,
                    password: passwordController.text,
                  );
              if (success && context.mounted) {
                context.go(_getDashboardRoute(role));
              }
            },
          ),
        ],
      ),
    );
  }
}
