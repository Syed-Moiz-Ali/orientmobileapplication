import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:staff_app/core/local/sync_providers.dart';
import 'package:staff_app/core/router/app_router.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_providers.dart';
import 'package:staff_app/features/supervisor/presentation/providers/supervisor_providers.dart';

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
          final dio = createDio(appName: 'staff');
          dio.interceptors.add(AuthInterceptor(ref, dio));
          return dio;
        }),
      ],
      child: const StaffApp(),
    ),
  );
}

class StaffApp extends ConsumerStatefulWidget {
  const StaffApp({super.key});

  @override
  ConsumerState<StaffApp> createState() => _StaffAppState();
}

class _StaffAppState extends ConsumerState<StaffApp> {
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  @override
  void initState() {
    super.initState();
    // Retry offline media uploads whenever connectivity returns.
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      final online = results.any((r) => r != ConnectivityResult.none);
      if (online) {
        flushPendingMediaUploads(ref);
      }
    });
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final brand = ref.watch(brandConfigProvider);
    // FE-FIX (pre-deployment): on resume, refresh each role's live data so a
    // booking assigned by the supervisor appears immediately for the advisor
    // and a completed job shows up in the supervisor's review tab.
    return ResumeRefreshScope(
      onResumed: () async {
        final sup = ref.read(supervisorDashboardProvider.notifier);
        await sup.refreshQueue();
        await sup.refreshReview();
        await sup.loadNotifications();
        // advisorRefreshProvider is a tick counter — bumping it reloads the
        // advisor dashboard/jobs on resume.
        ref.read(advisorRefreshProvider.notifier).state++;
      },
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: router,
        title: brand.appName,
        theme: AppTheme.light(brand),
      ),
    );
  }
}
