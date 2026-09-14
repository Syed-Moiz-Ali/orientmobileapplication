import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:customer_app/core/router/app_router.dart';
import 'package:customer_app/core/local/sync_providers.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await EnvironmentConfig.init();
  } catch (e, _) {
    debugPrint('EnvironmentConfig init failed: $e');
  }

  final logger = createLogger();

  try {
    AppErrorHandler.init(logger);
  } catch (e, _) {
    debugPrint('AppErrorHandler init failed: $e');
  }

  try {
    await HiveRegistry.initHive();
  } catch (e, _) {
    debugPrint('HiveRegistry init failed: $e');
  }

  try {
    await PushNotificationService.instance.initialize();
  } catch (e, _) {
    debugPrint('PushNotificationService init failed: $e');
  }

  runApp(
    ProviderScope(
      overrides: [
        loggerProvider.overrideWithValue(logger),
        dioClientProvider.overrideWith((ref) {
          final dio = createDio(appName: 'customer');
          dio.interceptors.add(AuthInterceptor(ref, dio));
          return dio;
        }),
      ],
      child: const CustomerApp(),
    ),
  );
}

class CustomerApp extends ConsumerWidget {
  const CustomerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final brand = ref.watch(brandConfigProvider);
    ref.watch(syncEngineProvider);
    // FE-FIX (pre-deployment): refresh on app-resume so cross-app changes
    // (booking confirmed, estimate awaiting approval, invoice ready) appear
    // as soon as the customer returns to the app.
    return ResumeRefreshScope(
      onResumed: () async {
        await ref.read(syncEngineProvider).syncAll();
        final notifier = ref.read(customerDashboardProvider.notifier);
        await notifier.refresh();
        ref.invalidate(customerBookingsProvider);
        ref.invalidate(customerApprovalsProvider);
      },
      child: AuthenticatedPushNotificationScope(
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: router,
          title: brand.appName,
          theme: AppTheme.light(brand),
          darkTheme: AppTheme.dark(brand),
          themeMode: ThemeMode.light,
        ),
      ),
    );
  }
}
