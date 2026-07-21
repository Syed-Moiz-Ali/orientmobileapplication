import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orientmobileapplication/core/theme/app_theme.dart';
import 'package:orientmobileapplication/core/router/app_router.dart';

// ─── Entry point ──────────────────────────────────────────────────────────────
void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      title: 'Orient Mobile',
      theme: AppTheme.light,
    );
  }
}
