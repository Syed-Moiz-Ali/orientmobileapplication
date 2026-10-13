// Phase 00 visual design validation prototype.
//
// NOT SHIPPED. This app imports no production package and no production app
// imports it. Run instructions live in README.md.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'design/prototype_theme.dart';
import 'shell/prototype_shell.dart';

void main() {
  runApp(const PrototypeApp());
}

class PrototypeApp extends StatefulWidget {
  const PrototypeApp({super.key});

  @override
  State<PrototypeApp> createState() => _PrototypeAppState();
}

class _PrototypeAppState extends State<PrototypeApp> {
  Locale _locale = const Locale('en');
  ThemeMode _themeMode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    final arabic = _locale.languageCode == 'ar';
    return MaterialApp(
      title: 'Orient Design Prototype',
      debugShowCheckedModeBanner: false,
      locale: _locale,
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: PrototypeTheme.light(arabic: arabic),
      darkTheme: PrototypeTheme.dark(arabic: arabic),
      themeMode: _themeMode,
      home: PrototypeShell(
        locale: _locale,
        themeMode: _themeMode,
        onLocaleChanged: (locale) => setState(() => _locale = locale),
        onThemeChanged: (mode) => setState(() => _themeMode = mode),
      ),
    );
  }
}
