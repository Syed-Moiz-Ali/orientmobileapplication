import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:owner_app/core/router/app_router.dart';
import 'package:owner_app/features/dashboard/presentation/providers/dashboard_ui_providers.dart';
import 'package:owner_app/features/job_cards/presentation/providers/job_card_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvironmentConfig.init();

  final logger = createLogger();
  AppErrorHandler.init(logger);

  await HiveRegistry.initHive();

  runApp(ProviderScope(overrides: [loggerProvider.overrideWithValue(logger)], child: const OwnerApp()));
}

class OwnerApp extends ConsumerWidget {
  const OwnerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final brand = ref.watch(brandConfigProvider);
    // FE-FIX (pre-deployment): real dashboard + job-card reload on resume so
    // payments recorded by a customer and completions from the shop floor
    // show up without a manual pull.
    return ResumeRefreshScope(
      onResumed: () async {
        await ref.read(dashboardUiProvider.notifier).refresh();
        ref.read(jobCardsProvider.notifier).load();
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


