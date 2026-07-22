import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orientmobileapplication/core/errors/app_error_handler.dart';
import 'package:orientmobileapplication/core/errors/logger_provider.dart';
import 'package:orientmobileapplication/core/local/hive/hive_registry.dart';
import 'package:orientmobileapplication/core/theme/app_theme.dart';
import 'package:orientmobileapplication/core/router/app_router.dart';

// ─── Entry point ──────────────────────────────────────────────────────────────
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final logger = createLogger();
  AppErrorHandler.init(logger);

  await HiveRegistry.initHive();

  runApp(
    ProviderScope(
      overrides: [loggerProvider.overrideWithValue(logger)],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      title: 'Orient Mobile',
      theme: AppTheme.light,
    );
  }
}
