import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'concepts/concept_tokens.dart';
import 'concepts/concept_a_screens.dart';
import 'concepts/concept_b_screens.dart';
import 'concepts/concept_c_screens.dart';

void main() {
  runApp(const OrientConceptShowcaseApp());
}

class OrientConceptShowcaseApp extends StatefulWidget {
  const OrientConceptShowcaseApp({super.key});

  @override
  State<OrientConceptShowcaseApp> createState() => _OrientConceptShowcaseAppState();
}

class _OrientConceptShowcaseAppState extends State<OrientConceptShowcaseApp> {
  ConceptDirection _activeConcept = ConceptDirection.conceptA;
  ShowcaseScreen _activeScreen = ShowcaseScreen.staff;
  bool _isArabic = false;
  bool _isDark = false;
  _ViewportMode _viewport = _ViewportMode.mobile;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Orient 2026 UI/UX Concept Showcase',
      debugShowCheckedModeBanner: false,
      locale: _isArabic ? const Locale('ar') : const Locale('en'),
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF1F5F9),
        fontFamily: _isArabic ? 'IBMPlexSansArabic' : 'PlusJakartaSans',
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF090D16),
        fontFamily: _isArabic ? 'IBMPlexSansArabic' : 'PlusJakartaSans',
      ),
      home: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // --- Interactive Top Controller Bar ---
              _buildTopControllerBar(),

              // --- Main Viewport Canvas ---
              Expanded(
                child: Container(
                  color: _isDark ? const Color(0xFF020408) : const Color(0xFFE2E8F0),
                  child: Center(
                    child: _buildViewportFrame(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopControllerBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _isDark ? const Color(0xFF111827) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: _isDark ? const Color(0xFF1F2937) : const Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: Column(
        children: [
          // Row 1: Concept Selector & Global Controls
          Row(
            children: [
              // Concept Direction Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: _isDark ? const Color(0xFF1F2937) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _isDark ? const Color(0xFF374151) : const Color(0xFFCBD5E1),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<ConceptDirection>(
                    value: _activeConcept,
                    dropdownColor: _isDark ? const Color(0xFF1F2937) : Colors.white,
                    items: ConceptDirection.values.map((c) {
                      return DropdownMenuItem(
                        value: c,
                        child: Text(
                          c.title,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _activeConcept = val);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Viewport Dimension Switcher
              Container(
                decoration: BoxDecoration(
                  color: _isDark ? const Color(0xFF1F2937) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(3),
                child: Row(
                  children: [
                    _buildViewportButton(_ViewportMode.mobile, Icons.phone_iphone_rounded, '390'),
                    _buildViewportButton(_ViewportMode.tablet, Icons.tablet_mac_rounded, '768'),
                    _buildViewportButton(_ViewportMode.desktop, Icons.desktop_windows_rounded, '1280'),
                    _buildViewportButton(_ViewportMode.fluid, Icons.fullscreen_rounded, 'Fluid'),
                  ],
                ),
              ),
              const Spacer(),

              // Locale Switcher (EN / AR)
              OutlinedButton.icon(
                onPressed: () => setState(() => _isArabic = !_isArabic),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.language_rounded, size: 16),
                label: Text(
                  _isArabic ? 'العربية (RTL)' : 'English (LTR)',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),

              // Dark Mode Toggle
              IconButton(
                onPressed: () => setState(() => _isDark = !_isDark),
                icon: Icon(
                  _isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  size: 20,
                ),
                tooltip: 'Toggle Theme',
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Row 2: Screen Archetype Pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ShowcaseScreen.values.map((screen) {
                final isSelected = _activeScreen == screen;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: isSelected,
                    showCheckmark: false,
                    avatar: Icon(
                      screen.icon,
                      size: 16,
                      color: isSelected ? Colors.white : null,
                    ),
                    label: Text(screen.label),
                    labelStyle: TextStyle(
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      fontSize: 12,
                      color: isSelected ? Colors.white : null,
                    ),
                    selectedColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    onSelected: (val) => setState(() => _activeScreen = screen),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewportButton(_ViewportMode mode, IconData icon, String label) {
    final active = _viewport == mode;
    return InkWell(
      onTap: () => setState(() => _viewport = mode),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF2563EB) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: active ? Colors.white : null),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                color: active ? Colors.white : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewportFrame() {
    Widget activeContent;
    switch (_activeConcept) {
      case ConceptDirection.conceptA:
        activeContent = ConceptAScreens.buildScreen(_activeScreen, _isDark, _isArabic);
        break;
      case ConceptDirection.conceptB:
        activeContent = ConceptBScreens.buildScreen(_activeScreen, _isDark, _isArabic);
        break;
      case ConceptDirection.conceptC:
        activeContent = ConceptCScreens.buildScreen(_activeScreen, _isDark, _isArabic);
        break;
    }

    final directionalContent = Directionality(
      textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: activeContent,
    );

    if (_viewport == _ViewportMode.fluid) {
      return directionalContent;
    }

    Size frameSize;
    String deviceTag;
    switch (_viewport) {
      case _ViewportMode.mobile:
        frameSize = const Size(390, 844);
        deviceTag = 'Mobile (390 × 844)';
        break;
      case _ViewportMode.tablet:
        frameSize = const Size(768, 1024);
        deviceTag = 'Tablet (768 × 1024)';
        break;
      case _ViewportMode.desktop:
        frameSize = const Size(1280, 800);
        deviceTag = 'Desktop (1280 × 800)';
        break;
      case _ViewportMode.fluid:
        frameSize = Size.zero;
        deviceTag = '';
        break;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Device Tag Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              deviceTag,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ),

          // Rendered Frame Container
          Container(
            width: frameSize.width,
            height: frameSize.height,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: _isDark ? Colors.black : Colors.white,
              borderRadius: BorderRadius.circular(_viewport == _ViewportMode.mobile ? 32 : 12),
              border: Border.all(
                color: _isDark ? const Color(0xFF374151) : const Color(0xFF94A3B8),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: directionalContent,
          ),
        ],
      ),
    );
  }
}

enum _ViewportMode { mobile, tablet, desktop, fluid }
