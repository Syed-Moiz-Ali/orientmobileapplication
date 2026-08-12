import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/src/theme/app_colors.dart';

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

    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      color: AppColors.warningBorder.withValues(alpha: 0.9),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off_rounded, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              'Offline - your actions will sync when you reconnect',
              textAlign: TextAlign.center,
              style: textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
