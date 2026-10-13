// Prototype review shell (spec §H): screen switcher, locale toggle, theme
// toggle, width presets and per-screen state variants around the six Phase 00
// screens. This chrome is NOT part of the design system - it exists so a
// reviewer can drive the prototype.
import 'package:flutter/material.dart';

import '../design/prototype_theme.dart';
import '../design/provisional_tokens.dart';
import '../l10n/provisional_strings.dart';
import '../screens/auth/login_prototype.dart';
import '../screens/dashboards/owner_dashboard_prototype.dart';
import '../screens/detail/technician_job_detail_prototype.dart';
import '../screens/forms/add_vehicle_prototype.dart';
import '../screens/listings/job_cards_prototype.dart';
import '../screens/workflows/inspection_prototype.dart';

enum PrototypeScreenKind { ownerDashboard, jobCards, technicianJob, addVehicle, login, inspection }

extension PrototypeScreenKindX on PrototypeScreenKind {
  String get labelKey => switch (this) {
        PrototypeScreenKind.ownerDashboard => 'console.screen.ownerDashboard',
        PrototypeScreenKind.jobCards => 'console.screen.jobCards',
        PrototypeScreenKind.technicianJob => 'console.screen.technicianJob',
        PrototypeScreenKind.addVehicle => 'console.screen.addVehicle',
        PrototypeScreenKind.login => 'console.screen.login',
        PrototypeScreenKind.inspection => 'console.screen.inspection',
      };

  IconData get icon => switch (this) {
        PrototypeScreenKind.ownerDashboard => Icons.space_dashboard_rounded,
        PrototypeScreenKind.jobCards => Icons.assignment_rounded,
        PrototypeScreenKind.technicianJob => Icons.build_circle_rounded,
        PrototypeScreenKind.addVehicle => Icons.directions_car_filled_rounded,
        PrototypeScreenKind.login => Icons.lock_outline_rounded,
        PrototypeScreenKind.inspection => Icons.fact_check_rounded,
      };

  /// State variants exposed per screen (captured in the visual pack).
  List<String> get variants => switch (this) {
        PrototypeScreenKind.ownerDashboard => ['populated', 'loading', 'empty', 'error'],
        PrototypeScreenKind.jobCards => ['populated', 'loading', 'empty', 'noMatch', 'error'],
        PrototypeScreenKind.technicianJob => ['active', 'delayed', 'completed', 'noTasks', 'loading', 'error'],
        PrototypeScreenKind.addVehicle => ['pristine', 'invalid', 'saving', 'saveError'],
        PrototypeScreenKind.login => ['default', 'invalid', 'otp', 'loading'],
        PrototypeScreenKind.inspection => ['partial', 'empty', 'complete', 'findingSheet', 'exitGuard'],
      };
}

class WidthPreset {
  final String label;
  final double width;
  final double height;

  const WidthPreset(this.label, this.width, this.height);
}

const List<WidthPreset> widthPresets = [
  WidthPreset('360', 360, 740),
  WidthPreset('390', 390, 844),
  WidthPreset('430', 430, 932),
  WidthPreset('600', 600, 960),
  WidthPreset('768', 768, 1024),
  WidthPreset('1024', 1024, 768),
  WidthPreset('1280', 1280, 800),
  WidthPreset('1440', 1440, 900),
];

class PrototypeShell extends StatefulWidget {
  final Locale locale;
  final ThemeMode themeMode;
  final ValueChanged<Locale> onLocaleChanged;
  final ValueChanged<ThemeMode> onThemeChanged;

  const PrototypeShell({
    super.key,
    required this.locale,
    required this.themeMode,
    required this.onLocaleChanged,
    required this.onThemeChanged,
  });

  @override
  State<PrototypeShell> createState() => _PrototypeShellState();
}

class _PrototypeShellState extends State<PrototypeShell> {
  PrototypeScreenKind _screen = PrototypeScreenKind.ownerDashboard;
  String? _variant;
  int _presetIndex = 1; // 390 default
  bool _fit = false;
  int _resetTicket = 0;

  String get _activeVariant => _variant ?? _screen.variants.first;

  void _selectScreen(PrototypeScreenKind kind) {
    setState(() {
      _screen = kind;
      _variant = null;
    });
  }

  void _reset() => setState(() => _resetTicket++);

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.canvas,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ConsoleBar(
            screen: _screen,
            variant: _activeVariant,
            preset: _fit ? null : widthPresets[_presetIndex],
            fit: _fit,
            locale: widget.locale,
            themeMode: widget.themeMode,
            onScreenChanged: _selectScreen,
            onVariantChanged: (v) => setState(() => _variant = v),
            onPresetChanged: (index) => setState(() {
              _presetIndex = index;
              _fit = false;
            }),
            onFitChanged: (fit) => setState(() => _fit = fit),
            onLocaleChanged: widget.onLocaleChanged,
            onThemeChanged: widget.onThemeChanged,
            onReset: _reset,
          ),
          Expanded(
            child: Container(
              color: p.surfaceSunken,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final preset = widthPresets[_presetIndex];
                  final frameWidth = _fit ? constraints.maxWidth : preset.width;
                  final frameHeight = _fit ? constraints.maxHeight : preset.height;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(ProtoSpace.s24),
                    child: Center(
                      child: _ViewportFrame(
                        width: frameWidth,
                        height: frameHeight,
                        child: _buildScreen(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScreen() {
    final resetKey = ValueKey('$_screen-$_activeVariant-$_resetTicket');
    return switch (_screen) {
      PrototypeScreenKind.ownerDashboard => OwnerDashboardPrototype(
          key: resetKey,
          variant: _activeVariant,
          onOpenJobCards: () => _selectScreen(PrototypeScreenKind.jobCards),
        ),
      PrototypeScreenKind.jobCards => JobCardsPrototype(
          key: resetKey,
          variant: _activeVariant,
        ),
      PrototypeScreenKind.technicianJob => TechnicianJobDetailPrototype(
          key: resetKey,
          variant: _activeVariant,
        ),
      PrototypeScreenKind.addVehicle => AddVehiclePrototype(
          key: resetKey,
          variant: _activeVariant,
        ),
      PrototypeScreenKind.login => LoginPrototype(
          key: resetKey,
          variant: _activeVariant,
        ),
      PrototypeScreenKind.inspection => InspectionPrototype(
          key: resetKey,
          variant: _activeVariant,
        ),
    };
  }
}

/// Fixed-size device frame with its own MediaQuery so screens respond to the
/// selected width exactly (no scaling - real breakpoints).
class _ViewportFrame extends StatelessWidget {
  final double width;
  final double height;
  final Widget child;

  const _ViewportFrame({required this.width, required this.height, required this.child});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final size = Size(width, height);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ProtoRadius.panel),
        border: Border.all(color: p.borderStrong, width: 1.5),
        boxShadow: ProtoElevation.modal,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ProtoRadius.panel),
        child: SizedBox(
          width: width,
          height: height,
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              size: size,
              devicePixelRatio: 1,
              padding: EdgeInsets.zero,
              viewPadding: EdgeInsets.zero,
              viewInsets: EdgeInsets.zero,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _ConsoleBar extends StatelessWidget {
  final PrototypeScreenKind screen;
  final String variant;
  final WidthPreset? preset;
  final bool fit;
  final Locale locale;
  final ThemeMode themeMode;
  final ValueChanged<PrototypeScreenKind> onScreenChanged;
  final ValueChanged<String> onVariantChanged;
  final ValueChanged<int> onPresetChanged;
  final ValueChanged<bool> onFitChanged;
  final ValueChanged<Locale> onLocaleChanged;
  final ValueChanged<ThemeMode> onThemeChanged;
  final VoidCallback onReset;

  const _ConsoleBar({
    required this.screen,
    required this.variant,
    required this.preset,
    required this.fit,
    required this.locale,
    required this.themeMode,
    required this.onScreenChanged,
    required this.onVariantChanged,
    required this.onPresetChanged,
    required this.onFitChanged,
    required this.onLocaleChanged,
    required this.onThemeChanged,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ProtoPalette.light.navy,
        border: Border(bottom: BorderSide(color: ProtoPalette.light.navyRaised)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: ProtoSpace.s20, vertical: ProtoSpace.s12),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: ProtoSpace.s16,
              runSpacing: ProtoSpace.s10,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: ProtoPalette.light.primary,
                        borderRadius: BorderRadius.circular(ProtoRadius.control),
                      ),
                      child: const Icon(Icons.science_rounded, color: Colors.white, size: 17),
                    ),
                    const SizedBox(width: ProtoSpace.s10),
                    Text(
                      context.s('console.title'),
                      style: context.types.cardTitle.copyWith(color: Colors.white),
                    ),
                  ],
                ),
                _segmented(
                  context,
                  options: const ['EN', 'ع'],
                  selected: locale.languageCode == 'ar' ? 1 : 0,
                  onSelect: (i) => onLocaleChanged(Locale(i == 1 ? 'ar' : 'en')),
                  tooltip: context.s('console.language'),
                ),
                _segmented(
                  context,
                  options: [context.s('console.light'), context.s('console.dark')],
                  selected: themeMode == ThemeMode.dark ? 1 : 0,
                  onSelect: (i) => onThemeChanged(i == 1 ? ThemeMode.dark : ThemeMode.light),
                  tooltip: context.s('console.theme'),
                ),
                _dropdown<String>(
                  context,
                  tooltip: context.s('console.width'),
                  value: fit ? 'fit' : (preset?.label ?? '390'),
                  items: [
                    for (final preset in widthPresets) preset.label,
                    'fit',
                  ],
                  labelOf: (v) => v == 'fit' ? context.s('console.fit') : v,
                  onSelect: (v) {
                    if (v == 'fit') {
                      onFitChanged(true);
                    } else {
                      onPresetChanged(widthPresets.indexWhere((preset) => preset.label == v));
                    }
                  },
                ),
                _dropdown<String>(
                  context,
                  tooltip: context.s('console.state'),
                  value: variant,
                  items: screen.variants,
                  labelOf: (v) => context.s('console.state.$v'),
                  onSelect: onVariantChanged,
                ),
                TextButton.icon(
                  onPressed: onReset,
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFF9DB4FF)),
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: Text(context.s('console.reset')),
                ),
              ],
            ),
            const SizedBox(height: ProtoSpace.s10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final kind in PrototypeScreenKind.values) ...[
                    _ScreenChip(
                      kind: kind,
                      selected: kind == screen,
                      onTap: () => onScreenChanged(kind),
                    ),
                    const SizedBox(width: ProtoSpace.s8),
                  ],
                ],
              ),
            ),
            const SizedBox(height: ProtoSpace.s8),
            Text(
              context.s('console.subtitle'),
              style: context.types.metadata.copyWith(color: ProtoPalette.light.onNavySecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _segmented(
    BuildContext context, {
    required List<String> options,
    required int selected,
    required ValueChanged<int> onSelect,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        decoration: BoxDecoration(
          color: ProtoPalette.light.navyRaised,
          borderRadius: BorderRadius.circular(ProtoRadius.control),
        ),
        padding: const EdgeInsets.all(3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < options.length; i++)
              GestureDetector(
                onTap: () => onSelect(i),
                child: AnimatedContainer(
                  duration: ProtoMotion.fast,
                  padding: const EdgeInsets.symmetric(horizontal: ProtoSpace.s12, vertical: ProtoSpace.s6),
                  decoration: BoxDecoration(
                    color: i == selected ? ProtoPalette.light.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(ProtoRadius.sm),
                  ),
                  child: Text(
                    options[i],
                    style: context.types.label.copyWith(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: i == selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _dropdown<T>(
    BuildContext context, {
    required String tooltip,
    required T value,
    required List<T> items,
    required String Function(T) labelOf,
    required ValueChanged<T> onSelect,
  }) {
    return Tooltip(
      message: tooltip,
      child: PopupMenuButton<T>(
        initialValue: value,
        onSelected: onSelect,
        color: ProtoPalette.light.navyRaised,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ProtoRadius.control)),
        itemBuilder: (context) => [
          for (final item in items)
            PopupMenuItem<T>(
              value: item,
              child: Text(
                labelOf(item),
                style: context.types.body.copyWith(color: Colors.white),
              ),
            ),
        ],
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: ProtoSpace.s12, vertical: ProtoSpace.s10),
          decoration: BoxDecoration(
            color: ProtoPalette.light.navyRaised,
            borderRadius: BorderRadius.circular(ProtoRadius.control),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                labelOf(value),
                style: context.types.label.copyWith(color: Colors.white, fontSize: 12),
              ),
              const SizedBox(width: ProtoSpace.s6),
              const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScreenChip extends StatelessWidget {
  final PrototypeScreenKind kind;
  final bool selected;
  final VoidCallback onTap;

  const _ScreenChip({required this.kind, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? ProtoPalette.light.primary : ProtoPalette.light.navyRaised,
      borderRadius: BorderRadius.circular(ProtoRadius.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ProtoRadius.pill),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: ProtoSpace.s12, vertical: ProtoSpace.s8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(kind.icon, size: 15, color: Colors.white),
              const SizedBox(width: ProtoSpace.s6),
              Text(
                context.s(kind.labelKey),
                style: context.types.label.copyWith(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
