import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';

enum AppWindowClass { compact, medium, expanded, large }

class AppAdaptiveSpec {
  final AppWindowClass windowClass;
  final Size size;
  final EdgeInsets safeArea;
  final EdgeInsets viewInsets;
  final bool isShort;
  final bool keyboardOpen;
  final EdgeInsets pagePadding;
  final double contentMaxWidth;
  final double formMaxWidth;
  final double dialogMaxWidth;
  final double gutter;
  final double sectionSpacing;
  final double itemSpacing;
  final double controlHeight;
  final double radius;
  final int gridColumns;
  final bool useNavigationRail;
  final bool extendNavigationRail;
  final double navigationRailWidth;
  final Alignment pageAlignment;
  final Alignment focusedFlowAlignment;

  const AppAdaptiveSpec({
    required this.windowClass,
    required this.size,
    required this.safeArea,
    required this.viewInsets,
    required this.isShort,
    required this.keyboardOpen,
    required this.pagePadding,
    required this.contentMaxWidth,
    required this.formMaxWidth,
    required this.dialogMaxWidth,
    required this.gutter,
    required this.sectionSpacing,
    required this.itemSpacing,
    required this.controlHeight,
    required this.radius,
    required this.gridColumns,
    required this.useNavigationRail,
    required this.extendNavigationRail,
    required this.navigationRailWidth,
    required this.pageAlignment,
    required this.focusedFlowAlignment,
  });

  bool get isCompact => windowClass == AppWindowClass.compact;
  bool get isMedium => windowClass == AppWindowClass.medium;
  bool get isExpanded => windowClass == AppWindowClass.expanded;
  bool get isLarge => windowClass == AppWindowClass.large;

  T pick<T>({required T compact, T? medium, T? expanded, T? large}) {
    return switch (windowClass) {
      AppWindowClass.compact => compact,
      AppWindowClass.medium => medium ?? compact,
      AppWindowClass.expanded => expanded ?? medium ?? compact,
      AppWindowClass.large => large ?? expanded ?? medium ?? compact,
    };
  }
}

extension AppResponsiveContext on BuildContext {
  AppWindowClass get windowClass => AppResponsive.classOf(this);

  AppAdaptiveSpec get adaptive => AppResponsive.specOf(this);

  bool get isCompact => windowClass == AppWindowClass.compact;

  bool get isMedium => windowClass == AppWindowClass.medium;

  bool get isExpanded => windowClass == AppWindowClass.expanded;

  bool get isLarge => windowClass == AppWindowClass.large;

  EdgeInsets get pagePadding => AppResponsive.pagePaddingFor(this);

  double get contentMaxWidth => AppResponsive.contentMaxWidthFor(this);

  int get gridColumns => AppResponsive.gridColumnsFor(this);
}

abstract final class AppResponsive {
  AppResponsive._();

  static const double compactMax = 599;
  static const double mediumMax = 1023;
  static const double expandedMax = 1439;

  static AppWindowClass classForWidth(double width) {
    if (width <= compactMax) return AppWindowClass.compact;
    if (width <= mediumMax) return AppWindowClass.medium;
    if (width <= expandedMax) return AppWindowClass.expanded;
    return AppWindowClass.large;
  }

  static AppWindowClass classOf(BuildContext context) {
    return classForWidth(MediaQuery.sizeOf(context).width);
  }

  static AppAdaptiveSpec specOf(BuildContext context) {
    return specFor(context, size: MediaQuery.sizeOf(context));
  }

  static AppAdaptiveSpec specFor(BuildContext context, {Size? size, BoxConstraints? constraints}) {
    final media = MediaQuery.maybeOf(context);
    final fallbackSize = media?.size ?? Size.zero;
    final resolvedSize = size ?? _sizeFromConstraints(constraints) ?? fallbackSize;
    final width = resolvedSize.width;
    final height = resolvedSize.height;
    final windowClass = classForWidth(width);
    final isShort = height > 0 && height < 680;
    final viewInsets = media?.viewInsets ?? EdgeInsets.zero;
    final keyboardOpen = viewInsets.bottom > 0;

    return AppAdaptiveSpec(
      windowClass: windowClass,
      size: resolvedSize,
      safeArea: media?.padding ?? EdgeInsets.zero,
      viewInsets: viewInsets,
      isShort: isShort,
      keyboardOpen: keyboardOpen,
      pagePadding: _pagePaddingFor(windowClass, width),
      contentMaxWidth: _contentMaxWidthFor(windowClass),
      formMaxWidth: _formMaxWidthFor(windowClass),
      dialogMaxWidth: _dialogMaxWidthFor(windowClass),
      gutter: _gutterFor(windowClass),
      sectionSpacing: _sectionSpacingFor(windowClass),
      itemSpacing: _itemSpacingFor(windowClass),
      controlHeight: _controlHeightFor(windowClass),
      radius: _radiusFor(windowClass),
      gridColumns: _gridColumnsFor(windowClass),
      useNavigationRail: windowClass != AppWindowClass.compact,
      extendNavigationRail: windowClass == AppWindowClass.large,
      navigationRailWidth: _navigationRailWidthFor(windowClass),
      pageAlignment: Alignment.topCenter,
      focusedFlowAlignment: keyboardOpen || isShort ? Alignment.topCenter : _focusedFlowAlignmentFor(windowClass),
    );
  }

  static Size? _sizeFromConstraints(BoxConstraints? constraints) {
    if (constraints == null) return null;
    final width = constraints.hasBoundedWidth ? constraints.maxWidth : 0.0;
    final height = constraints.hasBoundedHeight ? constraints.maxHeight : 0.0;
    if (width <= 0 && height <= 0) return null;
    return Size(width, height);
  }

  static EdgeInsets pagePaddingFor(BuildContext context) {
    return specOf(context).pagePadding;
  }

  static double contentMaxWidthFor(BuildContext context) {
    return specOf(context).contentMaxWidth;
  }

  static int gridColumnsFor(BuildContext context) {
    return specOf(context).gridColumns;
  }

  static EdgeInsets _pagePaddingFor(AppWindowClass windowClass, double width) {
    return switch (windowClass) {
      AppWindowClass.compact => EdgeInsets.symmetric(
        horizontal: width < 360 ? AppDimensions.s16 : AppDimensions.s20,
        vertical: AppDimensions.s16,
      ),
      AppWindowClass.medium => const EdgeInsets.symmetric(horizontal: AppDimensions.s28, vertical: AppDimensions.s24),
      AppWindowClass.expanded => const EdgeInsets.symmetric(horizontal: AppDimensions.s40, vertical: AppDimensions.s28),
      AppWindowClass.large => const EdgeInsets.symmetric(horizontal: AppDimensions.s48, vertical: AppDimensions.s32),
    };
  }

  static double _contentMaxWidthFor(AppWindowClass windowClass) {
    return switch (windowClass) {
      AppWindowClass.compact => double.infinity,
      AppWindowClass.medium => 860,
      AppWindowClass.expanded => 1180,
      AppWindowClass.large => 1320,
    };
  }

  static double _formMaxWidthFor(AppWindowClass windowClass) {
    return switch (windowClass) {
      AppWindowClass.compact => double.infinity,
      AppWindowClass.medium => 420,
      AppWindowClass.expanded => 440,
      AppWindowClass.large => 460,
    };
  }

  static double _dialogMaxWidthFor(AppWindowClass windowClass) {
    return switch (windowClass) {
      AppWindowClass.compact => double.infinity,
      AppWindowClass.medium => 520,
      AppWindowClass.expanded => 560,
      AppWindowClass.large => 600,
    };
  }

  static double _gutterFor(AppWindowClass windowClass) {
    return switch (windowClass) {
      AppWindowClass.compact => AppDimensions.s16,
      AppWindowClass.medium => AppDimensions.s20,
      AppWindowClass.expanded => AppDimensions.s24,
      AppWindowClass.large => AppDimensions.s28,
    };
  }

  static double _sectionSpacingFor(AppWindowClass windowClass) {
    return switch (windowClass) {
      AppWindowClass.compact => AppDimensions.s24,
      AppWindowClass.medium => AppDimensions.s28,
      AppWindowClass.expanded => AppDimensions.s32,
      AppWindowClass.large => AppDimensions.s40,
    };
  }

  static double _itemSpacingFor(AppWindowClass windowClass) {
    return switch (windowClass) {
      AppWindowClass.compact => AppDimensions.s12,
      AppWindowClass.medium => AppDimensions.s16,
      AppWindowClass.expanded => AppDimensions.s18,
      AppWindowClass.large => AppDimensions.s20,
    };
  }

  static double _controlHeightFor(AppWindowClass windowClass) {
    return switch (windowClass) {
      AppWindowClass.compact => 48,
      AppWindowClass.medium => 50,
      AppWindowClass.expanded => 52,
      AppWindowClass.large => 54,
    };
  }

  static double _radiusFor(AppWindowClass windowClass) {
    return switch (windowClass) {
      AppWindowClass.compact => AppDimensions.r10,
      AppWindowClass.medium => AppDimensions.r12,
      AppWindowClass.expanded => AppDimensions.r12,
      AppWindowClass.large => AppDimensions.r14,
    };
  }

  static int _gridColumnsFor(AppWindowClass windowClass) {
    return switch (windowClass) {
      AppWindowClass.compact => 1,
      AppWindowClass.medium => 2,
      AppWindowClass.expanded => 3,
      AppWindowClass.large => 4,
    };
  }

  static double _navigationRailWidthFor(AppWindowClass windowClass) {
    return switch (windowClass) {
      AppWindowClass.compact => 0,
      AppWindowClass.medium => 76,
      AppWindowClass.expanded => 92,
      AppWindowClass.large => 92,
    };
  }

  static Alignment _focusedFlowAlignmentFor(AppWindowClass windowClass) {
    return switch (windowClass) {
      AppWindowClass.compact => const Alignment(0, -0.34),
      AppWindowClass.medium => const Alignment(0, -0.28),
      AppWindowClass.expanded => const Alignment(0, -0.22),
      AppWindowClass.large => const Alignment(0, -0.18),
    };
  }
}

class AppAdaptiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, AppAdaptiveSpec adaptive) builder;

  const AppAdaptiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return builder(context, AppResponsive.specFor(context, constraints: constraints));
      },
    );
  }
}

class AppResponsivePage extends StatelessWidget {
  final Widget child;
  final bool scrollable;
  final bool constrainWidth;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final ScrollPhysics? physics;

  const AppResponsivePage({
    super.key,
    required this.child,
    this.scrollable = true,
    this.constrainWidth = true,
    this.padding,
    this.backgroundColor,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final adaptive = context.adaptive;
    final resolvedPadding = padding ?? adaptive.pagePadding;

    Widget content = Padding(padding: resolvedPadding, child: child);

    if (constrainWidth) {
      content = Align(
        alignment: adaptive.pageAlignment,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: adaptive.contentMaxWidth),
          child: content,
        ),
      );
    }

    if (scrollable) {
      content = SingleChildScrollView(
        physics: physics,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: content,
      );
    }

    return ColoredBox(
      color: backgroundColor ?? theme.scaffoldBackgroundColor,
      child: SafeArea(top: false, bottom: false, child: content),
    );
  }
}

class AppAdaptiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int? columns;
  final double? spacing;
  final double? runSpacing;
  final double? minChildWidth;
  final double childAspectRatio;

  const AppAdaptiveGrid({
    super.key,
    required this.children,
    this.columns,
    this.spacing,
    this.runSpacing,
    this.minChildWidth,
    this.childAspectRatio = 1,
  });

  @override
  Widget build(BuildContext context) {
    final adaptive = context.adaptive;
    final resolvedSpacing = spacing ?? adaptive.gutter;
    final resolvedColumns = columns ?? adaptive.gridColumns;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final minWidth = minChildWidth ?? adaptive.pick(compact: 220.0, medium: 240.0, expanded: 260.0, large: 280.0);
        final autoColumns = width.isFinite
            ? ((width + resolvedSpacing) / (minWidth! + resolvedSpacing)).floor().clamp(1, resolvedColumns).toInt()
            : resolvedColumns;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: autoColumns,
            crossAxisSpacing: resolvedSpacing,
            mainAxisSpacing: runSpacing ?? resolvedSpacing,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }
}

class AppSplitView extends StatelessWidget {
  final Widget primary;
  final Widget secondary;
  final double primaryFlex;
  final double secondaryFlex;
  final double spacing;
  final bool forceStacked;

  const AppSplitView({
    super.key,
    required this.primary,
    required this.secondary,
    this.primaryFlex = 1,
    this.secondaryFlex = 1,
    this.spacing = AppDimensions.s20,
    this.forceStacked = false,
  });

  @override
  Widget build(BuildContext context) {
    final adaptive = context.adaptive;
    final stacked = forceStacked || adaptive.isCompact;
    final resolvedSpacing = spacing == AppDimensions.s20 ? adaptive.gutter : spacing;

    if (stacked) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          primary,
          SizedBox(height: resolvedSpacing),
          secondary,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: primaryFlex.round(), child: primary),
        SizedBox(width: resolvedSpacing),
        Expanded(flex: secondaryFlex.round(), child: secondary),
      ],
    );
  }
}
