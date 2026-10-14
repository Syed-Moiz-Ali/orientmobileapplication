import 'package:flutter/material.dart';
import 'package:shared_core/src/localization/app_formatters.dart';
import 'package:shared_core/src/localization/shared_core_l10n.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';
import 'package:shared_core/src/theme/app_semantic_colors.dart';
import 'package:shared_core/src/theme/app_text_styles.dart';
import 'package:shared_core/src/theme/app_theme_context.dart';

/// Shared chart language for every analytics surface in the suite.
///
/// This is a **pure colour / typography / geometry helper** — it deliberately
/// does **not** depend on `fl_chart` (owner painters, the staff `fl_chart`
/// usage and CRM `CustomPaint` all read from this one source, spec §7 / V8).
///
/// Frozen rules carried from Phase 00 / Phase 01, hardened in Phase 01.2:
/// - max **4 series** per chart ([maxSeries]);
/// - series colours come from [AppColors.chartSeries] / [AppColors.chartSeriesDark];
/// - axis labels use [AppTextStyles.metadata] and localize; numeric values keep
///   tabular figures; currency values format through [AppFormatters.moneyAED];
/// - gridlines are subtle (`colors.outline`);
/// - **RTL mirrors series/legend order** via [orderSeries];
/// - empty data renders as [AppChartPlaceholder], never a blank plot.
class AppChartTheme {
  /// Whether the active brightness is dark.
  final bool isDark;

  /// Whether the ambient reading direction is RTL.
  final bool isRtl;

  /// Whether the active locale is Arabic (typography metrics).
  final bool isArabic;

  /// The 6-value series palette for the active brightness.
  final List<Color> palette;

  /// Axis tick label style.
  final TextStyle axisLabelStyle;

  /// Data-value / tooltip value style (tabular figures).
  final TextStyle valueLabelStyle;

  /// Subtle gridline ink.
  final Color gridlineColor;

  /// Axis baseline ink.
  final Color baselineColor;

  /// Plot / card surface for chart containers.
  final Color surfaceColor;

  /// Tooltip container decoration.
  final BoxDecoration tooltipDecoration;

  /// Tooltip text style.
  final TextStyle tooltipTextStyle;

  /// Gridline stroke width.
  final double gridlineWidth;

  /// Corner radius for bar series.
  final double barRadius;

  /// Stroke width for line series.
  final double lineWidth;

  /// Radius of a line-series data dot.
  final double dotRadius;

  const AppChartTheme({
    required this.isDark,
    required this.isRtl,
    required this.isArabic,
    required this.palette,
    required this.axisLabelStyle,
    required this.valueLabelStyle,
    required this.gridlineColor,
    required this.baselineColor,
    required this.surfaceColor,
    required this.tooltipDecoration,
    required this.tooltipTextStyle,
    this.gridlineWidth = 1,
    this.barRadius = 6,
    this.lineWidth = 2,
    this.dotRadius = 4,
  });

  /// Frozen maximum number of series rendered on one chart (Phase 01.2: 4).
  static const int maxSeries = 4;

  /// Series palette for a brightness (frozen semantic source lists).
  static List<Color> paletteFor(Brightness brightness) =>
      AppSemanticColors.forBrightness(brightness).chartSeries;

  /// Resolves the chart language for the active theme + locale + direction.
  static AppChartTheme of(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;
    final semantic = context.semanticColors;
    final locale = Localizations.maybeLocaleOf(context);
    final arabic = AppTypography.isArabic(locale);
    final rtl = Directionality.of(context) == TextDirection.rtl;

    return AppChartTheme(
      isDark: dark,
      isRtl: rtl,
      isArabic: arabic,
      palette: semantic.chartSeries,
      axisLabelStyle: AppTextStyles.metadata(
        color: colors.onSurfaceVariant,
        arabic: arabic,
      ),
      valueLabelStyle: AppTextStyles.mono(
        color: colors.onSurface,
        arabic: arabic,
      ),
      gridlineColor: colors.outline,
      baselineColor: colors.outlineVariant,
      surfaceColor: colors.surface,
      tooltipDecoration: BoxDecoration(
        color: colors.inverseSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
        boxShadow: AppDimensions.shadowModal,
      ),
      tooltipTextStyle: AppTextStyles.bodySmall(
        color: colors.onInverseSurface,
        arabic: arabic,
      ),
    );
  }

  /// Series colour for a zero-based index (wraps the palette).
  Color seriesColor(int index) {
    if (palette.isEmpty) return baselineColor;
    return palette[index % palette.length];
  }

  /// The first [count] series colours, capped at [maxSeries].
  List<Color> seriesColors(int count) {
    final capped = count.clamp(0, maxSeries);
    return [for (var i = 0; i < capped; i++) seriesColor(i)];
  }

  /// Formats a currency axis/tooltip value through the locale-aware
  /// [AppFormatters.moneyAED] (Latin digits in both locales, `AED` prefix in
  /// EN / `د.إ` suffix in AR). Keeps number formatting in one authority.
  String formatCurrency(num value, AppFormatters formatters) =>
      formatters.moneyAED(value);

  /// Formats a generic axis value: currency when [currency] is true, otherwise
  /// a grouped quantity. Both keep Latin digits per the frozen V5 policy.
  String formatValue(
    num value,
    AppFormatters formatters, {
    bool currency = false,
  }) => currency ? formatters.moneyAED(value) : formatters.group(value);

  /// Mirrors series/legend order in RTL so the first series sits at the
  /// reading-start edge in both languages (spec §5 RTL rule 7).
  List<T> orderSeries<T>(List<T> series) =>
      isRtl ? series.reversed.toList() : series;

  /// Palette order to use for a chart given a series count.
  List<Color> orderedPalette(int count) => orderSeries(seriesColors(count));
}

/// Empty-data placeholder for charts: a state, never a blank plot (V8).
class AppChartPlaceholder extends StatelessWidget {
  final String? title;
  final String? message;
  final IconData icon;
  final double height;
  final Widget? action;

  const AppChartPlaceholder({
    super.key,
    this.title,
    this.message,
    this.icon = Icons.insert_chart_outlined_rounded,
    this.height = 180,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = SharedCoreL10n.of(context);

    // Compact slots (e.g. a sparkline) cannot fit the stacked icon + title +
    // message; fall back to a single dense row so the state never overflows.
    if (height < 140) {
      return SizedBox(
        height: height,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.s16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: colors.onSurfaceVariant),
                const SizedBox(width: AppDimensions.s8),
                Flexible(
                  child: Text(
                    message ?? t.chartEmptyMessage,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: height,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.s24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 28, color: colors.onSurfaceVariant),
              const SizedBox(height: AppDimensions.s12),
              Text(
                title ?? t.commonNoData,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: AppDimensions.s4),
              Text(
                message ?? t.chartEmptyMessage,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              if (action != null) ...[
                const SizedBox(height: AppDimensions.s12),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
