import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/src/theme/app_colors.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';

final connectivityStatusProvider = StreamProvider<ConnectivityResult>((ref) {
  return Connectivity().onConnectivityChanged.map((results) {
    return results.isNotEmpty ? results.first : ConnectivityResult.none;
  });
});

class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(connectivityStatusProvider).value;
    if (status != null && status != ConnectivityResult.none) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final background = Color.alphaBlend(
      AppColors.warning.withValues(alpha: 0.12),
      colors.surface,
    );

    return Semantics(
      liveRegion: true,
      label: 'Offline mode. Changes will sync when connection is restored.',
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: background,
          border: const Border(bottom: BorderSide(color: AppColors.warning)),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.s16,
          vertical: AppDimensions.s8,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 16,
              color: AppColors.warning,
            ),
            const SizedBox(width: AppDimensions.s8),
            Flexible(
              child: Text(
                'Offline mode — changes will sync when connection is restored',
                textAlign: TextAlign.center,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
