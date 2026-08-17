import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:customer_app/core/router/app_router.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvironmentConfig.init();

  final logger = createLogger();
  AppErrorHandler.init(logger);

  await HiveRegistry.initHive();

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
    // FE-FIX (pre-deployment): refresh on app-resume so cross-app changes
    // (booking confirmed, estimate awaiting approval, invoice ready) appear
    // as soon as the customer returns to the app.
    return ResumeRefreshScope(
      onResumed: () async {
        final notifier = ref.read(customerDashboardProvider.notifier);
        await notifier.refresh();
        ref.invalidate(customerBookingsProvider);
        ref.invalidate(customerApprovalsProvider);
      },
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: router,
        title: brand.appName,
        theme: AppTheme.light(brand),
        darkTheme: AppTheme.dark(brand),
        themeMode: ThemeMode.light,
      ),
    );
  }
}
