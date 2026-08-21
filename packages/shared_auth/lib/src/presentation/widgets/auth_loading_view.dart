import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

class AuthLoadingView extends StatelessWidget {
  const AuthLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      body: Semantics(
        liveRegion: true,
        label: 'Restoring your secure session',
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusPanel,
                  ),
                ),
                child: Icon(
                  Icons.build_rounded,
                  color: colors.onPrimaryContainer,
                  size: 26,
                ),
              ),
              const SizedBox(height: AppDimensions.s16),
              Text(
                'Restoring your session',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppDimensions.s12),
              SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
