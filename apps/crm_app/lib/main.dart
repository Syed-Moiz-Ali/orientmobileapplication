import 'package:crm_app/l10n/gen/crm_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:crm_app/core/router/app_router.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_ui_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvironmentConfig.init();

  final logger = createLogger();
  AppErrorHandler.init(logger);

  await HiveRegistry.initHive();
  await PushNotificationService.instance.initialize();

  runApp(
    ProviderScope(
      overrides: [
        loggerProvider.overrideWithValue(logger),
        dioClientProvider.overrideWith((ref) {
          final dio = createDio(appName: 'crm');
          dio.interceptors.add(AuthInterceptor(ref, dio));
          return dio;
        }),
      ],
      child: const CrmApp(),
    ),
  );
}

class CrmApp extends ConsumerWidget {
  const CrmApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final brand = ref.watch(brandConfigProvider);
    final effectiveLocale = AppLocales.resolve(
      persisted: ref.watch(localeProvider),
      system: WidgetsBinding.instance.platformDispatcher.locale,
    );
    // FE-FIX (pre-deployment): reload CRM data on resume so new leads /
    // WhatsApp conversations appear without a manual refresh.
    return ResumeRefreshScope(
      onResumed: () => ref.read(crmUiProvider.notifier).refresh(),
      child: AuthenticatedPushNotificationScope(
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: router,
          title: brand.appName,
          onGenerateTitle: (context) =>
              CrmLocalizations.of(context)?.appTitle ?? brand.appName,
          locale: effectiveLocale,
          supportedLocales: AppLocales.supported,
          localizationsDelegates: const [
            CrmLocalizations.delegate,
            SharedCoreLocalizations.delegate,
            SharedAuthLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: AppTheme.light(brand, locale: effectiveLocale),
        ),
      ),
    );
  }
}
