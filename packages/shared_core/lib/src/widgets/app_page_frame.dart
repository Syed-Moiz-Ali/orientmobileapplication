import 'package:flutter/material.dart';
import 'package:shared_core/src/layout/app_responsive.dart';
import 'package:shared_core/src/theme/app_colors.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';
import 'package:shared_core/src/widgets/app_page_header.dart';

/// Standard responsive page frame capable of adapting smoothly across:
/// - Compact phone (<600px): fluid, comfortable gutters
/// - Comfortable tablet (600px - 1024px): bounded content, padded gutters
/// - Contained desktop (1024px - 1440px): max-width centered reading/working area
/// - Full dashboard desktop: optional [isFullWidth] mode for wide operational views
class AppPageFrame extends StatelessWidget {
  /// The primary content of the page.
  final Widget child;

  /// An optional structured page header. If provided, renders an [AppPageHeader].
  final String? title;
  final String? subtitle;
  final String? eyebrow;
  final Widget? leading;
  final Widget? primaryAction;
  final Widget? secondaryAction;
  final Widget? trailing;

  /// Custom header widget if [title] is not supplied.
  final Widget? header;

  /// Optional subheader slot, e.g. a search/filter bar or tabs.
  final Widget? subheader;

  /// Optional sticky footer slot, e.g. an action bar.
  final Widget? footer;

  /// Whether the page body should be wrapped in a [SingleChildScrollView].
  /// Defaults to true.
  final bool scrollable;

  /// Whether the content should expand to full width on wide screens.
  /// Defaults to false (contained reading/workspace width).
  final bool isFullWidth;

  /// Custom padding overriding the responsive default.
  final EdgeInsetsGeometry? padding;

  /// Background color. Defaults to [AppColors.canvas].
  final Color? backgroundColor;

  /// Custom scroll physics.
  final ScrollPhysics? physics;

  const AppPageFrame({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.eyebrow,
    this.leading,
    this.primaryAction,
    this.secondaryAction,
    this.trailing,
    this.header,
    this.subheader,
    this.footer,
    this.scrollable = true,
    this.isFullWidth = false,
    this.padding,
    this.backgroundColor,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    final adaptive = context.adaptive;
    final theme = Theme.of(context);
    final bg = backgroundColor ?? theme.scaffoldBackgroundColor;

    Widget? resolvedHeader = header;
    if (resolvedHeader == null && title != null) {
      resolvedHeader = AppPageHeader(
        title: title!,
        subtitle: subtitle,
        eyebrow: eyebrow,
        leading: leading,
        primaryAction: primaryAction,
        secondaryAction: secondaryAction,
        trailing: trailing,
      );
    }

    final resolvedPadding = padding ?? adaptive.pagePadding;
    final maxAllowedWidth = isFullWidth
        ? (adaptive.isLargeDesktop ? 1600.0 : double.infinity)
        : adaptive.contentMaxWidth;

    final Widget bodyContent = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (resolvedHeader != null) ...[
          resolvedHeader,
          SizedBox(height: adaptive.sectionSpacing * 0.75),
        ],
        if (subheader != null) ...[
          subheader!,
          SizedBox(height: adaptive.sectionSpacing * 0.75),
        ],
        child,
      ],
    );

    final Widget paddedContent = Padding(
      padding: resolvedPadding,
      child: bodyContent,
    );

    final Widget constrained = Align(
      alignment: adaptive.pageAlignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxAllowedWidth),
        child: paddedContent,
      ),
    );

    Widget mainSection;
    if (scrollable) {
      mainSection = SingleChildScrollView(
        physics: physics,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: constrained,
      );
    } else {
      mainSection = constrained;
    }

    if (footer != null) {
      return ColoredBox(
        color: bg,
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(child: mainSection),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  border: Border(
                    top: BorderSide(color: AppColors.borderDefault),
                  ),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: adaptive.gutter,
                  vertical: AppDimensions.s12,
                ),
                child: Align(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxAllowedWidth),
                    child: footer,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ColoredBox(
      color: bg,
      child: SafeArea(
        top: false,
        bottom: false,
        child: mainSection,
      ),
    );
  }
}
