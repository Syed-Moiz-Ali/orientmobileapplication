import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/src/theme/app_colors.dart';

/// FE-FIX (pre-deployment connectivity pass): a small, honest offline banner
/// shown under the app bar whenever the device has no network. The backend
/// queues offline writes (bookings, vehicles, work items), so users should
/// know their actions will sync later rather than silently disappear.
final connectivityStatusProvider =
    StreamProvider<ConnectivityResult>((ref) {
  return Connectivity().onConnectivityChanged.map((results) =>
      results.isNotEmpty ? results.first : ConnectivityResult.none);
});

class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(connectivityStatusProvider).value;
    if (status == null || status == ConnectivityResult.none) {
      return Container(
        width: double.infinity,
        color: AppColors.warningBorder.withValues(alpha: 0.9),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_rounded, size: 13, color: Colors.white),
            SizedBox(width: 6),
            Text(
              'Offline — your actions will sync when you reconnect',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
